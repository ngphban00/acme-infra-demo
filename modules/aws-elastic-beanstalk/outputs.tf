output "website_endpoint" {
  value = "http://${aws_elastic_beanstalk_environment.site.cname}"
}

output "app_name" {
  value = aws_elastic_beanstalk_application.site.name
}
