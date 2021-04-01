variable "snapid" {
  default	= "snap-"
  #provide your snapshot id here - i used an ec2 machine downloaded the files which are needed (lists file) and created a snapshot 
}

variable "nvidia" {
  default	= "http://us.download.nvidia.com/tesla/460.32.03/NVIDIA-Linux-x86_64-460.32.03.run"
}

variable "hashcat" {
  default	= "https://hashcat.net/files/hashcat-6.1.1.tar.gz"
}

variable "ami" {
  default	= "ami-0d3905203a039e3b0"
}

variable "itype" {
  default	= "p3.16xlarge"
}

variable "identity" {
  default	= "user"
}

variable "whitelistip" {
  default	= "0.0.0.0/32"
}

variable "sshkeyfile" {
  default	= "/home/user/.ssh/user"
}

variable "spotprice" {
  default	= null
}

variable "cmdp1" {
  default 	= "nohup sudo screen -dmS hashcat bash  -c 'sudo /opt/hashcat-6.1.1/hashcat.bin -a 0 -m"
}

variable "cmdp2" {
  default = "/opt/hashes.txt /words/rockyou.txt /words/hashesorg2019 /words/crackstation.txt -r /words/OneRuleToRuleThemAll.rule -o 00cracked.txt; exec bash' &"
}

variable "hashmode" {
  type		= number
  default	= "23800"
}