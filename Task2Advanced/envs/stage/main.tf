module "vm" {
  source = "../../../Task1Advanced/modules/vm"

  vm_name        = var.vm_name
  cores          = var.cores
  memory_gb      = var.memory_gb
  disk_size_gb   = var.disk_size_gb
  subnet_id      = var.subnet_id
  ssh_public_key = var.ssh_public_key
  zone           = var.zone
}
