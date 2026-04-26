data "yandex_compute_image" "os" {
  family = var.image_family
}

resource "yandex_compute_disk" "data" {
  name = "${var.vm_name}-data"
  type = var.disk_type
  zone = var.zone
  size = var.disk_size_gb
}

resource "yandex_compute_instance" "this" {
  name        = var.vm_name
  platform_id = var.platform_id
  zone        = var.zone

  resources {
    cores  = var.cores
    memory = var.memory_gb
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.os.id
      size     = var.boot_disk_size_gb
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.data.id
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = var.enable_nat
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}
