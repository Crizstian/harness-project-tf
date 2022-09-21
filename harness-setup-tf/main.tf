data "terraform_remote_state" "harness_anka" {
    count   = var.aws_anka_enabled ? 1 : 0
    backend = "local"

    config = {
        path = "../harness-anka-tf/terraform.tfstate"
    }
}

module "bootstrap_project" {
    source                        = "../modules/harness_project"
    # project setup
    create_org                    = false
    harness_platform_organization = var.harness_platform_organization 
    harness_platform_project      = var.harness_platform_project
    
    providers = {
        harness = harness.provisioner
    } 
}

module "bootstrap_delegates" {
    source                           = "../modules/harness_delegate"
    # delegate setup
    harness_delegate                 = local.harness_delegate
    harness_platform_api_key         = var.harness_platform_api_key
    harness_platform_organization_id = module.bootstrap_project.details.organization_id
    aws_anka_enabled                 = var.aws_anka_enabled
}

output "project" {
    value = {
        id               = module.bootstrap_project.details.project_id
        organization_id  = module.bootstrap_project.details.organization_id
        harness_delegate = local.harness_delegate
    }
}