terraform {
  required_version = ">= 1.0"
}
resource "null_resource" "converge" {
  provisioner "local-exec" {
    command = "sh collect.sh"
  }
}
