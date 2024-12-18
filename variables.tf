#Define AWS Region
variable "region" {
  description = "Infrastructure region"
  type        = string
  default     = "us-east-2"
}
#Define IAM User Access Key
variable "access_key" {
  description = "The access_key that belongs to the IAM user"
  type        = string
  sensitive   = true
  default     = ""
}
#Define IAM User Secret Key
variable "secret_key" {
  description = "The secret_key that belongs to the IAM user"
  type        = string
  sensitive   = true
  default     = ""
}
variable "name" {
  description = "The name of the application."
  type        = string
  default     = "app-7"
}
variable "log_group_prefix" {
  description = "The name of the log group."
  type        = string
  default     = "/aws/lambda/"
}
variable "vpc_cidr" {
  description = "The CIDR of the VPC."
  type        = string
  default     = "12.25.15.0/25"
}
variable "subnet_cidr_private" {
  description = "The CIDR blocks for the private subnets."
  type        = list(any)
  default     = ["12.25.15.0/27", "12.25.15.32/27", "12.25.15.64/27"]
}