# cft-poc-victim (authorized self-test)

Faithful reproduction of the **Cloud Foundation Toolkit** fork-PR RCE class:
a Cloud Build PR trigger with **comment-control disabled** runs an outside
contributor's `terraform apply` (fork-controlled `test/fixtures/`) as a
privileged build SA that holds a Secret Manager secret in `secretEnv`.
Mirrors `terraform-google-modules/*` `build/int.cloudbuild.yaml`.
All resources are the author's own; the "secret" is a canary. Read-only intent.
