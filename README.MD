
# Deploy Jenkins to AWS CentOS AMI using Terraform and Ansible
Make sure to create S3 bucket to store your terraform state.

main.tf
```
terraform {
	required_version = ">= 0.12"
	backend "s3" {
		bucket = "mark-terraform-jenkins-state" //replace bucket with your s3-bucket-name
		key="jenkins/state.tfstate"
		region="eu-west-1" // replace s3-region
	}
}
```

## Installations
Make sure to install terraform and ansible in your local machine

Install brew and ansible for mac using brew
Installing ansible:

```
brew  install ansible
```

Installing terraform:
```
brew install terraform
```

## Deployment
Provision ec2-server using terraform and run ansible after provisioning 

```
terraform init
```

```
terraform apply --auto-approve
```

## Accessing jenkins website
Visit your deployed jenkins website @ http://server_public_ip:8080

## Getting jenkins password 
Generating jenkins password from deployed ec2 server
```
ssh centos@server_public_ip;
sudo cat /Users/Shared/Jenkins/Home/secrets/initialAdminPassword;
```


## Remove provisioned ec2-server
```
terraform destroy --auto-approve
```