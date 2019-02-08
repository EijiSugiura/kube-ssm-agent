FROM amazonlinux:2

LABEL maintainer "Yusuke Kuoka <ykuoka@gmail.com>"

RUN mkdir dsa && cd dsa && \
    curl -L https://app.deepsecurity.trendmicro.com/software/agent/amzn2/x86_64/ -o agent.rpm && \
    yum -y agent.rpm && \
    touch /etc/use_dsa_with_iptables && \
    /opt/ds_agent/dsa_control -r && \
    /opt/ds_agent/dsa_control -a dsm://agents.deepsecurity.trendmicro.com:443/ "tenantID:XXXXXXXX" "token:XXXXXXXX" "policy:XXXXXXXX" && \
    cd .. && \
    rm -rf dsa

RUN yum update -y && \
    yum install -y systemd curl tar sudo && \
    yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

RUN mkdir work && cd work && \
    curl -L https://dl.k8s.io/v1.11.5/kubernetes-client-linux-amd64.tar.gz -o temp.tgz && \
    tar zxvf temp.tgz && \
    mv kubernetes/client/bin/kubectl /usr/bin/kubectl && \
    cd .. && \
    rm -rf work

RUN curl -L https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64 -o /usr/bin/aws-iam-authenticator && \
    chmod +x /usr/bin/aws-iam-authenticator

#Failed to get D-Bus connection: Operation not permitted
#RUN systemctl status amazon-ssm-agent

WORKDIR /opt/amazon/ssm/
CMD ["amazon-ssm-agent", "start"]
