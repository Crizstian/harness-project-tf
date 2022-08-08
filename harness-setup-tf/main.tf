module "bootstrap_project" {
    source                        = "../modules/harness_project"
    # project setup
    create_org                    = true
    harness_platform_organization = var.harness_platform_organization 
    harness_platform_project      = var.harness_platform_project
    
    providers = {
        harness = harness.provisioner
    } 
}

module "bootstrap_delegates" {
    source                           = "../modules/harness_delegate"
    # delegate setup
    harness_delegate                 = var.harness_delegate
    harness_platform_api_key         = var.harness_platform_api_key
    harness_platform_organization_id = module.bootstrap_project.details.organization_id
}

output "project" {
    value = {
        id               = module.bootstrap_project.details.project_id
        organization_id  = module.bootstrap_project.details.organization_id
        harness_delegate = var.harness_delegate
    }
}