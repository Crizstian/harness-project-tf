resource "harness_platform_organization" "lab" {
    count       = var.create_org ? 1 : 0
    identifier  = lower(replace(var.harness_platform_organization.name, "-", "_"))
    name        = var.harness_platform_organization.name
    description = var.harness_platform_organization.description
}

resource "harness_platform_project" "project" {
    identifier  = lower(replace(var.harness_platform_project.name, "-", "_"))
    name        = var.harness_platform_project.name
    org_id      = var.create_org ? harness_platform_organization.lab.0.identifier : var.harness_platform_organization.id
    description = var.harness_platform_project.description
}

output "details" {
    value = {
        organization_id = var.create_org ? harness_platform_organization.lab.0.identifier : var.harness_platform_organization.id
        project_id     = harness_platform_project.project.identifier
    }
}