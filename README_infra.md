# Technical case data ops

The infrastructure set up for this project involved the following:

1. Setting up configuration using the command `aws configure`. The variables for the `AWS Access Key ID`,
`AWS Secret Access Key`, `Default region name`, and `Default output format` where set this way. 

2. Terraform configuration files were then initialized with this block:

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

```
and then `terraform init`. 

3. After that, the terraform commands provided within the instructions were used: `terraform validate`, `terraform plan`, and `terraform apply`. 

## Additional features added
- Variable management, with the `variables.tf` file.
- version control, with Github


## Future directions
If I had more than the 'few hours' this take home was designed for , I would do the following:
- write tests for the infrastructure and API
  - these would be simple tests using pytest that would check that the route is working well
- the terraform file would have been broken down into modules, such as in this example: https://spacelift.io/blog/what-are-terraform-modules-and-how-do-they-work
