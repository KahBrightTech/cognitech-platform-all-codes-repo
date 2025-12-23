function hs {
    param(
        [string]$DeploymentName,
        [string]$Revision
    )
    if (-not $DeploymentName) {
        $DeploymentName = Read-Host "Enter the deployment name"
    }
    $cmd = "kubectl rollout history deployment/$DeploymentName"
    if ($Revision) {
        $cmd += " --revision=$Revision"
    }
    Invoke-Expression $cmd
}