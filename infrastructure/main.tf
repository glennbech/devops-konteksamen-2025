terraform {
  required_providers {
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.2.2"
    }
  }
}

provider "statuscake" {
  api_token = var.statuscake_api_token
}

resource "statuscake_contact_group" "default" {
  name            = var.contact_group_name
  email_addresses = var.contact_group_emails
}
output "contact_group_id" {
  value = statuscake_contact_group.default.id
}

# Bruker Terraform-modulen til å overvåke to nettsider
module "uptime_check_vg" {
  source           = "../modules/statuscake_uptime"
  name             = "VG Uptime Check"
  address          = "https://www.vg.no"
  check_interval   = 900
  confirmation     = 3
  trigger_rate     = 10
  timeout          = 75 
  validate_ssl     = false  # Deaktivert SSL-validering
  follow_redirects = true   # Tillater redirects
  request_method   = "HTTP"
  status_codes = [
  "200", "201", "204", "205", "206", "303", "400", "401", "403", 
  "404", "405", "406", "408", "409", "410", "413", "429", "444", 
  "494", "495", "496", "499", "500", "501", "502", "503", "504", 
  "505", "506", "507", "508", "509", "510", "511", "521", "522", "523"
]
  tags             = ["news", "monitoring"]
contact_group_id = [statuscake_contact_group.default.id]
}

module "uptime_check_xkcd" {
  source           = "../modules/statuscake_uptime"
  name             = "XKCD Uptime Check"
  address          = "https://xkcd.com"
  check_interval   = 900
  confirmation     = 3
  trigger_rate     = 2
  timeout          = 75
  validate_ssl     = false
  follow_redirects = true
  request_method   = "HTTP"
  status_codes = [
  "200", "201", "204", "205", "206", "303", "400", "401", "403", 
  "404", "405", "406", "408", "409", "410", "413", "429", "444", 
  "494", "495", "496", "499", "500", "501", "502", "503", "504", 
  "505", "506", "507", "508", "509", "510", "511", "521", "522", "523"
]
  tags             = ["comics", "monitoring"]
contact_group_id = [statuscake_contact_group.default.id]
}

# Output for begge sjekkene
output "vg_uptime_check_id" {
  value = module.uptime_check_vg.uptime_check_id
}

output "xkcd_uptime_check_id" {
  value = module.uptime_check_xkcd.uptime_check_id
}
