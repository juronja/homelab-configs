# Amazon CLI commands

## EC2

### Provisioning VM

```bash
aws ec2 create-security-group --group-name dilute-right --description "VM specific rules" --vpc-id vpc-0b426cba8b4bc8d93

aws ec2 authorize-security-group-ingress --group-id sg-0953efee322d9a3ae  --protocol tcp --port 22 --cidr 0.0.0.0/0

aws ec2 run-instances --image-id ami-00f07845aed8c0ee7 --count 1 --instance-type t2.micro --key-name id_amazon --security-groups dilute-right --private-dns-name-options HostnameType=resource-name


#--block-device-mappings DeviceName="xvda",VolumeSize=10
```

### Add Security Group ports
```bash
aws ec2 authorize-security-group-ingress --group-id sg-0953efee322d9a3ae  --protocol tcp --port 7474 --cidr 0.0.0.0/0

```