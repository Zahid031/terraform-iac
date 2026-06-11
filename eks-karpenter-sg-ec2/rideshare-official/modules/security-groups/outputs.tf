output "eks_cluster_sg_id" {
  description = "EKS control plane SG — pass to eks module"
  value       = aws_security_group.eks_cluster.id
}

output "eks_nodes_sg_id" {
  description = "EKS worker node SG — Karpenter discovers via tag, reference only"
  value       = aws_security_group.eks_nodes.id
}

output "alb_sg_id" {
  description = "ALB SG — attach to AWS Load Balancer Controller ingress class"
  value       = aws_security_group.alb.id
}

output "data_plane_sg_id" {
  description = "Data plane SG — attach to Postgres, Redis, Kafka, ScyllaDB instances"
  value       = aws_security_group.data_plane.id
}

output "bastion_sg_id" {
  description = "Bastion SG — pass to ec2-bastion module"
  value       = aws_security_group.bastion.id
}
