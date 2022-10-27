# saedul/module/bastion/main.tf

############   Create Bastion Host   ################
resource "aws_security_group" "bastion-sg" {
  name = "bastion-sg"
  vpc_id = var.vpc

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = var.my-ip-address # 보안 | 내 PC에서 SSH 접속하므로 내 PC IP 넣는게 맞음.
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "bastion-sg"
  }
}

resource "aws_instance" "bastion" {
  ami = "ami-0e6329e222e662a52"
  instance_type = "t2.micro"
  subnet_id     = element(var.public-subnet, 0)
  key_name = aws_key_pair.bastion-keypair-dev.key_name
  vpc_security_group_ids = [
    aws_security_group.bastion-sg.id
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = "true"
  }

  tags = { 
    "Name" = "bastionHost"
  }
}

resource "aws_eip" "ip" {
  instance = aws_instance.bastion.id
  vpc      = true

  tags = {
    Name = "bastion_eip"
  }
}