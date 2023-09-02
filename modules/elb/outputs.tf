output "elb_address" {
  value = aws_elb.web.dns_name
}