locals {
  hashcmd 	= "${var.cmdp1} ${var.hashmode} ${var.cmdp2}"
}

data "http" "myip" {
  url = "https://ipinfo.io/ip"
}

# create and run a cracking instance
provider "aws" {
  profile	= "default"
  region	= "eu-central-1"
}

resource "aws_security_group" "rook_security" {
  description	= "Allow inbound SSH."
  
  egress {
    from_port	= 0
    to_port	= 0
    protocol	= "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port	= 22
    to_port	= 22
    protocol	= "tcp"
    cidr_blocks	= ["${var.whitelistip}", "${chomp(data.http.myip.body)}/32"]
  }
}

resource "aws_spot_instance_request" "rook-spot" {
  spot_price		= "${var.spotprice}"
  spot_type		= "one-time"
  availability_zone	= "eu-central-1a"
  wait_for_fulfillment	= true
  ami			= "${var.ami}"
  instance_type		= "${var.itype}"
  key_name		= "${var.identity}"
  security_groups	= ["${aws_security_group.rook_security.name}"]
   
  ebs_block_device {
    device_name	= "/dev/xvdb"
    volume_size = 50
    volume_type = "gp3"
    snapshot_id = "${var.snapid}"
  }

  connection {
    type	= "ssh"
    host	= "${aws_spot_instance_request.rook-spot.public_ip}"
    user	= "ubuntu"
    private_key = "${file("${var.sshkeyfile}")}"
  }
  
  provisioner "file" {
    source	= "files/blacklist-nouveau.conf"
    destination	= "/tmp/blacklist-nouveau.conf"
  }

  provisioner "file" {
    source	= "files/nouveau-kms.conf"
    destination	= "/tmp/nouveau-kms.conf"
  }
  
  provisioner "file" {
    source	= "files/hashes.txt"
    destination	= "/tmp/hashes.txt"
  }

  provisioner "remote-exec" {
    inline = [
    "sudo apt update",
    "sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\"",
    "sudo DEBIAN_FRONTEND=noninteractive apt install -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" build-essential linux-headers-4.15.0-1040-aws gcc screen linux-image-extra-virtual git make",
    "sudo apt update && sudo apt upgrade -y && sudo apt install build-essential -yq && sudo apt-get install p7zip-full -y",
    "sudo cp /tmp/blacklist-nouveau.conf /etc/modprobe.d/.",
    "sudo cp /tmp/nouveau-kms.conf /etc/modprobe.d/.",
    "sudo cp /tmp/hashes.txt /opt/.",
    "sudo update-initramfs -u",
    "sudo reboot &",
    ]
    # sshd process may exit before the reboot completes, preventing it from
    # returning the scripts exit status
    # allow_missing_exit_status = true
    # Option doesn't appear to be working currently...
  }

  provisioner "remote-exec" {
    # new remote exec to connect back after restart
    inline = [
    "sudo wget -P /opt/ ${var.nvidia}",
    "sudo wget -P /opt/ https://hashcat.net/beta/hashcat-6.1.1%2B150.7z",
    "sudo /bin/bash /opt/NVIDIA-Linux-x86_64-460.32.03.run --ui=none --no-questions --silent -X",
    "sudo mkdir /opt/hashcat/",
    #"sudo tar -xvf /opt/hashcat-6.1.1.tar.gz -C /opt/",
    "cd /opt/",
    "sudo 7z x hashcat-6.1.1+150.7z",
    #"cd /opt/hashcat-6.1.1 && sudo make",
    "sudo mkdir /words/",
    "sudo mount /dev/xvdb /words/",
    "${local.hashcmd}",
    "sleep 1",
    ]
  }
}

resource "null_resource" "local" {
  provisioner "local-exec" {
    command = "echo ssh -i ${var.sshkeyfile} ubuntu@${aws_spot_instance_request.rook-spot.public_ip}"
  }
}
