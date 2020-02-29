How to use
==========

## Set vairables

```
mv terraform.example.tfvars terraform.tfvars
# input variables in terraform.tfvars
export TF_VAR_vsphere_user={user}
export TF_VAR_vsphere_password={password}
export TF_VAR_vsphere_server={server}
```

## Run terraform

```
terraform init
terraform plan
terraform apply
```
