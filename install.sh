#!/bin/bash

export K9S_VERSION="0.27.4"
export K9S_RELEASE_FILE_NAME="k9s_Linux_amd64.tar.gz"
export HELM_VERSION="3.9.3"
export STERN_VERSION="1.25.0"
export LAZYDOCKER_VERSION="0.20.0"
export POPEYE_VERSION="0.11.1"
export TERRAFORM_VERSION="1.5.5"
export TERRAGRUNT_VERSION="0.49.1"
export VELERO_VERSION="1.11.1"

if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
fi
cd /tmp/ || exit

sudo apt update
sudo apt-get install -y \
    apt-transport-https \
    software-properties-common \
    gnupg \
    ca-certificates \
    lsb-release \
    curl \
    wget \
    unzip \
    tar \
    sudo && clear

function install_docker () {
    echo "Installing docker and docker-compose"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install docker-ce docker-compose
    sudo systemctl enable docker
    sudo usermod -aG docker "$USER"
    echo "docker and docker-compose Installation Done"
}

function install_kubectl () {
    echo "Installing kubectl"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check && \
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
}

function install_helm () {
    echo "Installing helm"
    wget -O helm-linux-amd64.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz
    tar -zxvf helm-linux-amd64.tar.gz
    sudo install -o root -g root -m 0755 linux-amd64/helm /usr/local/bin/helm
}

function install_minikube () {
    echo "Installing minikube"
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install -o root -g root -m 0755 minikube-linux-amd64 /usr/local/bin/minikube
}

function install_k9s () {
    echo "Installing k9s"
    if [ -f "/tmp/${K9S_RELEASE_FILE_NAME}" ]; then
        rm -rf "/tmp/${K9S_RELEASE_FILE_NAME}"
    fi
    if [ -f "/usr/local/bin/k9s" ]; then
        rm -rf /usr/local/bin/k9s
    fi
    wget https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/${K9S_RELEASE_FILE_NAME}
    tar -xzvf ${K9S_RELEASE_FILE_NAME} 
    sudo install -o root -g root -m 0755 k9s /usr/local/bin/k9s
}

function install_stern () {
    echo "Installing stern"
    if [ -f "/usr/local/bin/stern" ]; then
        rm -rf /usr/local/bin/stern
    fi
    wget https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_amd64.tar.gz
    tar -xzvf stern_${STERN_VERSION}_linux_amd64.tar.gz 
    rm -rf stern_${STERN_VERSION}_linux_amd64.tar.gz
    sudo install -o root -g root -m 0755 stern /usr/local/bin/stern
}

function install_lazydocker () {
    echo "Installing lazydocker"
    if [ -f "/usr/local/bin/lazydocker" ]; then
        rm -rf /usr/local/bin/lazydocker
    fi
    wget https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz
    tar -xzvf lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz 
    rm -rf lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz
    sudo install -o root -g root -m 0755 lazydocker /usr/local/bin/lazydocker
}

function install_popeye () {
    echo "Installing popeye"
    if [ -f "/usr/local/bin/popeye" ]; then
        rm -rf /usr/local/bin/popeye
    fi
    wget https://github.com/derailed/popeye/releases/download/v${POPEYE_VERSION}/popeye_Linux_x86_64.tar.gz
    tar -xzvf popeye_Linux_x86_64.tar.gz 
    rm -rf popeye_Linux_x86_64.tar.gz
    sudo install -o root -g root -m 0755 popeye /usr/local/bin/popeye
}

function install_terraform () {
    echo "Installing terraform"
    if [ -f "/usr/local/bin/terraform" ]; then
        rm -rf /usr/local/bin/terraform
    fi
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    sudo install -o root -g root -m 0755 terraform /usr/local/bin/terraform
}

function install_terragrunt () {
    echo "Installing terragrunt"
    if [ -f "/usr/local/bin/terragrunt" ]; then
        rm -rf /usr/local/bin/terragrunt
    fi
    wget https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64
    sudo install -o root -g root -m 0755 terragrunt_linux_amd64 /usr/local/bin/terragrunt
}

function install_velero () {
    echo "Installing velero"
    curl -sLo velero.tar.gz https://github.com/vmware-tanzu/velero/releases/download/v${VELERO_VERSION}/velero-v${VELERO_VERSION}-linux-amd64.tar.gz
    tar -xzvf velero.tar.gz
    sudo install -o root -g root -m 0755 velero-v${VELERO_VERSION}-linux-amd64/velero /usr/local/bin/velero
}

function install_awscli () {
    echo "Installing awscli"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
}

function install_azure_cli () {
    echo "Installing azure-cli"
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
}

function install_gcp_cli () {
    echo "Installing gcp-cli"
    curl -fsSL https://sdk.cloud.google.com | bash
}

function install_oci_cli () {
    echo "Installing oci-cli"
    curl -sL https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh | sh
}

function install_all () {
    install_docker
    install_lazydocker
    install_kubectl
    install_helm
    install_minikube
    install_k9s
    install_stern
    install_popeye
    install_terraform
    install_terragrunt
    install_velero
    install_awscli
    install_azure_cli
    install_gcp_cli
    install_oci_cli
}

function main_menu () {

    # Enter the number of the tool you want to install
    echo "Enter the number of the tool you want to install"
    echo "┌────┬─────────────────────┐"
    echo "│S.No│ Tool Name           │"
    echo "├────┼─────────────────────┤"
    echo "│  1 │ install docker      │"
    echo "│  2 │ install lazydocker  │"
    echo "│  3 │ install kubectl     │"
    echo "│  4 │ install helm        │"
    echo "│  5 │ install minikube    │"
    echo "│  6 │ install k9s         │"
    echo "│  7 │ Install stern       │"
    echo "│  8 │ Install popeye      │"
    echo "│  9 │ Install terraform   │"
    echo "│ 10 │ Install terragrunt  │"
    echo "│ 11 │ Install velero      │"
    echo "│ 12 │ Install aws-cli     │"
    echo "│ 13 │ Install azure-cli   │"
    echo "│ 14 │ Install gcp-cli     │"
    echo "│ 15 │ Install oci-cli     │"
    echo "├────┼─────────────────────┤"
    echo "│  0 │ exit                │"
    echo "└────┴─────────────────────┘"
    read -p "Enter your choice: " choice
    case $choice in
        1)
            install_docker && main_menu
            ;;
        2)
            install_lazydocker && main_menu
            ;;
        3)
            install_kubectl && main_menu
            ;;
        4)
            install_helm && main_menu
            ;;
        5)
            install_minikube && main_menu
            ;;
        6)
            install_k9s && main_menu
            ;;
        7)
            install_stern && main_menu
            ;;
        8)
            install_popeye && main_menu
            ;;
        9)
            install_terraform && main_menu
            ;;
        10)
            install_terragrunt && main_menu
            ;;
        11)
            install_velero && main_menu
            ;;
        12)
            install_awscli && main_menu
            ;;
        13)
            install_azure_cli && main_menu
            ;;
        14)
            install_gcp_cli && main_menu
            ;;
        15)
            install_oci_cli && main_menu
            ;;
        ALL)
            install_all
            ;;
        0)
        exit
    esac
}

main_menu
