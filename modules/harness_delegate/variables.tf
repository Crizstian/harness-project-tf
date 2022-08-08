variable "deploy_docker_delegate" {
    default = false
}
variable "deploy_k8s_delegate" {
    default = false
}
variable "harness_platform_organization_id" {}
variable "harness_platform_api_key" {}
variable "harness_api_endpoint" {
    default = "https://app.harness.io/gateway/ng/api"
}
variable "harness_delegate" {
    default = {
        name                   = ""
        description            = ""
        size                   = ""
        tags                   = ""
        clusterPermissionType  = ""
        customClusterNamespace = ""
    }
}
variable "delegate_manifest" {
    default = "harness-delegate.yml"
}
variable "kubeconfig_path" {
    default = "--kubeconfig ../.kube/config"
}

locals {
    harness_download_k8s_delegate_endpoint    = "${var.harness_api_endpoint}/download-delegates/kubernetes?orgIdentifier=${var.harness_platform_organization_id}"
    harness_download_docker_delegate_endpoint = "${var.harness_api_endpoint}/download-delegates/docker?orgIdentifier=${var.harness_platform_organization_id}"
    default_token                             = "default_token_${var.harness_platform_organization_id}"

    docker_delegates = { for name, delegate in var.harness_delegate.docker: name => {
        docker_manifest = "${name}-${var.delegate_manifest}"
        body            = jsonencode({
            name                   = name
            description            = delegate.description
            size                   = delegate.size
            tags                   = delegate.tags
            tokenName              = can(delegate.tokenName) ? delegate.tokenName : local.default_token 
            clusterPermissionType  = delegate.clusterPermissionType
            customClusterNamespace = delegate.customClusterNamespace
        })
    } if delegate.enable }

    k8s_delegates = { for name, delegate in var.harness_delegate.k8s: name => {
        k8s_manifest = "${name}-${var.delegate_manifest}"
        body            = jsonencode({
            name                   = name
            description            = delegate.description
            size                   = delegate.size
            tags                   = delegate.tags
            tokenName              = can(delegate.tokenName) ? delegate.tokenName : local.default_token 
            clusterPermissionType  = delegate.clusterPermissionType
            customClusterNamespace = delegate.customClusterNamespace
        })
    } if delegate.enable }
}