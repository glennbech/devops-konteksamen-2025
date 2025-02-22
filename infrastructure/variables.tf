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
