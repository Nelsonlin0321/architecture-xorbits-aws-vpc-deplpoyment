variable "region" {
  default = "ap-southeast-1"
}

variable "vpc-cidr" {
  default = "10.10.0.0/16"
}

variable "public-subnet-cidr" {
  default = "10.10.1.0/24"

}

variable "public-subnet-az" {
  default = "ap-southeast-1a"
}

variable "private-subnet-cidr" {
  default = "10.10.2.0/24"

}

variable "private-subnet-az" {
  default = "ap-southeast-1b"
}

variable "machine_image" {
  default     = "ami-0df7a207adb9748c7"
  description = "Ubuntu Server 22.04 LTS (HVM), SSD Volume Type"
}

variable "instance-type" {
  default = "t2.micro"
}