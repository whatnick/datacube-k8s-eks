#!/bin/bash
export TERRAFORM_VERSION=0.12.18
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_DEFAULT_REGION="us-west-2"
apk update
apk add curl jq python bash ca-certificates git openssl unzip wget
mkdir tmp
cd tmp
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin
cd ..
rm -rf tmp
tflint --version
for a in $(ls examples/stage);
    do 
        cd examples/stage/$a/;
        rm -rf .terraform;
        cp main.tf main.tf.bck;
        cp ../../../.circleci/sample/main.tf.sample main.tf;
        terraform init;
        tflint --module main.tf; 
        mv main.tf.bck main.tf;
        terraform init -backend=false;
        terraform validate; test_result=$?
        if (($test_result != 0)); then
            printf '%s\n' "Terraform Validate Failed" >&2  # write error message to stderr
            exit $test_result                              # or exit $test_result
        fi
        cd ../../../;
    done;