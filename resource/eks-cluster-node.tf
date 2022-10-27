# 여기서는 EC2관련 IAM Role을 생성해주고
resource "aws_iam_role" "worker-iam-role" {
  name               = "${local.cluster_name}-managed-worker-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = {
    Name        = "${local.cluster_name}-worker-node-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-iam-role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-iam-role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-iam-role.name
}

# 마지막으로 Node Group을 생성한다.
resource "aws_eks_node_group" "worker-node-group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${local.cluster_name}-worker-node"
  node_role_arn   = aws_iam_role.worker-iam-role.arn
  subnet_ids      = aws_subnet.private-subnet[*].id

  // Worker Settings
  instance_types = var.worker-instance-types
  disk_size      = var.worker-disk-size

  labels = {
    "role" = "terraform-eks-m5-large"
  }

  scaling_config {
    desired_size = var.worker-size.desired
    min_size     = var.worker-size.min
    max_size     = var.worker-size.max
  }

  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    Name        = "${local.cluster_name}-worker-node"
  }
}
