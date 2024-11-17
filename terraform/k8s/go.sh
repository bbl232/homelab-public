#!/usr/bin/env bash
terraform init
terraform apply -var-file=inputs.tfvars.json