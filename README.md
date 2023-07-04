# Arbor Tech Test Documentation
Terraform implementation of the Arbor Tech Test

## Common Tasks

### Dev

Run `terraform workspace select dev`
`terraform plan -var-file=config/dev.tfvars`
`terraform apply -var-file=config/dev.tfvars`

### Todo

 - Add SSL Functionality to ALB - Currently not possible in my sandbox environment
[] Autoscaling based upon metrics for Response Time
[] Autoscaling based upon metrics for Success Rate - 5xx 
[] Testing+Security - tfsec - static code analysis for terraform stack
[] Migration to Containers - Faster scale up 
[] Load Testing - Not possible against nginx welcome page - Gatling 

4000 schools * 20 classes * 30 peoples = Up to 80,000 registers being submitted at 930am 
Potential for use of SQS or other queueing service to reduce write requirements to the database
Redis/Memcache to cache reads of class list 
