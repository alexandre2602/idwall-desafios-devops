#!/bin/bash

sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf

mkdir -p /var/lib/mysql
mkdir -p /var/www

kubectl create secret generic mysql-pass --from-literal=password=j7XG85ETxwJweYJH

echo 'deploy database'
kubectl create -f /usr/local/bin/application/database/mysql-pvc-claim.yml
kubectl create -f /usr/local/bin/application/database/mysql-pv-claim.yml
kubectl create -f /usr/local/bin/application/database/wordpress-mysql-service.yml
kubectl create -f /usr/local/bin/application/database/wordpress-mysql-deployment.yml

echo 'deploy aplication web'
kubectl create -f /usr/local/bin/application/web/wordpress-pvc-claim.yml
kubectl create -f /usr/local/bin/application/web/wordpress-pv-claim.yml
kubectl create -f /usr/local/bin/application/web/wordpress-service.yml
kubectl create -f /usr/local/bin/application/web/wordpress-deployment.yml
