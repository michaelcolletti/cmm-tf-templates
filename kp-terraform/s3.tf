resource "aws_s3_bucket" "monitor" {
  bucket = "mon-log-bucket"
  acl    = "private"

  tags = {
    Name        = "Monitoring Data"
    Environment = "Dev"
  }
  versioning {
    enabled = false
  }
}
resource "aws_s3_bucket" "traces" {
  bucket = "traces-bucket"
  acl    = "private"

  tags = {
    Name        = "Observability and Trace Data"
    Environment = "Dev"
    Ephemeral = "true"
  }
  versioning {
    enabled = false
  }
}
resource "aws_s3_bucket" "templates" {
  bucket = "template-bucket"
  acl    = "private"

  tags = {
    Name        = "Templates and Stacks"
    Environment = "Dev"
    Ephemeral = "false"
  }
  versioning {
    enabled = true
  }
}
resource "aws_s3_bucket" "logs" {
  bucket = "logs-bucket"
  acl    = "private"

  tags = {
    Name        = "Log Data"
    Environment = "Dev"
  }
  versioning {
    enabled = false
  }

}
