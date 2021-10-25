#!/bin/bash

cd jenkins/deploy-infra/terraform
terraform init
terraform apply -auto-approve

echo "Aguardando criação de maquinas ..."
sleep 10 # 10 segundos

echo $"[ec2-dev-img-jenkins]" > ../ansible/hosts # cria arquivo
echo "$(/home/ubuntu/terraform output | grep public_dns | awk '{print $2;exit}')" | sed -e "s/\",//g" >> ../ansible/hosts # captura output faz split de espaco e replace de ",

echo "Aguardando criação de maquinas ..."
sleep 10 # 10 segundos

cd ../ansible

echo "Executando ansible ::::: [ ansible-playbook -i hosts provisionar.yml -u ubuntu --private-key /var/lib/jenkins/.ssh/id_rsa ]"
## TODO verificar caminho da chave privada no usuário jenkins
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts provisionar.yml -u ubuntu --private-key /var/lib/jenkins/.ssh/id_rsa
# ansible-playbook -i hosts provisionar.yml -u ubuntu --private-key /home/ubuntu/treinamentoItau