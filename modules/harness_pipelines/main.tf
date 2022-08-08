variable "harness_platform_project" {}
variable "harness_pipelines" {}

resource "harness_platform_pipeline" "example" {
    identifier = "terraform_generated_pipeline"
    org_id     = var.harness_platform_project.organization_id
    project_id = var.harness_platform_project.id
    name       = "terraform-generated-pipeline"
    yaml       = file("../${path.root}/contrib/pipelines/face-app/pipeline.yml")
}