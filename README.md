# stackpath-anycast-terrafor,

Terraform Anycast setup on stackpath using containers and/or VM's

to run this, first set the enviroment variables, Set enviroment variables like this:

```
export TF_VAR_stackpath_client_id=xxx
export TF_VAR_stackpath_client_secret=xxx
export TF_VAR_stackpath_stack_id=xxx  #Stackpath speak for project. https://control.stackpath.com/stacks/ it's the slug
```

Run terrafrom from either the VM or Container directory:


```
terraform init
terraform plan
terraform apply
```

get the anycast IP via web or
```
 cat terraform.tfstate | grep anycast.platform.stackpath.net/subnets
              "anycast.platform.stackpath.net/subnets": "185.85.196.41/32"
``` 
you should now have an anycasted service running on that IP port 5000.

10 secs of work and you have global workload :)

To clean up and shut down run:
```
terraform destroy
```

