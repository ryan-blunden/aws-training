#!/usr/bin/env bash

# To find the list of Amazon Liunx AMI IDs for each region, go to
# https://aws.amazon.com/amazon-linux-2/release-notes/

echo "[info]: Creating Security Group."

echo "VPC ID: "
read VPC_ID

echo "Security Group name: "
read SECURITY_GROUP_NAME

# Create security group
SECURITY_GROUP_ID=`aws ec2 create-security-group \
    --vpc-id ${VPC_ID} \
    --description "EC2 Automation Security Group" \
    --group-name ${SECURITY_GROUP_NAME} | jq -r .GroupId`
aws ec2 create-tags --resources ${SECURITY_GROUP_ID} --tags "Key=Name,Value=${SECURITY_GROUP_NAME}"

echo "[info]: Applying Ingress rules."

echo "IP Address (CIDR format) to restrict SSH access:"
read YOUR_IP

# Create ingress rules (port 80, 443 and port 22)
# Note: Yes, we could combine these into one command but this is for learning purposes.

aws ec2 authorize-security-group-ingress \
    --group-id ${SECURITY_GROUP_ID} \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0


aws ec2 authorize-security-group-ingress \
    --group-id ${SECURITY_GROUP_ID} \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id ${SECURITY_GROUP_ID} \
    --protocol tcp \
    --port 22 \
    --cidr ${YOUR_IP}

aws ec2 authorize-security-group-egress \
    --group-id ${SECURITY_GROUP_ID} \
    --protocol tcp \
    --port 0-65535 \
    --cidr 0.0.0.0/0
    

echo "[info]: Configuring EC2 instance."

echo "Instance name: "
read INSTANCE_NAME

echo "Instance type: "
read INSTANCE_TYPE

echo "AMI ID: "
read AMI_ID

echo "Subnet ID: "
read SUBNET_ID

echo "Key Pair name (must already exist): "
read KEY_PAIR_NAME

echo -e "[info]: Making request to launch instance. Result payload will display once complete.\n"

EC2_RESULT=`aws ec2 run-instances \
    --image-id ${AMI_ID} \
    --count 1 \
    --instance-type ${INSTANCE_TYPE} \
    --key-name ${KEY_PAIR_NAME} \
    --user-data file://bin/install-docker-amazon-linux.sh \
    --subnet-id ${SUBNET_ID} \
    --security-group-ids ${SECURITY_GROUP_ID} \
    --associate-public-ip-address`

RESULT=$?

echo ${EC2_RESULT} | jq

if [ ${RESULT} != 0 ]; then
    echo -e "[error]: Unable to create EC2 instance. Cleaning up security group.\n"
    aws ec2 delete-security-group --group-id ${SECURITY_GROUP_ID}
    exit ${RESULT}
fi


echo "[info]: Setting instance name."

INSTANCE_ID=`echo ${EC2_RESULT} | jq -r .Instances[0].InstanceId`
aws ec2 create-tags --resources ${INSTANCE_ID} --tags "Key=Name,Value=${INSTANCE_NAME}"

echo "[info]: Finished."
