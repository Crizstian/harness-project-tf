#!/bin/bash 

# documentation: https://stackoverflow.com/questions/32163955/how-to-run-shell-script-on-host-from-docker-container

#while true; do eval "$(cat /Users/cristianramirez/Library/Mobile\ Documents/com~apple~CloudDocs/Development/Harness/Labs/harness-tf-setup/contrib/runner/runnerpipe)" &> /Users/cristianramirez/Library/Mobile\ Documents/com~apple~CloudDocs/Development/Harness/Labs/harness-tf-setup/contrib/runner/pipe.log; done

#while true; do eval "$(cat /Users/cristianramirez/Library/Mobile\ Documents/com~apple~CloudDocs/Development/Harness/Labs/harness-tf-setup/contrib/runner/runnerpipe)" &> /Users/cristianramirez/Library/Mobile\ Documents/com~apple~CloudDocs/Development/Harness/Labs/harness-tf-setup/contrib/runner/pipe.log; done


tmux new -d './drone-runner-aws-darwin-amd64 delegate --envfile=.env --pool=pool.yml |& tee /tmp/runner.log'

ps -ax | grep tmux

tail -f /tmp/runner.log