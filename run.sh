#!/bin/bash -e
set -o pipefail

vagrant up

cd ansible
ansible-playbook provisioning.yml -i hosts



