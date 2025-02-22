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

# Bruker Terraform-modulen til å overvåke to nettsider
module "uptime_check_vg" {
  source          = "../modules/statuscake_uptime"
  name            = "VG Uptime Check"
  address         = "https://www.vg.no"
  check_interval  = 300
  confirmation    = 3
  trigger_rate    = 10
  timeout         = 50
  validate_ssl    = false  # Midlertidig for testing
  request_method  = "HTTP"
  follow_redirects = true
  status_codes    = ["200"]
  tags            = ["news", "monitoring"]
}

module "uptime_check_xkcd" {
  source          = "../modules/statuscake_uptime"
  name            = "XKCD Uptime Check"
  address         = "https://xkcd.com"
  check_interval  = 300  # Endret fra 600 til 300 (tillatt verdi)
  confirmation    = 3
  trigger_rate    = 5
  timeout         = 50
  validate_ssl    = false  # Midlertidig for testing
  request_method  = "HTTP"
  follow_redirects = true
  status_codes    = ["200"]
  tags            = ["comics", "monitoring"]
}

# Output for begge sjekkene
output "vg_uptime_check_id" {
  value = module.uptime_check_vg.uptime_check_id
}

output "xkcd_uptime_check_id" {
  value = module.uptime_check_xkcd.uptime_check_id
}
