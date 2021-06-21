resource "aws_instance" "bastion" {
  ami                         = var.AmiLinux[var.region]
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.PublicAZA.id
  vpc_security_group_ids      = [aws_security_group.FrontEnd.id]
  key_name                    = var.key_name
  tags = {
    Name = "bastion"
    env = "dev"
    tier = "api"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  sudo yum update -y && sudo yum update --security

HEREDOC
}
resource "aws_instance" "docker-swarm" {
  ami                         = var.AmiLinux[var.region]
  instance_type               = "t2.small"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.PublicAZA.id
  vpc_security_group_ids      = [aws_security_group.BuildMon.id]
  key_name                    = var.key_name
  tags = {
    Name = "docker"
    env = "dev"
    tier = "build"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  sudo mkdir -p /apps/docker
  sudo yum update -y;sudo yum update --security
  sudo wget https://download.docker.com/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker.repo
  sudo yum install docker-ce git -y
  sudo systemctl enable docker;sudo systemctl start docker;sudo systemctl status docker
  sudo firewall-cmd --permanent --add-port=2376/tcp
  sudo firewall-cmd --permanent --add-port=2377/tcp
  sudo firewall-cmd --permanent --add-port=7946/tcp
  sudo firewall-cmd --permanent --add-port=80/tcp
  sudo firewall-cmd --permanent --add-port=7946/udp
  sudo firewall-cmd --permanent --add-port=4789/udp
  sudo firewall-cmd --reload
  sudo systemctl restart docker
  sudo docker swarm init --advertise-addr 192.168.0.102
  sudo docker info;sudo docker node ls
HEREDOC
}

resource "aws_instance" "DockerLin" {
  ami                         = var.AmiLinux[var.region]
  instance_type               = "t2.small"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.PublicAZA.id
  vpc_security_group_ids      = [aws_security_group.BuildMon.id]
  key_name                    = var.key_name
  tags = {
    name = "hippocrates"
    env = "dev"
    tier = "build"
    app = "docker"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  sudo mkdir -p /apps/web
  sudo yum update -y;sudo yum update --security
  sudo yum install git httpd -y docker-ce 
  sudo systemctl enable docker;sudo systemctl start docker 

HEREDOC
}
resource "aws_instance" "DockerWin" {
  ami                         = var.AmiWin[var.region]
  instance_type               = "t2.small"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.PublicAZA.id
  vpc_security_group_ids      = [aws_security_group.BuildMon.id]
  key_name                    = var.key_name
  tags = {
    Name = "DockerWin"
    env = "dev"
    tier = "build"
    proj = "hippocrates"
  }
  user_data = "pwd"
# <<HEREDOC
#curl.exe -L https://github.com/containerd/containerd/releases/download/v$Version/containerd-$Version-windows-amd64.tar.gz -o containerd-windows-amd64.tar.gz tar.exe xvf .\containerd-windows-amd64.tar.gz
#
#Copy-Item -Path ".\bin\" -Destination "$Env:ProgramFiles\containerd" -Recurse -Force
#cd $Env:ProgramFiles\containerd\
#.\containerd.exe config default | Out-File config.toml -Encoding ascii
#
## Review the configuration. Depending on setup you may want to adjust:
## - the sandbox_image (Kubernetes pause image)
## - cni bin_dir and conf_dir locations
#Get-Content config.toml
#
#Add-MpPreference -ExclusionProcess "$Env:ProgramFiles\containerd\containerd.exe"
#
#.\containerd.exe --register-service
#Start-Service containerd
#
#HEREDOC
#
}

resource "aws_instance" "timeseriesdb" {
  ami                         = var.AmiLinux[var.region]
  instance_type               = "t2.small"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.PrivateAZA.id
  vpc_security_group_ids      = [aws_security_group.Database.id]
  key_name                    = var.key_name
  tags = {
    Name = "TSDB-HIPAA"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  #sleep 180
  #  sudo yum install -y https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
  sudo tee /etc/yum.repos.d/timescale_timescaledb.repo <<EOL
[timescale_timescaledb]
name=timescale_timescaledb
baseurl=https://packagecloud.io/timescale/timescaledb/el/7/\$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/timescale/timescaledb/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
EOL
  sudo yum update -y
  sudo yum install -y timescaledb-postgresql-12
  sudo systemctl enable timescaledb-postgresql-12 ;sudo systemctl start timescaledb-postgresql-12;sudo service timescaledb-postgresql-12 status 
# sudo echo "exclude=postgres-12" >>/etc/yum.conf 
  sudo -u postgres service postgres-12 start

HEREDOC

}

###############################################
# CONSIDER USING A HOSTED AWS SOLUTION LIKE AMP
###############################################
resource "aws_instance" "monitoring" {
  ami                         = var.AmiLinux[var.region]
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.PublicAZA.id
  vpc_security_group_ids      = [aws_security_group.FrontEnd.id]
  key_name                    = var.key_name
  tags = {
    Name = "monitoring"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  sudo yum update -y;sudo yum update --security 
  sudo mkdir /monitoring;cd /monitoring
  sudo yum install git python36-pip.noarch -y 
  sudo useradd -m -s /bin/bash prometheus
  sudo su - prometheus "wget https://github.com/prometheus/prometheus/releases/download/v2.2.1/prometheus-2.2.1.linux-amd64.tar.gz"
  sudo tar -xzvf prometheus-2.2.1.linux-amd64.tar.gz;sudo mv prometheus-2.2.1.linux-amd64/ prometheus/ 
HEREDOC
}

resource "aws_instance" "kitchensinkjenkins" {
  ami                         = var.AmiLinux[var.region]
  instance_type               = "t2.small"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.PublicAZA.id
  vpc_security_group_ids      = [aws_security_group.BuildMon.id]
  key_name                    = var.key_name
  tags = {
    Name = "kitchensinkjenkins"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  sudo yum update -y;sudo yum update --security  -y
  sudo yum install git jenkins -y && sudo systemctl enable jenkins; sudo systemctl start jenkins;sudo systemctl status jenkins
  
HEREDOC
}
