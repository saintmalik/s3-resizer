data "aws_acm_certificate" "cert" {
  provider = aws.us-east-1
  domain   = "*.example.com"
  statuses = ["ISSUED"]
}