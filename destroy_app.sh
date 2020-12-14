#!/bin/bash

# Delete NGINX web server and service
echo -e "\nDeleting NGINX..."
kubectl delete -f nginx_service_lb.yaml -n knmp
kubectl delete -f nginx_deployment.yaml -n knmp
kubectl delete -f nginx_configmap.yaml -n knmp

# Delete PHP Server and Service
echo -e "\nDeleting PHP..."
kubectl delete -f php_service.yaml -n knmp
kubectl delete -f php_deployment.yaml -n knmp
kubectl delete -f php_pv.yaml -n knmp

# Delete MySql Deployment and Service
echo -e "\nDeleting MySQL..."
kubectl delete -f mysql-service.yaml -n knmp
kubectl delete -f mysql-deployment.yaml -n knmp
kubectl delete -f mysql-pv.yaml -n knmp
kubectl delete -f mysql-secret.yaml -n knmp

# Delete namespace
echo -e "\nDeleting namespace..."
kubectl delete -f knmp.yaml

# Delete MetalLB Loadbalancer
echo -e "\nDeleting MetalLB Loadbalancing services..."
kubectl delete -f metallb.yaml
kubectl delete -f metallb-configmap.yaml

# Delete kubernetes user
# echo -e "\nDeleting User..."
# contactcs_user_rb.yaml
