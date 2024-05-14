variable "remote_folder" {
  type        = string
  description = "The remote folder name"
  default     = "/tmp"
}

variable "kubernetes_version" {
  type        = string
  description = "The kubernetes version to install"
  default     = "1.30"
}
