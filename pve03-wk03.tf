resource "proxmox_virtual_environment_vm" "web_server-wk03" {
  node_name       = "pve03"
  vm_id           = 106
  name            = "wk-03"
  bios            = "ovmf"
  machine         = "q35"
  keyboard_layout = "en-us"
  boot_order      = ["scsi0", "ide2", "net0"]

  acpi                                 = true
  on_boot                              = false
  scsi_hardware                        = "virtio-scsi-single"
  delete_unreferenced_disks_on_destroy = true
  purge_on_destroy                     = true
  reboot_after_update                  = true

  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = "virtio"
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 12288
  }

  operating_system {
    type = "l26"
  }

  efi_disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
    type         = "4m"
  }


  disk {
    interface         = "scsi0"
    datastore_id      = "local-lvm"
    file_format       = "raw"
    size              = 32
    cache             = "writeback"
    aio               = "io_uring"
    discard           = "on"
    iothread          = true
    path_in_datastore = "vm-106-disk-1"
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "BC:24:11:6E:70:E0" 
    queues      = 2
  }
  lifecycle {
    ignore_changes = [
      disk,    
      hostpci   
    ]
  }
 }