resource "aws_key_pair" "bastion-keypair" {
    key_name = "bastion-keypair"
    public_key = file("../../aws/secret/bastion-keypair.pub")
}

resource "aws_key_pair" "eks-keypair" {
    key_name = "eks-keypair"
    public_key = file("../../aws/secret/eks-keypair.pub")
}