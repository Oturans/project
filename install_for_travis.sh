
#!/bin/bash
set -e

#Install Terraform
curl -O https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
sudo unzip terraform_0.12.24_linux_amd64.zip -d /usr/local/bin
terraform --version

# install tflint
curl https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# install helm
- curl https://kubernetes-helm.storage.googleapis.com/helm-v2.13.1-linux-amd64.tar.gz | tar zx
- sudo mv linux-amd64/helm /usr/bin/
- helm version --client
