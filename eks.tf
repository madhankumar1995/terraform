module "eks" {
  create = var.create_eks
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "doohp-${var.environment}"
  cluster_version = "1.22"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks_default.arn
    resources        = ["secrets"]
  }]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["m6i.large", "t3.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = var.eks_node_instance_count

      instance_types = var.eks_node_instance_type
      capacity_type  = "SPOT"
      key_name       = "devops"
      labels = {
        Environment = var.environment
      }

      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }

    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::002445826379:user/rocket_employees/andrew.break"
      username = "developer"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::002445826379:user/au/au_tf_user"
      username = "kyle.sorrels"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::002445826379:user/kyle.sorrels"
      username = "kyle.sorrels"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::002445826379:user/rocket_employees/andrew.break"
      username = "andrew.break"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::002445826379:user/rocket_employees/madhan.kumar"
      username = "madhan.kumar"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_accounts = [
    "002445826379"
  ]

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

####################
#    ETC           #
####################

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

resource "aws_kms_key" "eks_default" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
