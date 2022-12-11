environment            = "Prod"
vpc_id                 = "vpc-030733224caf4db0d"
availability_zones     = ["ap-southeast-1a", "ap-southeast-1b"]
private_subnets        = ["subnet-0cc7ce043d54d5d2c", "subnet-06c196150acab22d9"]
public_subnets         = ["subnet-033fbcf7fbdfc95ba", "subnet-08de7c009bd549a19"]
service_desired_count  = 1
tsl_certificate_arn    = "arn:aws:acm:ap-southeast-1:514380290403:certificate/5d5f5f70-022d-4f29-b353-b2b5eedb251b"
route53_hosted_zone_id = "Z0613739GJSDG0I0DOHQ"
container_image        = "514380290403.dkr.ecr.ap-southeast-1.amazonaws.com/prod-elk"
log_group              = "Prod-elk"
