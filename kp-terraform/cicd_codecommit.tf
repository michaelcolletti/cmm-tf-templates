resource "aws_codecommit_repository" "aws-repo" {
  repository_name = "TestRepository"
  description     = "This is the repo for a sample App repository"
}
