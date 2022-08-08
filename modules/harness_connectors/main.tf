variable "harness_platform_project" {}
variable "harness_connectors" {}

locals {
    github_connectors = { for name, details in var.harness_connectors.github : "${name}_github_connector" => {
        description        = details.description
        connection_type    = details.connection_type
        url                = details.url
        delegate_selectors = details.delegate_selectors
        validation_repo    = details.validation_repo
        org_id             = details.org_id == "" ? var.harness_platform_project.organization_id : details.org_id
        project_id         = var.harness_platform_project.id
        credentials = {
            http = {
                username  = details.credentials.http.username
            }
        }
    } if details.enable }

    k8s_connectors = { for name, details in var.harness_connectors.k8s : "${name}_k8s_connector" => {
        enable             = details.enable
        description        = details.description
        tags               = details.tags
        delegate_selectors = details.delegate_selectors
        org_id             = details.org_id == "" ? var.harness_platform_project.organization_id : details.org_id
        project_id         = var.harness_platform_project.id
    } if details.enable }

    docker_connectors = { for name, details in var.harness_connectors.docker : "${name}_docker_connector" => {
        enable             = details.enable
        description        = details.description
        tags               = details.tags
        delegate_selectors = details.delegate_selectors
        type               = details.type
        url                = details.url
        org_id             = details.org_id == "" ? var.harness_platform_project.organization_id : details.org_id
        project_id         = var.harness_platform_project.id
        credentials = {
            username =  details.credentials.username
        }
       
    } if details.enable }

    github_secrets = { for name, details in var.harness_connectors.github : "${name}_github_connector_secret" => {
        secret      = details.credentials.http.token_ref
        description = details.description
        org_id      = details.org_id == "" ? var.harness_platform_project.organization_id : details.org_id
        project_id  = var.harness_platform_project.id
    } if details.enable }

    docker_secrets = { for name, details in var.harness_connectors.docker : "${name}_docker_connector_secret" => {
        secret      = details.credentials.password_ref
        description = details.description
        org_id      = details.org_id == "" ? var.harness_platform_project.organization_id : details.org_id
        project_id  = var.harness_platform_project.id
    } if details.enable }

    secrets = merge(local.github_secrets, local.docker_secrets)
}

resource "harness_platform_secret_text" "harness_secrets" {
    for_each                  = local.secrets
    identifier                = "${replace(lower(each.key), "-", "_")}"
    name                      = "${each.key}"
    description               = each.value.description
    secret_manager_identifier = "harnessSecretManager"
    value_type                = "Inline"
    value                     = each.value.secret
    org_id                    = each.value.org_id
    project_id                = each.value.project_id

    lifecycle {
        ignore_changes = [
            value,
        ]
    }
}

resource "harness_platform_connector_github" "connector" {
    for_each           = local.github_connectors
    identifier         = replace(lower(each.key), "-", "_")
    name               = each.key
    description        = each.value.description
    url                = each.value.url
    connection_type    = each.value.connection_type
    validation_repo    = each.value.validation_repo
    delegate_selectors = each.value.delegate_selectors
    org_id             = each.value.org_id
    project_id         = each.value.project_id
    credentials {
        http {
            username  = each.value.credentials.http.username
            token_ref = harness_platform_secret_text.harness_secrets["${each.key}_secret"].id
        }
    }
}

resource "harness_platform_connector_docker" "registry" {
    for_each           = local.docker_connectors
    identifier         = replace(lower(each.key), "-", "_")
    name               = each.key
    description        = each.value.description
    tags               = each.value.tags
    delegate_selectors = each.value.delegate_selectors
    project_id         = each.value.project_id
    org_id             = each.value.org_id
    type               = each.value.type
    url                = each.value.url
    
    credentials {
        username     = each.value.credentials.username
		password_ref = harness_platform_secret_text.harness_secrets["${each.key}_secret"].id
    }
}

resource "harness_platform_connector_kubernetes" "inheritFromDelegate" {
    for_each           = local.k8s_connectors
    identifier         = replace(lower(each.key), "-", "_")
    name               = each.key
    description        = each.value.description
    tags               = each.value.tags
    org_id             = each.value.org_id
    project_id         = each.value.project_id
    
    inherit_from_delegate {
        delegate_selectors = each.value.delegate_selectors
    }
}

output "connectors" {
    value = {
        github_connectors = local.github_connectors
        k8s_connectors = local.k8s_connectors
        docker_connectors = local.docker_connectors
    }
}