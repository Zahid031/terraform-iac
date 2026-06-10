variable "project"            { type = string }
variable "environment"        { type = string }
variable "region"             { type = string }
variable "kubernetes_version" {
    type = string
    default = "1.32"
    }
variable "vpc_cni_version"    { 
    type = string
    default = "v1.19.2-eksbuild.1" 
    }
variable "coredns_version"    { 
    type = string 
    default = "v1.11.4-eksbuild.2" 
    }
variable "kube_proxy_version" { 
    type = string 
    default = "v1.32.0-eksbuild.2" 
    }
variable "tags" {    
    type = map(string) 
    default = {} 
    }
