FROM jenkins/jenkins:lts-jdk21

USER root

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh

# Add bitnami charts
RUN helm repo add bitnami https://charts.bitnami.com/bitnami
RUN helm repo update

# Update APT
RUN apt-get update

# Install nano
RUN apt-get install nano -y

# Install this plugin for 'envsubst' commands used in jenkins pipelines to replace variables.
RUN apt-get install gettext-base -y

USER jenkins