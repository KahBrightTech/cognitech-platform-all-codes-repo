# Terraform configuration to create the Ansible Master SSM Document
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Variables for the SSM document
variable "document_name" {
  description = "Name of the SSM document"
  type        = string
  default     = "ansible-masterv2"
}

variable "document_description" {
  description = "Description of the SSM document"
  type        = string
  default     = "Document to create ansible master on instances"
}

variable "tags" {
  description = "Tags to apply to the SSM document"
  type        = map(string)
  default = {
    Environment = "production"
    Purpose     = "ansible-configuration"
    ManagedBy   = "terraform"
  }
}

# SSM Document for Ansible Master Configuration
resource "aws_ssm_document" "ansible_masterv2" {
  name            = var.document_name
  document_type   = "Command"
  document_format = "YAML"

  # Document content from external YAML file
  content = file("${path.module}/ansible-masterv2-document.yaml")

  tags = var.tags
}

# Output the document name and ARN
output "ssm_document_name" {
  description = "Name of the created SSM document"
  value       = aws_ssm_document.ansible_masterv2.name
}

output "ssm_document_arn" {
  description = "ARN of the created SSM document"
  value       = aws_ssm_document.ansible_masterv2.arn
}

output "ssm_document_status" {
  description = "Status of the SSM document"
  value       = aws_ssm_document.ansible_masterv2.status
}

output "ssm_document_version" {
  description = "Version of the SSM document"
  value       = aws_ssm_document.ansible_masterv2.latest_version
}
