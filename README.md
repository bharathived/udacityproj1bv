# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
In this project, you'll have the opportunity to demonstrate the skills learned in this course, by creating infrastructure as code in the form of a Terraform template to deploy a website with a load balancer.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com)
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
<h1> Create Policy definition </h1>
Create Policy definition to ensure all indexed resources in your subscription have tags and deny creation if they do not have tags.
 project1policy.json is the policy file. Run the following commands from VisualStudio terminal.
1) terraform init

2) az login

3)  az policy definition create --name tagging-policy --rules project1policy.json
4) az policy assignment list - command will display the list of policies in your subscription. please verify if your newly created tagging-policy

<h1> Creating a Packer template </h1>
  Use server.json as template to virtual machine image. create environment file with following enviroment variables:
  export ARM_CLIENT_SECRET="KxxxxxV"
  export ARM_SUBSCRIPTION_ID="xxxx"
  export ARM_TENANT_ID="xxxxx"
  export ARM_CLIENT_ID="xxxxxxx"
  set the environment variables using environment file.

  packer validate server.json
  packer build  server.json

<h1> Creating a Terraform template </h1>
  use the same enviroment file to set/export the environment variables.
  main.tf and variables.tf goes together .  
  terraform validate  - command use to validate main.tf and variables.tf
  terraform plan -out solution.plan


<h1> Deploying the infrastructure </h1>
Deploy the infrastructure by running the following command.
terraform apply -plan solution.plan
### Output
**Your words here**
 
