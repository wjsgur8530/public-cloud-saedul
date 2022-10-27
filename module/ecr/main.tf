# saedul/module/ecr/main.tf

locals {
  app_name = "${var.env}-ecr"
}

## ecr private repository를 만듭니다
resource "aws_ecr_repository" "cookalone-dev-ecr" {
  name = local.app_name
}