# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY TERRAFORM CONFIG
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
terraform {
  required_version = ">= 1.1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 4.0"
    }
  }
}


# ----------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ----------------------------------------------------
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}


# ----------------------------------------------------
# DEPLOY VPC
# ----------------------------------------------------
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}


# ----------------------------------------------------
# DEPLOY IAM ROLE
# ----------------------------------------------------
locals {
  taskRole_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

resource "aws_iam_role" "task" {
  path = "/"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : "AssumeRoleECS"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "task" {
  count      = length(local.taskRole_arns)
  role       = aws_iam_role.task.name
  policy_arn = element(local.taskRole_arns, count.index)
}

resource "aws_iam_role_policy" "task" {
  role = aws_iam_role.task.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup"
          ],
          "Resource" : "*"
        }
      ]
  })
}


# ----------------------------------------------------
# DEPLOY NETWORK
# ----------------------------------------------------
data "aws_vpc" "this" {
  default = true
}

data "aws_subnet_ids" "this" {
  vpc_id = data.aws_vpc.this.id
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}


# ----------------------------------------------------
# DEPLOY SECURITY GROUP
# ----------------------------------------------------
resource "aws_security_group" "this" {
  vpc_id = data.aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ----------------------------------------------------
# DEPLOY DATABASE
# ----------------------------------------------------
resource "aws_db_instance" "dmiranda-demo-du" {
  identifier_prefix = var.aws_db_identifier_prefix
  engine            = var.aws_db_engine
  allocated_storage = var.aws_db_allocated_storage
  instance_class    = var.aws_db_instance
  name              = var.aws_db_name
  username          = var.aws_db_username
  password          = var.aws_db_password

  # Don't copy this to your production examples. It's only here to make it quicker to delete this DB.
  skip_final_snapshot = true
}


# ----------------------------------------------------
# DEPLOY S3
# ----------------------------------------------------
resource "aws_s3_bucket" "b" {
  bucket  = var.aws_bucket_name

  tags    = var.aws_bucket_tags
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "public-read"
}

# ----------------------------------------------------
# DEPLOY CLOUDFRONT
# ----------------------------------------------------
#     **** TODO  ****


