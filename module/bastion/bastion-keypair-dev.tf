# saedul/module/bastion/bastion-keypair.tf

resource "aws_key_pair" "bastion-keypair-dev" {
    key_name = "bastion-keypair-dev"
    public_key = file("../../env/dev/bastion-keypair-dev.pub")
}

