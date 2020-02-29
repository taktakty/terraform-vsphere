How to use
==========

## Prerequisites

```
brew install terraform
brew install ansible
```

## Set vairables

```
mv terraform.tfvars.example terraform.tfvars
# input variables in terraform.tfvars
export TF_VAR_vsphere_user={user}
export TF_VAR_vsphere_password={password}
export TF_VAR_vsphere_vcenter={server}
export TF_VAR_vm_user={user}
export TF_VAR_vm_password={password}
```

## Run terraform

```
terraform init
terraform plan
terraform apply
```
