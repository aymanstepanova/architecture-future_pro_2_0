output "vm_id" {
  description = "Идентификатор виртуальной машины."
  value       = yandex_compute_instance.this.id
}

output "vm_name" {
  description = "Имя виртуальной машины."
  value       = yandex_compute_instance.this.name
}

output "vm_internal_ip" {
  description = "Внутренний IP основного сетевого интерфейса."
  value       = yandex_compute_instance.this.network_interface[0].ip_address
}

output "vm_public_ip" {
  description = "Публичный IP (NAT), если включён."
  value       = yandex_compute_instance.this.network_interface[0].nat_ip_address
}

output "data_disk_id" {
  description = "Идентификатор подключаемого диска данных."
  value       = yandex_compute_disk.data.id
}

output "data_disk_name" {
  description = "Имя подключаемого диска данных."
  value       = yandex_compute_disk.data.name
}
