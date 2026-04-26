variable "vm_name" {
  description = "Имя виртуальной машины (задаётся вызывающей конфигурацией, без привязки к имени окружения внутри модуля)."
  type        = string
}

variable "cores" {
  description = "Число vCPU."
  type        = number
}

variable "memory_gb" {
  description = "Объём RAM, ГиБ."
  type        = number
}

variable "disk_size_gb" {
  description = "Размер подключаемого диска данных, ГБ."
  type        = number
}

variable "subnet_id" {
  description = "Идентификатор подсети для основного сетевого интерфейса."
  type        = string
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к ВМ (метаданные cloud-init / SSH keys)."
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "Зона доступности для ВМ и диска."
  type        = string
}

variable "boot_disk_size_gb" {
  description = "Размер загрузочного диска, ГБ."
  type        = number
  default     = 10
}

variable "image_family" {
  description = "Семейство образа ОС для загрузочного диска (публичный образ Yandex Cloud)."
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "disk_type" {
  description = "Тип подключаемого диска данных (например network-hdd, network-ssd)."
  type        = string
  default     = "network-hdd"
}

variable "enable_nat" {
  description = "Назначать ли публичный IP (NAT) для интерфейса в подсети."
  type        = bool
  default     = true
}

variable "platform_id" {
  description = "Идентификатор платформы вычислений Yandex Cloud."
  type        = string
  default     = "standard-v3"
}
