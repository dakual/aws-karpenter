#!/bin/bash

set -e

CLUSTER_NAME=karpenter-demo
AWS_DEFAULT_REGION=eu-central-1
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
TEMPOUT=$(mktemp)


# Creating the KarpenterNode IAM Role
# First we need to create the IAM resources using AWS CloudFormation.
curl -fsSL https://karpenter.sh/v0.6.1/getting-started/cloudformation.yaml > $TEMPOUT

aws cloudformation deploy \
  --stack-name Karpenter-${CLUSTER_NAME} \
  --template-file ${TEMPOUT} \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides ClusterName=${CLUSTER_NAME}


# Second, we need to grant access to instances using the profile to connect to the cluster. 
# This command adds the Karpenter node role to your aws-auth configmap, allowing nodes with 
# this role to connect to the cluster.
eksctl create iamidentitymapping \
  --username system:node:{{EC2PrivateDNSName}} \
  --cluster ${CLUSTER_NAME} \
  --arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME} \
  --group system:bootstrappers \
  --group system:nodes
# Now, Karpenter can launch new EC2 instances and those instances can connect to your cluster.

# Create the KarpenterController IAM Role
# Karpenter requires permissions like launching instances. This will create an AWS IAM Role, 
# Kubernetes service account, and associate them using IRSA.
eksctl create iamserviceaccount \
  --cluster ${CLUSTER_NAME} --name karpenter --namespace karpenter \
  --attach-policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/KarpenterControllerPolicy-${CLUSTER_NAME} \
  --approve