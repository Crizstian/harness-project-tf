variable "harness_platform_project" {}
variable "harness_pipelines" {}
variable "pipelines_folder" {
    default = "contrib/pipelines"
}

# data "template_file" "pipeline" {
#     for_each    = var.harness_pipelines
#     template = file("../${path.root}/${var.pipelines_folder}/${each.key}/${each.value.yaml}")
#     vars = {

#     }
# }

resource "harness_platform_pipeline" "pipeline" {
    for_each    = var.harness_pipelines
    identifier  = lower(replace(each.key, "-", "_"))
    org_id      = each.value.org_id
    project_id  = each.value.project_id
    name        = each.key
    yaml        = file("../${path.root}/${var.pipelines_folder}/${each.key}/${each.value.yaml}")
    description = each.value.description
}