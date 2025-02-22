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


resource "statuscake_uptime_check" "example" {
  check_interval = var.check_interval
  confirmation   = var.confirmation
  name           = var.uptime_check_name
  trigger_rate   = var.trigger_rate

  http_check {
    timeout      = var.http_timeout
    validate_ssl = var.validate_ssl
    status_codes = var.status_codes
  }

  monitored_resource {
    address = var.monitored_address
  }
  tags = var.tags
}

output "example_com_uptime_check_id" {
  value = statuscake_uptime_check.example.id
}
