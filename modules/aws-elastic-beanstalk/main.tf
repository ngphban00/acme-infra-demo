resource "random_id" "suffix" {
  byte_length = 4
}

# --- Render HTML + package into zip ---

resource "local_file" "index" {
  content = templatefile(var.index_html_path, {
    environment = var.environment
    cost_center = var.cost_center
    owner       = var.owner
  })
  filename = "${path.module}/.build/index.html"
}

resource "local_file" "procfile" {
  content  = "web: python3 -m http.server 5000\n"
  filename = "${path.module}/.build/Procfile"
}

data "archive_file" "site" {
  type        = "zip"
  source_dir  = "${path.module}/.build"
  output_path = "${path.module}/.build/site.zip"
  depends_on  = [local_file.index, local_file.procfile]
}

# --- S3 bucket for EB application versions ---

resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.name}-${var.environment}-eb-${random_id.suffix.hex}"
  tags   = local.common_tags
}

resource "aws_s3_object" "bundle" {
  bucket = aws_s3_bucket.artifacts.id
  key    = "site-${data.archive_file.site.output_md5}.zip"
  source = data.archive_file.site.output_path
  etag   = data.archive_file.site.output_md5
  tags   = local.common_tags
}

# --- IAM: EC2 instance profile ---

resource "aws_iam_role" "ec2" {
  name = "${var.name}-${var.environment}-eb-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_web_tier" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name}-${var.environment}-eb-ec2-profile"
  role = aws_iam_role.ec2.name
  tags = local.common_tags
}

# --- IAM: EB service role ---

resource "aws_iam_role" "service" {
  name = "${var.name}-${var.environment}-eb-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "elasticbeanstalk.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "service_health" {
  role       = aws_iam_role.service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "service_managed_updates" {
  role       = aws_iam_role.service.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

# --- Elastic Beanstalk ---

data "aws_elastic_beanstalk_solution_stack" "python" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux 2023 .* running Python 3\\.12$"
}

resource "aws_elastic_beanstalk_application" "site" {
  name        = "${var.name}-${var.environment}"
  description = "${var.name} - ${var.environment}"
  tags        = local.common_tags
}

resource "aws_elastic_beanstalk_application_version" "site" {
  name        = "v-${data.archive_file.site.output_md5}"
  application = aws_elastic_beanstalk_application.site.name
  bucket      = aws_s3_bucket.artifacts.id
  key         = aws_s3_object.bundle.id
  tags        = local.common_tags
}

resource "aws_elastic_beanstalk_environment" "site" {
  name                = "${var.name}-${var.environment}"
  application         = aws_elastic_beanstalk_application.site.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.python.name
  version_label       = aws_elastic_beanstalk_application_version.site.name
  tags                = local.common_tags

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.service.arn
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ec2.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PORT"
    value     = "5000"
  }
}

locals {
  common_tags = {
    application = var.name
    environment = var.environment
    cost_center = var.cost_center
    owner       = var.owner
    managed_by  = "terraform"
  }
}
