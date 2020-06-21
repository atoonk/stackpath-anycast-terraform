variable "stackpath_stack_id" {}
variable "stackpath_client_id" {}
variable "stackpath_client_secret" {}

# Set enviroment variables like this:
#export TF_VAR_stackpath_client_id=xxx
#export TF_VAR_stackpath_client_secret=xxx
#export TF_VAR_stackpath_stack_id=xxx  #Stackpath speak for project. https://control.stackpath.com/stacks/ it's the slug

# Specify StackPath Provider and your access details
provider "stackpath" {
  stack_id      = var.stackpath_stack_id
  client_id     = var.stackpath_client_id
  client_secret = var.stackpath_client_secret
}

resource "stackpath_compute_workload" "my-anycast-workload" {
  name = "my-anycast-workload"
  slug = "my-anycast-workload"

  annotations = {
    # request an anycast IP
    "anycast.platform.stackpath.net" = "true"
  }

  network_interface {
    network = "default"
  }


  container {
    # Name that should be given to the container
    name = "app"

    port {
      name = "web"
      port = 8000
      protocol = "TCP"
      enable_implicit_network_policy = true
    }

    # image to use for the container
    image = "atoonk/pythonweb:latest"

    # Override the command that's used to execute the container. If this option 
    # is not provided the default entrypoint and command defined by the docker 
    # image will be used.
    # command = []
    resources {
      requests = {
        "cpu"    = "1"
        "memory" = "2Gi"
      }
    }

    env {
      key   = "PYTHONUNBUFFERED"
      value = "1"
    }
  }

  target {
    name         = "global"
    min_replicas = 3
    max_replicas = 4
    scale_settings {
      metrics {
        metric = "cpu"
        # Scale up when CPU averages 50%.
        average_utilization = 50
      }
    }
    # Deploy these 1 to 2 instances in Dallas and Seattle
    deployment_scope = "cityCode"
    selector {
      key      = "cityCode"
      operator = "in"
      values   = [
        "DFW", "SEA"
      ]
    }
  }
}
