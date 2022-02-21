#!/bin/bash

#############################
# Create The Cluster in GKE #
#############################
# helm 3 is being used for deploying Helm based Jenkins package

gcloud auth login

CLUSTER_NAME=jenkins

ZONE=europe-west4-a

MACHINE_TYPE=e2-medium

gcloud container clusters \
    create $CLUSTER_NAME \
    --zone $ZONE \
    --machine-type $MACHINE_TYPE \
    --enable-autoscaling \
    --num-nodes 1 \
    --max-nodes 1 \
    --min-nodes 1

kubectl create clusterrolebinding \
    cluster-admin-binding \
    --clusterrole cluster-admin \
    --user $(gcloud config get-value account)


#Latest version of nginx controller
kubectl apply \
    -f deploy-ingress-nginx.yml

# Wait to make sure that LB IP is ready
echo "Retrieving LB IP....."
for i in $(seq 1 60); do
    echo -ne "."
    sleep 1
done
echo

# Retrieve ingress ip
LB_IP=$(kubectl -n ingress-nginx\
    get svc ingress-nginx-controller \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}"); echo $LB_IP
