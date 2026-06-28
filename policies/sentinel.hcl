policy "restrict-azure-app-service-sku" {
  source            = "./restrict-azure-app-service-sku.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "restrict-aws-eb-instance-type" {
  source            = "./restrict-aws-eb-instance-type.sentinel"
  enforcement_level = "hard-mandatory"
}
