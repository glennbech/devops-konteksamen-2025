terraform {
  required_providers {
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.2.2"
    }
  }
}

resource "statuscake_uptime_check" "this" {
  name           = var.name
  check_interval = var.check_interval
  confirmation   = var.confirmation
  trigger_rate   = var.trigger_rate
  contact_groups = var.contact_group_id


  http_check {
    request_method   = var.request_method
    timeout          = var.timeout
    validate_ssl     = var.validate_ssl
    follow_redirects = var.follow_redirects
    status_codes     = var.status_codes
  }

  monitored_resource {
    address = var.address
  }

  tags = var.tags
}
