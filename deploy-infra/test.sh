#!/bin/bash

cd jenkins/deploy-infra/terraform
## TODO verificar caminho terraform
# curl "http://$(/home/ubuntu/terraform output | grep public_dns | awk '{print $2;exit}')" | sed -e "s/\",//g"
uri=$(/home/ubuntu/terraform output | grep public_ip | awk '{print $2;exit}' | sed -e "s/\",//g")

echo $uri

body=$(curl "http://$uri")

regex='Welcome to nginx!'

if [[ $body =~ $regex ]]
then 
    echo "::::: nginx está no ar :::::"
    exit 0
else
    echo "::::: nginx não está no ar :::::"
    exit 1
fi