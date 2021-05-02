provider "aws" {
  version = "~> 2.31"
}

terraform {
  required_version = "~> 0.12.18"

  backend "s3" {
    region = "{{ .Env.AWS_DEFAULT_REGION }}"
    bucket = "{{ .Env.TERRAFORM_REMOTE_STATE_S3 }}"
    key    = "{{ .Env.DEPLOY_ENV }}/terraform.tfstate"
  }
}