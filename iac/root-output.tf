output "vpc_id" {
    value = module.staging-network.vpc_id
}
output "public_subnets"{
    value = module.staging-network.public_subnets
}
output "private_subnets"{
    value = module.staging-network.private_subnets
}
output "eks_name" {
    value = module.eks.cluster_name
}
output "name-servers" {
    value = module.domain_map.name-servers
}