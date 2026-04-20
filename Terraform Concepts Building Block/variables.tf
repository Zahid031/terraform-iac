variable "PATH_TO_PUBLIC_KEY" {
    type = string
    default = "/home/ubuntu/.ssh/id_rsa.pub"
}

variable "key_name" {
    type = string
    default = "test_key"
}

variable "ami_id" {
    type = string
    default = "ami-0e7ff22101b84bcff"
}
variable "instance_type" {
    type = string
    default = "t3.micro"
}