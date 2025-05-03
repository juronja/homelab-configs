FROM jenkins/jenkins:lts-jdk21

USER root

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install eksctl
RUN ARCH=amd64 && PLATFORM=$(uname -s)_$ARCH
RUN curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
RUN tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
RUN mv /tmp/eksctl /usr/local/bin

# Install AWS IAM Authenticator
RUN curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
RUN chmod +x ./aws-iam-authenticator && mv ./aws-iam-authenticator /usr/local/bin

USER jenkins