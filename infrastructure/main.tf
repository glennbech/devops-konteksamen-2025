terraform {
  required_providers {
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.2.2"
    }
  }
}

variable "site_name" {
  description = "Navnet på nettsiden som overvåkes"
  type        = string
}

variable "site_url" {
  description = "URL-adressen til nettsiden"
  type        = string
}

variable "check_interval" {
  description = "Hvor ofte StatusCake skal sjekke nettsiden (i sekunder)"
  type        = number
  default     = 300
}

variable "contact_group_id" {
  description = "ID-en til kontaktgruppen som skal varsles"
  type        = number
}

resource "statuscake_contact_group" "alerts" {
  name  = "Default Alerts"
  emails = ["admin@example.com"]
}

resource "statuscake_uptime_check" "website" {
  name           = var.site_name
  check_interval = var.check_interval
  confirmation   = 3
  trigger_rate   = 10

  http_check {
    timeout      = 20
    validate_ssl = true
    status_codes = ["200"]
  }

  monitored_resource {
    address = var.site_url
  }

  tags = ["production"]

  contact_groups = [statuscake_contact_group.alerts.id]
}

output "uptime_check_id" {
  value = statuscake_uptime_check.website.id
}
