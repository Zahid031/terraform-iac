locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Number of NAT Gateways: 0, 1 (single), or one per AZ
  nat_gw_count = var.enable_nat_gateway ? (
    var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)
  ) : 0
}
