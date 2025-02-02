variable "SA_name" {
  type        = string
  default     = "terraform-tfstate"
  description = "The SA name"
}

variable "sa-auth-key-name" {
  type        = string
  default     = ".auth-key.json"
  description = "The authorized key name"
}

variable "sa-static-key-name" {
  type        = string
  default     = ".credentials"
  description = "The static key name"
}
