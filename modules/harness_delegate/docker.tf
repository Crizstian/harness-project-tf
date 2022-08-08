resource "null_resource" "download_docker_delegate_manifest" {
    for_each = local.docker_delegates

    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        working_dir = path.root
        command     = <<-EOT
        curl -o ../contrib/manifests/${each.value.docker_manifest} \
        --location \
        --request POST '${local.harness_download_docker_delegate_endpoint}' \
        --header 'Content-Type: application/json' \
        --header 'x-api-key: ${var.harness_platform_api_key}' --data-raw '${each.value.body}'
        EOT
    }
}

resource "null_resource" "deploy_docker_delegate" {
    for_each   = local.docker_delegates
    depends_on = [null_resource.download_docker_delegate_manifest]

    provisioner "local-exec" {
        working_dir = path.root
        command     = "docker-compose -f ../contrib/manifests/${each.value.docker_manifest} up -d"
    }
}