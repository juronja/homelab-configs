FROM jenkins/jenkins:latest-jdk21

USER root

# Update APT and general tool install
# gettext-base is needed for 'envsubst' commands used in jenkins pipelines to replace variables.
RUN apt-get update && apt-get install nano gettext-base -y

# # Install kubectl
# RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
#     && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
#     && rm kubectl

# # Install AWS CLI
# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
#     && unzip awscliv2.zip \
#     && ./aws/install \
#     && rm -rf awscliv2.zip ./aws

# # Install Terraform
# RUN apt-get update && apt-get install -y lsb-release gnupg curl ca-certificates \
#     && mkdir -p /usr/share/keyrings \
#     && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
#     && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list \
#     && apt-get update \
#     && apt-get install -y terraform

# # Install Helm & Add bitnami charts
# RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
#     && chmod 700 get_helm.sh \
#     && ./get_helm.sh \
#     && rm -rf get_helm.sh \
#     && helm repo add bitnami https://charts.bitnami.com/bitnami \
#     && helm repo update

USER jenkins
