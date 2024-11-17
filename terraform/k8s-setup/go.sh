#!/usr/bin/env bash
terraform init
terraform apply
terraform output -json > ../k8s/inputs.tfvars.json