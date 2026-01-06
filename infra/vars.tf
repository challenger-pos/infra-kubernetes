variable "projectName" {
  default = "challengeone-g19"
}

variable "region_default" {
  default = "us-east-2"
}

variable "cidr_vpc" {
  default = "10.0.0.0/16"
}

variable "tags" {
  default = {
    Name = "g19-challengeone"
  }
  
}