variable "bucket_name" {
  type        = string
  default     = "faizievbucket"
  description = "The bucket name"
}

variable "bucket_size" {
  type        = number
  default     = 1073741824
  description = "size in bytes"
}

variable "bucket_acl" {
  type        = string
  default     = "private"
  description = "The bucket acl"
}
