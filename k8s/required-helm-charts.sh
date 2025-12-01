#!/bin/bash

<< comment
pre-requisties:
- kubectl
- helm

comment

######## adding the repo'es to the cluster:
# argocd
helm repo add argo https://argoproj.github.io/argo-helm 

# prometheus-community
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# vpa
helm repo add fairwinds-stable https://charts.fairwinds.com/stable

# aws ingress controller:
helm repo add eks https://aws.github.io/eks-charts

######## installing the helm charts:
# argocd
helm install argocd argo/argo-cd -n argocd --create-namespace 

# monitoring (prometheus and grafana)
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

# vpa-manager
helm install vpa fairwinds-stable/vpa -n vpa --create-namespace

# aws-ingress-controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=wanderlust-cluster \
  --set region=ap-south-1

######## patching the service to NodePort
#Argocd
kubectl patch svc argocd-server -n argocd \
  -p '{"spec": {"type": "NodePort"}}'

#prometheus
kubectl patch svc monitoring-kube-prometheus-prometheus -n monitoring \
  -p '{"spec": {"type": "NodePort"}}'

Grafana
$kubectl patch svc monitoring-grafana -n monitoring \
  -p '{"spec": {"type": "NodePort"}}'

######## initial passwords to login:
# creating the file
> passwords.txt

# ArgoCD password
echo -n "argocd password: " >> passwords.txt && \
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 --decode >> passwords.txt
echo "" >> passwords.txt  # Added newline

# Grafana password
echo -n "grafana password: " >> passwords.txt && \
kubectl -n monitoring get secret monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode >> passwords.txt
echo "" >> passwords.txt  # Added newline



