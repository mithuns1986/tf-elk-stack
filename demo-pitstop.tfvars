ecs_name        = "-Demo-CDI-ECS"
environment         = "demo"
vpc_id              = "vpc-0d15cb8eec63686a1"
availability_zones  = ["ap-southeast-1a", "ap-southeast-1b"]
private_subnets     = ["subnet-0f455437d8e7610e8", "subnet-06dc315b236e12be4"]
public_subnets      = ["subnet-009cc6d0f8a461ba1", "subnet-0e48ed5ad5ef0958d"]
container_memory    = "1024"
service_desired_count = 1
container_port      = "4000"
container_cpu       = "512"
health_check_path   = "/" 
tsl_certificate_arn = "arn:aws:acm:ap-southeast-1:818682305270:certificate/dbb8fa5f-1993-4c29-9c08-5b141d1beb53"
container_image     = "818682305270.dkr.ecr.ap-southeast-1.amazonaws.com/dev-cdi-pitstop"
#
ecr_name = "demo-cdi"
alb_name = "demo-cdi"
sg_name  = "demo-cdi"
costcenter  = "12345"
db_allocated_storage = "20"
db_instance_class = "db.t3.micro"
multi_az = false
database_name = "democdi"
database_username = "demouser"
database_password = "DemoCDI#4321"




