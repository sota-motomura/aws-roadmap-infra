output "alb_dns_name" {
  description = "ALBのDNS名(これでアクセス確認ができます)"
  value       = aws_lb.main.dns_name
}

output "rds_endpoint" {
  description = "RDSのエンドポイント"
  value       = aws_db_instance.main.endpoint
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "test_output" {
  value = "PRサイクルのテストです"
}