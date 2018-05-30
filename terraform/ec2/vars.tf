variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

variable "vpc_id" {}
variable "subnet_ids" {
  type = "list"
}
variable "instance_name" {}
variable "key_name" {}
variable "instance_type" {}
variable "ami_id" {}
variable "security_group_name" {}
variable "ssh_inbound_cidr" {
  default = "0.0.0.0/0"
}
