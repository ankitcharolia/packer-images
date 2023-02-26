#!/bin/bash

export AWS_PROFILE=aws-stage
# export AWS_PROFILE=aws-prod

PACKER=$(which packer)
[[ -z ${PACKER} ]] &&  echo 'packer command not found in the search path. exiting...' && exit 1

packer init .
packer fmt .
packer validate .
packer build -var-file="ubuntu-stage.pkrvars.hcl" aws-ubuntu.pkr.hcl