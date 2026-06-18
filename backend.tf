terraform {
  backend "s3" {
    bucket         = "phase3-tfstate-01"
    key            = "phase1/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "phase3-tflock"
    encrypt        = true
  }
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}
