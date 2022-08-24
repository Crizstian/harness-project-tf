pipeline:
  name: terraform-generated-pipeline
  identifier: terraform_generated_pipeline
  projectIdentifier: ios_face_app_sample
  orgIdentifier: cristian_lab_org
  tags: {}
  properties:
    ci:
      codebase:
        connectorRef: crizstian_github_connector
        repoName: "ios-sample-app "
        build: <+input>
  stages:
    - stage:
        name: init
        identifier: init
        type: CI
        spec:
          cloneCodebase: true
          infrastructure:
            type: VM
            spec:
              type: Pool
              spec:
                poolName: osx-anka
                os: MacOS
          execution:
            steps:
              - step:
                  type: Run
                  name: hello world
                  identifier: hello_world
                  spec:
                    shell: Bash
                    command: echo "hello world"
                  description: testing step
                  failureStrategies: []


pipeline_desc = {
  appname = {
    project_id
    org_id
    connectorRef
    repoName
    stage = {
      name = {
        cloneCodebase
        infrastructure = {
          type
          spec
          poolName
          os
        }
        execution = {
          step = {
            type
            name
            command
            description
          }
        }
      }
    }
  }
}

pipeline:
  name: ${PIPELINE_NAME}
  identifier: ${PIPELINE_IDENTIFIER}
  projectIdentifier: ${PROJECT_IDENTIFIER}
  orgIdentifier: ${ORG_IDENTIFIER}
  tags: {}
  properties:
    ci:
      codebase:
        connectorRef: ${CONNECTOR_REF}
        repoName: ${REPO_NAME}
        build: <+input>
  stages:
    - stage:
        name: ${STAGE_NAME}
        identifier: ${STAGE_IDENTIFIER}
        type: CI
        spec:
          cloneCodebase: ${CLONE_CODEBASE}
          infrastructure:
            type: ${INFRASTRUCTURE_TYPE}
            spec:
              type: ${INFRASTRUCTURE_SPEC}
              spec:
                poolName: ${INFRASTRUCTURE_POOL_NAME}
                os: ${INFRASTRUCTURE_OS}
          execution:
            steps:
              - step:
                  type: ${STEP_TYPE}
                  name: ${STEP_NAME}
                  identifier: ${STEP_IDENTIFIER}
                  spec:
                    shell: Bash
                    command: ${STEP_COMMAND}
                  description: ${STEP_DESCRIPTION}
                  failureStrategies: []
