provider "aws" {
  region = "sa-east-1"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com" # outra opção "https://ifconfig.me"
}

resource "aws_instance" "ec2-jenkins_nginx" {
  ami                         = "ami-054a31f1b3bf90920" # data.aws_ami.ubuntu.id
  subnet_id                   = "subnet-03575db38d50158f1"
  instance_type               = "t2.medium"
  key_name                    = "key-dev-ernane-aws"
  associate_public_ip_address = true

  root_block_device {
    encrypted   = true
    volume_size = 16
  }

  tags = {
    Name = "ec2-jenkins_nginx-${count.index}"
  }

  vpc_security_group_ids = [aws_security_group.jenkins_nginx.id]

}

resource "aws_security_group" "jenkins_nginx" {
  name        = "acessos"
  description = "acessos inbound traffic"
  vpc_id      = "vpc-002bf2946d3dba700"

  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"] #${chomp(data.http.myip.body)}/32"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = null,
      security_groups : null,
      self : null
    },    
    {
      description      = "SSH from VPC"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null,
      security_groups : null,
      self : null
    },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = [],
      prefix_list_ids  = null,
      security_groups : null,
      self : null,
      description : "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "jenkins-nginx-lab"
  }
}

output "jenkins_nginx" {
  value = [
    "jenkins_nginx",
    "id: ${aws_instance.ec2-jenkins_nginx.id}",
    "private: ${aws_instance.ec2-jenkins_nginx.private_ip}",
    "public: ${aws_instance.ec2-jenkins_nginx.public_ip}",
    "public_dns: ${aws_instance.ec2-jenkins_nginx.public_dns}",
    "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.ec2-jenkins_nginx.public_dns}"
  ]
}

# terraform refresh para mostrar o ssh
