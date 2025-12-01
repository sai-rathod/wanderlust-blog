module "staging-network" {
    source = "./network"
    env = "staging"
    vpc_cidr = "10.10.0.0/16"
    public_subnet_cidr = ["10.10.1.0/24","10.10.2.0/24"]
    private_subnet_cidr = ["10.10.10.0/24","10.10.11.0/24"]
    sg_ports = [20,443,3000,8080,80]
}

module "domain_map" {
  source = "./domainmap"
  domain_name = "practicesayi.online"
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "practicesayi.online"
  zone_id     = module.domain_map.domain-zone-id

  subject_alternative_names = ["www.practicesayi.online"]

  wait_for_validation = true
  validation_method   = "DNS"

  tags = {
    Name        = "wanderlust-certificate"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = "wanderlust-cluster"
  cluster_version = "1.28"

  vpc_id     = module.staging-network.vpc_id
  subnet_ids = module.staging-network.public_subnets

  cluster_endpoint_public_access = true
    cluster_addons = {
    coredns = {
      most_recent = true
    }
    
    kube-proxy = {
      most_recent = true
    }
    
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }


  eks_managed_node_groups = {
    spot_nodes = {
      name = "spot-node-group"
      
      desired_size = 2
      min_size     = 1
      max_size     = 3
      
      capacity_type  = "SPOT"
      instance_types = ["t2.medium"]
      
      disk_size = 20
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}