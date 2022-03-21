variable "aws_region" {
  type = string
  description = ""
}

variable "aws_profile" {
  type = string
  description = ""
}

variable "aws_bucket_name" {
  type = string
  description = ""
}

variable "aws_bucket_tags" {
  type = map(string)
  description = ""
}

variable "aws_db_identifier_prefix" {
  type = string
  description = ""
}

variable "aws_db_engine" {
  type = string
  description = ""
}

variable "aws_db_allocated_storage" {
  type = string
  description = ""
}

variable "aws_db_instance" {
  type = string
  description = ""
}

variable "aws_db_name" {
  type = string
  description = ""
}

variable "aws_db_username" {
  type = string
  description = ""
}

variable "aws_db_password" {
  type = string
  description = ""
}

