variable "aws_region" {
  description = "デプロイ先のAWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "db_password" {
  description = "RDSの管理者パスワード"
  type        = string
  sensitive   = true
}