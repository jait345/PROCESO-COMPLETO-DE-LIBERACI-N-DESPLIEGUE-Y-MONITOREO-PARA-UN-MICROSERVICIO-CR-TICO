terraform {
  required_version = ">= 1.5.0"
}

resource "null_resource" "create_kind" {
  provisioner "local-exec" {
    command = "bash infra/terraform/scripts/create_kind.sh"
  }
}
