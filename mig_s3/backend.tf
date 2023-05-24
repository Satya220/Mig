terraform {
  backend "s3" {
    bucket = "sfbucket220"
    key    = "project1/week1/terraform/terraform.tfstates"
    dynamodb_table = "terraform-lock"  
  }
 }
