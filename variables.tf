variable "location" {
  description = "Região Azure"
  type        = string
  default     = "northcentralus"
}

variable "admin_username" {
  description = "Usuario admin da VM"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Caminho da chave publica SSH"
  type        = string
}

variable "allowed_ssh_ip" {
  description = "Ip autorizado a acessar via ssh (CIDR)"
  type        = string
}