#!/bin/bash

# Create kubernetes user
# contactcs_user_rb.yaml

# Create MetalLB Loadbalancer
echo -e "\nCreate MetalLB Loadbalancing services..."
kubectl create -f metallb.yaml
kubectl create -f metallb-configmap.yaml

# Create namespace
echo -e "\nCreating namespace..."
kubectl create -f knmp.yaml

# Create MySql Deployment and Service
echo -e "\nCreating MySQL..."
kubectl create -f mysql-secret.yaml -n knmp
kubectl create -f mysql-pv.yaml -n knmp
kubectl create -f mysql-deployment.yaml -n knmp
kubectl create -f mysql-service.yaml -n knmp

# Create PHP Server and Service
echo -e "\nCreating PHP..."
kubectl create -f php_pv.yaml -n knmp
kubectl create -f php_deployment.yaml -n knmp
kubectl create -f php_service.yaml -n knmp

# Create NGINX web server and service
echo -e "\nCreating NGINX..."
kubectl create -f nginx_configmap.yaml -n knmp
kubectl create -f nginx_deployment.yaml -n knmp
# The following line creates a LB service.  This only works if MetalLB is deployed correctly
kubectl create -f nginx_service_lb.yaml -n knmp
# If you don't deploy MetalLB, then use this service instead and comment out the line above
# kubectl create -f nginx_service.yaml -n knmp

# Display pod status
echo -e "\nPod Status:"
kubectl get pod -n knmp
