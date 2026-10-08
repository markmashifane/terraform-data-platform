variable "location" {
  type        = string
  default     = "South Africa North"
  description = "Azure region for deployment"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Deployment environment tag"
}
