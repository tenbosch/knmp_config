# KNMP
**K**ubernetes **N**GINX **M**ySQL **P**HP (LAMP equivalent)

I created this to learn and demonstrate Kubernetes. I've tried to incorporate many kubernetes features including deployments, configmaps, secrets, services, load balancer, persistent volumes (via NFS) and more.  This is designed to run on-premises.  I've tested this in several environments (kubeadm, Rancher, bare metal the hard way, GKE, and EKS).  I also have a version that runs on Raspberry Pi's.  For that, you'll have to use MariaDB ARM container image (mysql_deployment.yaml) instead of MySQL.  I will continue to expand this to include more features.

The app is a very simple contacts editor. It allows you to view, create, and edit simple contact information. The front-end is a multi-pod load-balanced NGINX web server. The load balancer is MetalLB. The app is written in PHP. The database is MySQL. All files are hosted on a NFS server using persistent volumes, including the PHP code and the MySQL database. Passwords are stored in secrets.

## ToDo's:
- [ ] Create CI/CD pipeline
- [ ] Automatically create the database/table if they doesn't exist.  Good for new deployments and demos
- [ ] Incorporate a function service ([OpenFaas](https://github.com/openfaas/faas)) into this as well.  Exposes the add/edit/delete as API web services.
- [x] Automate/Script the deployment and the destruction of the app (create_app.sh and destroy_app.sh)
- [x] Re-create in it's own namespace. ~~Include MetalLB in this so that MetalLB can be used independently for other applications~~
- [x] Put PHP source code in github - placed in private repository [tenbosch/knmp_code](https://github.com/tenbosch/knmp_code)
- [x] Put config code in github - placed in private repository [tenbosch/knmp_config](https://github.com/tenbosch/knmp_config)

## Steps to re-create the application (Work in progress)
- Deploy Kubernetes via kubeadm
- Clone this repository: ```git clonehttps://github.com/tenbosch/knmp_code.git```
- Change create_app.sh and destroy.sh to executable ```chmod a+x create_app.sh``` and ```chmod a+x destroy_app.sh```
- Install nfs-common on **ALL** of the kubernetes nodes
- This app requires an NFS server - See mysql-pv.yaml and php_pv.yaml for details around NFS server IP and exports
  - Copy PHP code to correct export on NFS server
  - Creation of MySQL database can only happen once the MySQL pod is running
- Deploy everything ```./create_app.sh```
- Create MySQL database if this is the initial build.  This is accomplished by logging into the MySQL pod with the command ```kubectl exec -it <pod name> -n knmp -- /bin/bash```.  Then use the MySQL client to create the database
- Check services ```kubectl get svc -n knmp``` for the IP address of the LoadBalancer service and use that to access the application
- *Add additional steps*

## Database Details
- DB Name: knmp
- Table Name: contacts
- Table description:

| Field | Type | Null | Key | Default | Extra |
|--|--|--|--|--|--|
| contact_id | int | NO | PRI | NULL | auto_increment |
| first | varchar(50) | YES | | NULL |
| last | varchar(50) | YES | | NULL |
| phone | varchar(15) | YES | | NULL |
| email | varchar (50) | YES | | NULL |


SQL statement to create db and table
```
CREATE DATABASE knmp;
USE knmp;
CREATE TABLE contacts (
    contact_id int NOT NULL AUTO_INCREMENT,
    first varchar(50),
    last varchar(50),
    phone varchar(15),
    email varchar(50),
    PRIMARY KEY (contact_id)
);
```

## Custom Docker Container Image for PHP 
This is hosted on Docker Hub under tenbosch/php-pdo

***Dockerfile***
```
FROM php:7-fpm
RUN docker-php-ext-install pdo_mysql
CMD ["php-fpm"]
EXPOSE 9000
```

## Ubiquiti Networks UniFi Router BGP Configuration
The application uses a load balancer which interacts with the Unifi router via BGP.  Below are the steps to run on the router in order to setup BGP. 
**NOTE**: Be sure to add ALL neighbors, possibly including the MASTER node.
```
$ ssh admin@192.168.1.1
$ configure
$ set protocols bgp 64512 parameters router-id 192.168.1.1
$ set protocols bgp 64512 neighbor 192.168.1.235 remote-as 64512
$ set protocols bgp 64512 neighbor 192.168.1.236 remote-as 64512
$ set protocols bgp 64512 neighbor 192.168.1.237 remote-as 64512
$ set protocols bgp 64512 neighbor 192.168.1.238 remote-as 64512
$ commit
$ save
$ exit
$ show ip bgp #Run this after if MetalLB has been deployed
$ exit
```
It may take a minute or so for details to display when running ```show ip```.

## Description of configuration files

| Files | Description |
|--|--|
| create_app.sh | This is a simple script that deploys the application in a specific order |
| destroy_app.sh | This is a simple script that destroys the application |
| metallb.yaml | MetalLB is a simple bare metal load balancer for Kubernetes.  This deployment is specific to this application |
| metallb-configmap.yaml | This is the configuration for metallb.  It has the BGP info for communicating to the router |
| mysql-deployment.yaml | This defines the MySQL database pod |
| mysql-service.yaml | This exposes the MySQL DB to the local containers.  It’s only connected to by the PHP server |
| mysql-pv.yaml | This creates the PV for the MySQL database.  The files are exported on NFS (192.168.1.242/data1/mysql |
| mysql-secret.yaml | This defines the password secret for the MySQL database |
| nginx_deployment.yaml | This defines the NGINX web server pods.  It spawns 3 replicas of the web server and is load balanced |
| nginx_service_lb.yaml | This is the load balancer service for the NGINX web server.  This requires MetalLB to be installed and configured with a router (Unifi).  It does not require any other service |
| nginx_service.yaml (**USE THIS NODEPORT SERVICE INSTEAD IF YOU DON'T WANT LB**) | This exposes the NGINX web server via a standard node port |
| nginx_configmap.yaml | This defines the configuration for the NGINX web server |
| php_deployment.yaml | This defines the php server pod |
| php_service.yaml | This exposes the PHP server to the local containers.  It’s only accessed by the NGINX server |
| php_pv.yaml | This creates the PV for the PHP code.  The files are exported on NFS (192.168.1.242/data1/code) |

## Diagram of the application
![Application Diagram](diagram.png)

## View of the application
![Application View](appview.png)
