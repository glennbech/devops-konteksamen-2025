variable "statuscake_api_token" {
  description = "API-token for StatusCake"
  type        = string
}

variable "contact_group_name" {
  description = "Navn på kontaktgruppen"
  type        = string
  default     = "DevOps Team"
}

variable "contact_group_emails" {
  description = "E-postadresser for kontaktgruppen"
  type        = list(string)
  default     = ["mumi002@student.krstiania.no"]
}


variable "uptime_check_name" {
  description = "Navn på uptime-sjekken"
  type        = string
  default     = "example-site"
}

variable "check_interval" {
  description = "Hvor ofte sjekken skal kjøre (i sekunder)"
  type        = number
  default     = 300
}

variable "confirmation" {
  description = "Antall bekreftelser før en feil rapporteres"
  type        = number
  default     = 3
}

variable "trigger_rate" {
  description = "Antall ganger en feil må oppstå før alarmen utløses"
  type        = number
  default     = 10
}

variable "http_timeout" {
  description = "Timeout for HTTP-sjekken"
  type        = number
  default     = 20
}

variable "validate_ssl" {
  description = "Om SSL-validering skal være aktivert"
  type        = bool
  default     = true
}

variable "status_codes" {
  description = "Hvilke HTTP-statuskoder som anses som gyldige"
  type        = list(string)
  default     = ["200"]
}

variable "monitored_address" {
  description = "Nettsiden som skal overvåkes"
  type        = string
  default     = "https://www.example.com"
}

variable "tags" {
  description = "Tags for ressursen"
  type        = list(string)
  default     = ["production"]
}
