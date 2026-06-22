#!/usr/bin/env python3

"""List or delete inactive IAM roles based on last used activity.

By default this script performs a dry run and prints the roles that would be
considered for deletion. Pass --delete to actually remove eligible roles.

Usage
-----
Prerequisites:
    pip install boto3
    # Configure AWS credentials via `aws configure`, environment variables,
    # or an AWS named profile (see --profile below).

Dry run (default, makes NO changes):
    # Report roles inactive for more than 100 days (the default threshold).
    python cleanup_inactive_iam_roles.py

    # Use a specific AWS profile and a custom threshold of 90 days.
    python cleanup_inactive_iam_roles.py --profile myprofile --days 90

    # Also list roles that have no last-used timestamp but were created
    # before the threshold.
    python cleanup_inactive_iam_roles.py --include-never-used

Actual run (DELETES roles, irreversible):
    # Review the dry-run output first, then add --delete to remove the roles.
    python cleanup_inactive_iam_roles.py --delete

    # Delete with a custom threshold and profile.
    python cleanup_inactive_iam_roles.py --profile myprofile --days 90 --delete

    # Safely test deletion against a small batch first with --max-roles.
    python cleanup_inactive_iam_roles.py --delete --max-roles 1
"""

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import Iterator, Optional

import boto3
from botocore.exceptions import BotoCoreError, ClientError, ProfileNotFound


SERVICE_LINKED_PATH_PREFIX = "/aws-service-role/"


@dataclass
class RoleEvaluation:
    role_name: str
    arn: str
    created: datetime
    last_used: Optional[datetime]
    age_days: Optional[int]
    reason: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "List IAM roles whose last activity is older than the threshold and "
            "optionally delete them."
        )
    )
    parser.add_argument(
        "--days",
        type=int,
        default=100,
        help="Delete roles inactive for more than this many days. Default: 100.",
    )
    parser.add_argument(
        "--profile",
        help="AWS named profile to use. If omitted, boto3 default credential resolution is used.",
    )
    parser.add_argument(
        "--delete",
        action="store_true",
        help="Actually delete the matching roles. Without this flag, the script only reports matches.",
    )
    parser.add_argument(
        "--include-never-used",
        action="store_true",
        help=(
            "Include roles with no last-used timestamp when their creation date is older "
            "than the threshold."
        ),
    )
    parser.add_argument(
        "--max-roles",
        type=int,
        help="Optional cap on the number of matching roles to process.",
    )
    return parser.parse_args()


def build_iam_client(profile: Optional[str]):
    session_kwargs = {"profile_name": profile} if profile else {}
    session = boto3.Session(**session_kwargs)
    return session.client("iam")


def iter_roles(iam_client) -> Iterator[dict]:
    paginator = iam_client.get_paginator("list_roles")
    for page in paginator.paginate():
        for role in page.get("Roles", []):
            yield role


def fetch_role_detail(iam_client, role_name: str) -> dict:
    # list_roles frequently returns an empty RoleLastUsed, so fetch the
    # authoritative last-used data per role via get_role.
    return iam_client.get_role(RoleName=role_name)["Role"]


def is_service_linked_role(role: dict) -> bool:
    path = role.get("Path", "")
    role_name = role.get("RoleName", "")
    return path.startswith(SERVICE_LINKED_PATH_PREFIX) or role_name.startswith("AWSServiceRoleFor")


def evaluate_role(role: dict, threshold_days: int, include_never_used: bool, now: datetime) -> Optional[RoleEvaluation]:
    if is_service_linked_role(role):
        return None

    role_name = role["RoleName"]
    arn = role["Arn"]
    created = role["CreateDate"]
    last_used = role.get("RoleLastUsed", {}).get("LastUsedDate")

    if last_used is not None:
        age_days = (now - last_used).days
        if age_days <= threshold_days:
            return None
        reason = f"last used {age_days} days ago"
        return RoleEvaluation(role_name, arn, created, last_used, age_days, reason)

    created_age_days = (now - created).days
    if include_never_used and created_age_days > threshold_days:
        reason = (
            "no tracked last-used timestamp; role is older than the threshold "
            f"({created_age_days} days since creation)"
        )
        return RoleEvaluation(role_name, arn, created, None, None, reason)

    return None


def format_timestamp(value: Optional[datetime]) -> str:
    if value is None:
        return "never-tracked"
    return value.astimezone(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")


def detach_managed_policies(iam_client, role_name: str) -> None:
    paginator = iam_client.get_paginator("list_attached_role_policies")
    for page in paginator.paginate(RoleName=role_name):
        for policy in page.get("AttachedPolicies", []):
            iam_client.detach_role_policy(RoleName=role_name, PolicyArn=policy["PolicyArn"])


def delete_inline_policies(iam_client, role_name: str) -> None:
    paginator = iam_client.get_paginator("list_role_policies")
    for page in paginator.paginate(RoleName=role_name):
        for policy_name in page.get("PolicyNames", []):
            iam_client.delete_role_policy(RoleName=role_name, PolicyName=policy_name)


def remove_from_instance_profiles(iam_client, role_name: str) -> None:
    paginator = iam_client.get_paginator("list_instance_profiles_for_role")
    for page in paginator.paginate(RoleName=role_name):
        for profile in page.get("InstanceProfiles", []):
            iam_client.remove_role_from_instance_profile(
                InstanceProfileName=profile["InstanceProfileName"],
                RoleName=role_name,
            )


def delete_role(iam_client, role_name: str) -> None:
    detach_managed_policies(iam_client, role_name)
    delete_inline_policies(iam_client, role_name)
    remove_from_instance_profiles(iam_client, role_name)
    iam_client.delete_role(RoleName=role_name)


def main() -> int:
    args = parse_args()
    if args.days < 1:
        print("--days must be greater than zero", file=sys.stderr)
        return 2

    try:
        iam_client = build_iam_client(args.profile)
    except ProfileNotFound as exc:
        print(f"AWS profile error: {exc}", file=sys.stderr)
        return 2
    except (BotoCoreError, ClientError) as exc:
        print(f"Unable to create IAM client: {exc}", file=sys.stderr)
        return 2

    now = datetime.now(timezone.utc)
    threshold_date = now - timedelta(days=args.days)
    matches: list[RoleEvaluation] = []

    try:
        for role in iter_roles(iam_client):
            if is_service_linked_role(role):
                continue
            try:
                detailed_role = fetch_role_detail(iam_client, role["RoleName"])
            except (BotoCoreError, ClientError) as exc:
                print(
                    f"Skipping {role['RoleName']}: unable to fetch role details: {exc}",
                    file=sys.stderr,
                )
                continue
            evaluation = evaluate_role(detailed_role, args.days, args.include_never_used, now)
            if evaluation is None:
                continue
            matches.append(evaluation)
            if args.max_roles and len(matches) >= args.max_roles:
                break
    except (BotoCoreError, ClientError) as exc:
        print(f"Failed while listing IAM roles: {exc}", file=sys.stderr)
        return 1

    print(f"Threshold date: {threshold_date.strftime('%Y-%m-%d %H:%M:%S UTC')}")
    print(f"Matching roles: {len(matches)}")
    for match in matches:
        print(
            f"- {match.role_name} | created={format_timestamp(match.created)} | "
            f"last_used={format_timestamp(match.last_used)} | {match.reason}"
        )

    if not args.delete:
        print("Dry run only. Re-run with --delete to remove the matching roles.")
        return 0

    if not matches:
        print("No matching roles to delete.")
        return 0

    failures = 0
    for match in matches:
        try:
            delete_role(iam_client, match.role_name)
            print(f"Deleted role: {match.role_name}")
        except (BotoCoreError, ClientError) as exc:
            failures += 1
            print(f"Failed to delete role {match.role_name}: {exc}", file=sys.stderr)

    if failures:
        print(f"Completed with {failures} deletion failure(s).", file=sys.stderr)
        return 1

    print("Completed successfully.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())