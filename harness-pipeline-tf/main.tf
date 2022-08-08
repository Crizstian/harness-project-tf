data "terraform_remote_state" "bootstrap_project" {
  backend = "local"

  config = {
    path = "../harness-setup-tf/terraform.tfstate"
  }
}

module "project_connectors" {
    source                   = "../modules/harness_connectors"
    # connector setup
    harness_connectors       = local.harness_connectors
    harness_platform_project = data.terraform_remote_state.bootstrap_project.outputs.project

    providers = {
        harness = harness.provisioner
    } 
}

module "project_pipelines" {
    source                   = "../modules/harness_pipelines"
    # connector setup
    harness_pipelines        = {}
    harness_platform_project = data.terraform_remote_state.bootstrap_project.outputs.project

    providers = {
        harness = harness.provisioner
    } 
}

output "details" {
  value = module.project_connectors.connectors
}