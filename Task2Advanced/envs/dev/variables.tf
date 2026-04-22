variable "cloud_id" {
  description = "Идентификатор облака Yandex Cloud."
  type        = string
}

variable "folder_id" {
  description = "Идентификатор каталога Yandex Cloud."
  type        = string
}

variable "zone" {
  description = "Зона доступности (должна совпадать с подсетью и параметром модуля)."
  type        = string
}

variable "vm_name" {
  description = "Имя ВМ для этого стека."
  type        = string
}

variable "cores" {
  type = number
}

variable "memory_gb" {
  type = number
}

variable "disk_size_gb" {
  type = number
}

variable "subnet_id" {
  type = string
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}
