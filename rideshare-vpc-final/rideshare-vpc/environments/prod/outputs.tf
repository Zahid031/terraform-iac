output "vpc_id"                    { value = module.vpc.vpc_id }
output "vpc_cidr"                  { value = module.vpc.vpc_cidr }
output "public_subnet_ids_list"    { value = module.vpc.public_subnet_ids_list }
output "private_app_subnet_ids_list"  { value = module.vpc.private_app_subnet_ids_list }
output "private_data_subnet_ids_list" { value = module.vpc.private_data_subnet_ids_list }
output "nat_gateway_public_ips"    { value = module.vpc.nat_gateway_public_ips }
output "vpc_endpoint_sg_id"        { value = module.vpc.vpc_endpoint_sg_id }
