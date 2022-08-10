#!/bin/bash 

function install_requirements {
 cat << 'EOF' > /tmp/install-harness-requirements.sh
    export NONINTERACTIVE=1
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
    brew install wget tmux

    sudo wget https://desktop.docker.com/mac/main/amd64/Docker.dmg
    sudo hdiutil attach Docker.dmg
    sudo /Volumes/Docker/Docker.app/Contents/MacOS/install --accept-license
    sudo hdiutil detach /Volumes/Docker
EOF

    bash /tmp/install-harness-requirements.sh
}


function setup_machine {
    # get the list of installers
    softwareupdate --list-full-installers
    # install the latest version, such as 12.4, 12.3.1, etc.
    softwareupdate --fetch-full-installer --full-installer-version ${VERSION}
    #
    sudo /usr/bin/dscl . -passwd /Users/ec2-user zbun0ok= ${NEW_PASSWORD}
}

function generate_env {
    export IPA=$(ifconfig -l | xargs -n1 ipconfig getifaddr)
    cat << EOF > ~/runner/.env
    DRONE_RUNNER_HOST=$${IPA}
    DRONE_RUNNER_NAME=harness-osx-runner
    DRONE_RUNNER_SECRET=bea26a2221fd8090ea38720fc445eca6
    DRONE_DEBUG=true
    DRONE_TRACE=true
EOF
}

function generate_pool {
    cat << EOF > ~/runner/pool.yml
version: "1"
instances:
- name: ${POOL_NAME}
  default: true
  type: anka   
  pool: 2    
  limit: 100  
  platform:
      os: darwin
      arch: amd64
  spec:
      account:
      username: ${ANKA_VM_USERNAME}
      password: ${ANKA_VM_PASSWORD}
      vm_id: ${VM_NAME}
EOF
}

function setup_runner {
    mkdir ~/runner
    generate_env
    generate_pool
    cd ~/runner
    wget https://github.com/drone-runners/drone-runner-aws/releases/download/v1.0.0-rc.8/drone-runner-aws-darwin-amd64
    chmod +x drone-runner-aws-darwin-amd64
}


function main {
    install_requirements
    setup_machine

    anka --debug create -a /Applications/Install\ macOS\ Monterey.app ${VM_NAME} --ram-size ${RAM_SIZE} --cpu-count ${CPU_COUNT} --disk-size ${DISK_SIZE}

    anka start ${VM_NAME}

    setup_runner
}

main