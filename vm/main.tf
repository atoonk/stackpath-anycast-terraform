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


  virtual_machine {
    # Name that should be given to the container
    name = "app"

    # StackPath image to use for the VM
    image = "stackpath-edge/ubuntu-1804-bionic:v201909061930"

    # The ports that should be publicly exposed on the VM.
    port {
      name = "ssh"
      port = 22
      protocol = "TCP"
      enable_implicit_network_policy = true
    }
    port {
      name = "web"
      port = 80
      protocol = "TCP"
      enable_implicit_network_policy = true
    }


    # Override the command that's used to execute the container. If this option 
    # is not provided the default entrypoint and command defined by the docker 
    # image will be used.
    # command = []
    resources {
      requests = {
        "cpu"    = "4"
        "memory" = "16Gi"
      }
    }

  # Cloud-init user data. Provide at least a public key
    user_data = <<EOT
#cloud-config
ssh_authorized_keys:
 - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKMD4mOJGaKlnTXpgl02K6hkx1nZEq8Pq5JtwmqQJm+CktZKfFRTm/B0j5bB/97TQ+1Blb115rZ9fUrfo8BfXBtGcVzczrSDX8sR3o5mNSswTjBRomiEwfVY6MFoOyuuy5UJFFH8JL8dcSR3U2ILw8UIiv8lIWIYWdup4eU+78wuCLcujlB9JcPo6CVohjFgxSXO+eQN7vyF5Wof4n/VsIpQd/1zWq3rOv4XiA39yd57cYBlHffDRWiU607GsFdwyyEsnhU/JiFVTw5LyJNtAlx58WpiXekQ/3aMi9yoVy2uBZtnpg5uWSkLabc05vH3OcoKSyd+Nt38B2vsRQhXN1
EOT
    # Define a probe to determine when the instance is ready to serve traffic.
    readiness_probe {
      tcp_socket {
        port = 22
      }
      period_seconds = 60
      success_threshold = 1
      failure_threshold = 4
      initial_delay_seconds = 60
    }


    # Mount an additional volume into the virtual machine.
    volume_mount {
      slug       = "logging-volume"
      mount_path = "/var/log"
    }
  }

  target {
    name         = "global"
    min_replicas = 1
    max_replicas = 2
    scale_settings {
      metrics {
        metric = "cpu"
        # Scale up when CPU averages 50%.
        average_utilization = 50
      }
    }
    # Deploy these 1 to 2 instances in Dallas, TX, USA and Amsterdam, NL.
    deployment_scope = "cityCode"
    selector {
      key      = "cityCode"
      operator = "in"
      values   = [
        "DFW", "SEA"
      ]
    }
  }
  # Provision a new additional volume that can be mounted to the containers and
  # virtual machines defined in the workload.
  volume_claim {
    name = "Logging volume"
    slug = "logging-volume"
    resources {
      requests = {
        storage = "100Gi"
      }
    }
  }
}
