Example of simple highly available web server by terraform.

There are several points of project MVP:
- green/blue deployment
- zero downtime
- autoscaling
- load balancer

As a result of run there will be started and printed load balancer url with necessary instances.

Provider: `aws`

Use:
- `terraform init`
- `terraform plan` and `terraform apply`
- `terraform destroy` (don't forget after testing!)

(with secrets in env or profile `AWS_PROFILE=<profile>`)
