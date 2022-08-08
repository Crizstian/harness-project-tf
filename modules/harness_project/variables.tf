variable "harness_platform_organization" {}
variable "harness_platform_project" {}
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
variable "create_org" {
    default = true
}
variable "create_delegate" {
    default = true
}