module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}


module "eks" {
  source = "./modules/eks"

  cluster_name    = "eks-labs"
  node_group_name = "eks-workers"

  node_instance_type = "t3.medium"

  desired_size = 2
  min_size     = 1
  max_size     = 3

  subnet_ids = concat(
    module.vpc.public_subnets,
    module.vpc.private_subnets
  )

  private_subnet_ids = module.vpc.private_subnets
}