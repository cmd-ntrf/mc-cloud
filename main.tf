terraform {
  required_version = ">= 0.14.2"
}

variable "node_count" {
  default = 1
}

module "openstack" {
  source         = "./openstack"
  config_git_url = "https://github.com/ComputeCanada/puppet-magic_castle.git"
  config_version = "11.0"

  cluster_name = "tfcloud"
  domain       = "calculquebec.cloud"
  image        = "CentOS-7-x64-2020-03"

  instances = {
    mgmt   = { type = "p4-6gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
    login  = { type = "p2-3gb", tags = ["login", "public", "proxy"], count = 1 }
    node   = { type = "g1-18gb-c4-22gb", tags = ["node"], count = var.node_count }
  }

  volumes = {
    nfs = {
      home     = { size = 10 }
      project  = { size = 50 }
      scratch  = { size = 50 }
    }
  }

  public_keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtK+7I+alsG4rJvg96ycHCl9Cjugww4D+UnPXCm1qi+kwq/SHyc3dXdPt1ls47jerAj3jfWx39zFovN3eyRsxG0PyMLyl2xpeYxT9BKWVqClijYKfUBj74fFsOj9ma7rw6Y7ksNXA4zL1VVhRH7vIhgjWZZO1VH1f6GYrB6sVBsjodKYQLAF+TLPJsONYOOQe8iKxdOCob/9D5nWRgIARTNGWc4m2EQAciDoZ2Qmoy0BSFs7amhMqytmFk80Ww83K2Fa4lqn/27rMb4NZlbzYKWfmnPXefzW/oa85WmFM+al95Lwg55kXWWTgOCBj1atYizLCQwZ1KSVPcn6fQVB3Yw=="]

  nb_users = 10
  generate_ssh_key = true
}

output "accounts" {
  value = module.openstack.accounts
}

output "public_ip" {
  value = module.openstack.public_ip
}

## Uncomment to register your domain name with CloudFlare
# module "dns" {
#   source           = "./dns/cloudflare"
#   email            = "you@example.com"
#   name             = module.openstack.cluster_name
#   domain           = module.openstack.domain
#   public_instances = module.openstack.public_instances
#   ssh_private_key  = module.openstack.ssh_private_key
#   sudoer_username  = module.openstack.accounts.sudoer.username
# }

## Uncomment to register your domain name with Google Cloud
# module "dns" {
#   source           = "./dns/gcloud"
#   email            = "you@example.com"
#   project          = "your-project-id"
#   zone_name        = "you-zone-name"
#   name             = module.openstack.cluster_name
#   domain           = module.openstack.domain
#   public_instances = module.openstack.public_instances
#   ssh_private_key  = module.openstack.ssh_private_key
#   sudoer_username  = module.openstack.accounts.sudoer.username
# }

# output "hostnames" {
#   value = module.dns.hostnames
# }
