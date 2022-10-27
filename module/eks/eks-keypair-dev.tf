# saedul/module/eks/eks-keypair.tf

resource "aws_key_pair" "eks-keypair-dev" {
    key_name = "eks-keypair-dev"
    public_key = file("../../env/dev/eks-keypair-dev.pub")
}