#!/bin/bash
export TERRAFORM_VERSION=0.12.20
export AWS_ACCESS_KEY_ID="anaccesskey" # TODO: Use a CI account for this
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
        echo "====================================";
        echo "Testing Example $a";
        echo "====================================";
        rm -rf .terraform;
        cp main.tf main.tf.bck;
        cp ../../../.circleci/sample/main.tf.sample main.tf;
        terraform init;
        tflint --module main.tf; test_result=$?
        if (($test_result != 0)); then
            printf '%s\n' "TFLint Failed" >&2  # write error message to stderr
            exit $test_result                  # or exit $test_result
        fi
        mv main.tf.bck main.tf;
        rm -rf .terraform;
        terraform init -backend=false;
        terraform validate; test_result=$?
        if (($test_result != 0)); then
            printf '%s\n' "Terraform Validate Failed" >&2  # write error message to stderr
            # exit $test_result                            # TODO: Make this work without STS
        fi
        cd ../../../;
    done;