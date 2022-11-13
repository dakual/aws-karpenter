Create EKS cluster for Karpenter
```sh
eksctl create cluster -f cluster.yaml
```

Connecting cluster
```sh
aws eks update-kubeconfig --region eu-central-1 --name karpenter-demo
```

Creating the KarpenterNode IAM Role
```sh
sh role.sh
```

```sh
# https://aws.amazon.com/tr/premiumsupport/knowledge-center/eks-kubernetes-object-access-error/
KUBE_EDITOR="nano" kubectl edit configmap aws-auth -n kube-system

mapUsers: |
  - userarn: arn:aws:iam::632296647497:root
    groups:
    - system:masters
```

Create the EC2 Spot Service Linked Role
This step is only necessary if this is the first time you’re using EC2 Spot in this account.
```sh
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
```

Install Karpenter using Helm
```sh
helm repo add karpenter https://charts.karpenter.sh
helm repo update
helm upgrade --install karpenter karpenter/karpenter --namespace karpenter \
  --create-namespace --set serviceAccount.create=false --version v0.6.1 \
  --set controller.clusterName=karpenter-demo \
  --set controller.clusterEndpoint=$(aws eks describe-cluster --name karpenter-demo --query "cluster.endpoint" --output json) \
  --set aws.defaultInstanceProfile=KarpenterNodeInstanceProfile-karpenter-demo \
  --wait
```

Check the Karpenter resources on K8S
```sh
kubectl get all -n karpenter
```

Configure Karpenter provisioner
```sh
kubectl apply -f provisioner.yaml 
```

Karpenter Node Autoscaling Test
```sh
kubectl apply -f deployment.yaml
kubectl scale deployment test-deployment --replicas 5
```

Karpenter's logs.
```sh
kubectl logs -f -n karpenter $(kubectl get pods -n karpenter -l karpenter=controller -o name)
kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter -c controller
```


```sh
eksctl get nodegroup --cluster=karpenter-demo
eksctl delete nodegroup --cluster=karpenter-demo --name=karpenter-demo-ng --disable-eviction
eksctl create nodegroup --config-file=cluster.yaml

kubectl delete deployment hello-kube

# If you delete a node with kubectl, Karpenter will gracefully cordon, drain, and shutdown the corresponding instance.
kubectl delete node <NODE-NAME>
```

Cleanup
```sh
helm uninstall karpenter --namespace karpenter
eksctl delete iamserviceaccount --cluster karpenter-demo --name karpenter --namespace karpenter
aws cloudformation delete-stack --stack-name Karpenter-karpenter-demo
aws ec2 describe-launch-templates \
    | jq -r ".LaunchTemplates[].LaunchTemplateName" \
    | grep -i Karpenter-karpenter-demo \
    | xargs -I{} aws ec2 delete-launch-template --launch-template-name {}
eksctl delete cluster -f cluster.yaml
```


With Terraform
```sh
terraform init
terraform apply --auto-apply
```