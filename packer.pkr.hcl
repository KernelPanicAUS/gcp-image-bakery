source "googlecompute" "ubuntu" {
  project_id   = "cloudrun-testing-321019"
  source_image = "ubuntu-1804-bionic-v20210623"
  image_name   = "ubuntu-1804-haredened-{{timestamp}}"
  ssh_username = "ubuntu"
  preemptible  = true
  zone         = "europe-west3-b"
}

source "googlecompute" "centos-8" {
  project_id   = "cloudrun-testing-321019"
  source_image = "centos-8-v20210721"
  image_name   = "centos-8-haredened-{{timestamp}}"
  ssh_username = "packer"
  preemptible  = true
  zone         = "europe-west3-b"
}

source "googlecompute" "rhel-8" {
  project_id   = "cloudrun-testing-321019"
  source_image = "rhel-8-v20210721"
  image_name   = "rhel-8-haredened-{{timestamp}}"
  ssh_username = "packer"
  preemptible  = true
  zone         = "europe-west3-b"
}

build {
  sources = [
    "sources.googlecompute.ubuntu",
    "sources.googlecompute.centos-8",
    "sources.googlecompute.rhel-8"
  ]

  # provisioner "shell" {
  #   inline = [
  #     "yes | sudo apt update",
  #     "yes | sudo apt upgrade"
  #   ]
  # }


  provisioner "ansible" {
    extra_arguments = ["-b"]
    playbook_file   = "./main.yml"
    user            = "packer"
  }
}
