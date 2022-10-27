# saedul/module/eks/main.tf

## 클러스터가 사용할 역할을 정의합니다.
## AmazonEKSClusterPolicy와 AmazonEKSVPCResourceController를 포함합니다.
resource "aws_iam_role" "cluster-role" {
  name = "${var.env}-eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster-role.name
}
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster-role.name
}

#Security Group
resource "aws_security_group" "cluster-sg" {
  name        = "clusterSG"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = {
    Name = "eks-cluster-sg"
  }
}
 
resource "aws_security_group_rule" "cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster-sg.id
  to_port           = 443
  type              = "ingress"
}

## EKS 클러스터를 정의합니다
resource "aws_eks_cluster" "cluster" {
  name     = "${var.env}-cluster"
  role_arn = aws_iam_role.cluster-role.arn
  version                   = "1.21"
  
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]  
  vpc_config {
    security_group_ids = [aws_security_group.cluster-sg.id]
    subnet_ids = var.private-subnet[*]
    endpoint_private_access = true
    endpoint_public_access = true
  }
   
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
  ]
}

# resource "aws_eks_addon" "kube_proxy" {
#   cluster_name      = aws_eks_cluster.cluster.name
#   addon_name        = "kube-proxy"
#   addon_version     = "v1.21.2-eksbuild.2"
#   resolve_conflicts = "OVERWRITE"
# }
# resource "aws_eks_addon" "core_dns" {
#   cluster_name      = aws_eks_cluster.cluster.name
#   addon_name        = "coredns"
#   addon_version     = "v1.8.4-eksbuild.1"
#   resolve_conflicts = "OVERWRITE"
# }

// eks-cluster-node
# 여기서는 EC2관련 IAM Role을 생성해주고
resource "aws_iam_role" "worker-iam-role" {
  name               = "${var.env}-cluster-managed-worker-node"

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
    Name        = "${var.env}-cluster-worker-node-iam-role"
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
  node_group_name = "${var.env}-cluster-worker-node"
  node_role_arn   = aws_iam_role.worker-iam-role.arn
  subnet_ids      = var.private-subnet[*]
  
  // Worker Settings
  instance_types = var.worker-instance-types
  disk_size      = var.worker-disk-size

  labels = {
    "role" = "terraform-eks-m5-large"
  }
  
  remote_access {
    ec2_ssh_key = aws_key_pair.eks-keypair-dev.key_name
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
    Name        = "${var.env}-cluster-worker-node"
  }
}
