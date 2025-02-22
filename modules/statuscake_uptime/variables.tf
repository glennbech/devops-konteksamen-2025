variable "name" {
  description = "Navn på overvåkningstjenesten"
  type        = string
}

variable "address" {
  description = "Nettsiden som skal overvåkes"
  type        = string
}

variable "check_interval" {
  description = "Hvor ofte skal sjekken kjøres (i sekunder)"
  type        = number
  default     = 300
}

variable "confirmation" {
  description = "Antall bekreftelser før en feil rapporteres"
  type        = number
  default     = 3
}

variable "trigger_rate" {
  description = "Antall feilede sjekker før varsling"
  type        = number
  default     = 10
}

variable "timeout" {
  description = "Timeout for HTTP-sjekk (i sekunder)"
  type        = number
  default     = 50
}

variable "validate_ssl" {
  description = "Skal sertifikatvalidering brukes?"
  type        = bool
  default     = false
}

variable "request_method" {
  description = "HTTP request method for the uptime check"
  type        = string
  default     = "HTTP"
}

variable "follow_redirects" {
  description = "Om vi skal følge redirects"
  type        = bool
  default     = true
}

variable "status_codes" {
  description = "Godkjente HTTP-statuskoder"
  type        = list(string)
  default     = ["200"]
}

variable "tags" {
  description = "Liste over tags for overvåkningstjenesten"
  type        = list(string)
  default     = ["production"]
}
