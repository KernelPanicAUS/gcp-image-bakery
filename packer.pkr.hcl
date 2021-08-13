source "googlecompute" "ubuntu" {
  project_id   = "cloudrun-testing-321019"
  source_image = "ubuntu-1804-bionic-v20210623"
  image_name   = "ubuntu-1804-hardened-{{timestamp}}"
  ssh_username = "ubuntu"
  preemptible  = true
  zone         = "europe-west3-b"
}

source "googlecompute" "centos-8" {
  project_id   = "cloudrun-testing-321019"
  source_image = "centos-8-v20210721"
  image_name   = "centos-8-hardened-{{timestamp}}"
  ssh_username = "packer"
  preemptible  = true
  zone         = "europe-west3-b"
}

source "googlecompute" "rhel-8" {
  project_id   = "cloudrun-testing-321019"
  source_image = "rhel-8-v20210721"
  image_name   = "rhel-8-hardened-{{timestamp}}"
  ssh_username = "packer"
  preemptible  = true
  zone         = "europe-west3-b"
}

source "googlecompute" "windows_server_2016" {
  project_id          = "cloudrun-testing-321019"
  source_image_family = "windows-2016"
  disk_size           = "100"
  disk_type           = "pd-ssd"
  machine_type        = "e2-highcpu-8"
  communicator        = "winrm"
  //  subnetwork     = "app-vms"
  //  tags           = "packer-winrm"
  winrm_username = "packer_user"
  winrm_insecure = true
  winrm_use_ssl  = true
  metadata = {
    windows-startup-script-cmd = "winrm quickconfig -quiet & net user /add packer_user & net localgroup administrators packer_user /add & winrm set winrm/config/service/auth @{Basic=\"true\"}"
//    windows-shutdown-script-ps1 =  "C:/scripts/cleanup-packer.ps1"
  }
  zone = "europe-west3-b"
  //  image_storage_locations = ["europe-west2"]
  image_name = "windows-2016-hardened-{{timestamp}}"
  //  image_family =  "app-base"
}

build {
  sources = [
    "sources.googlecompute.windows_server_2016"
  ]

  provisioner "file" {
    source = "scripts/cleanup-packer.ps1"
    destination = "C:/scripts/cleanup-packer.ps1"
  }

  provisioner "file" {
    source = "posh-dsc-windows-hardening/AuditPolicy_WindowsServer2016.ps1"
    destination = "C:/scripts/AuditPolicy_WindowsServer2016.ps1"
  }

  provisioner "file" {
    source = "posh-dsc-windows-hardening/CIS_WindowsServer2016_v110.ps1"
    destination = "C:/scripts/CIS_WindowsServer2016_v110.ps1"
  }

  provisioner "powershell" {
    environment_vars = ["ADMIN_PASSWORD=${build.Password}"]
    script           = "scripts/enable-autologon.ps1"
  }

  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
  }

  provisioner "powershell" {
    environment_vars = ["WINRMPASS=${build.Password}"]
    inline           = ["Write-Host \"Automatically generated aws password is: $Env:WINRMPASS\""]
  }

  provisioner "powershell" {
    script            = "scripts/windows-2016-bootstrap.ps1"
    elevated_user     = "packer_user"
    elevated_password = build.Password
  }

  provisioner "powershell" {
    environment_vars = ["ADMIN_PASSWORD=${build.Password}"]
    script           = "scripts/disable-autologon.ps1"
  }
}

build {
  sources = [
    "sources.googlecompute.ubuntu",
    "sources.googlecompute.centos-8",
    "sources.googlecompute.rhel-8"
  ]

  provisioner "ansible" {
    extra_arguments = ["-b"]
    playbook_file   = "./main.yml"
    user            = "packer"
  }
}
