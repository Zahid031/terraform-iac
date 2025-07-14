variable "test" {
    type = string
    default = "test_value"
}

#input variable condition

# variable "input_variable_condition" {
#     type = string
#     default = "input_condition"

#     validation {
#       condition = contains(["east","west"],lower(var.input_variable_condition))
#       error_message = "Unsupported region"
#     }
# }
  

#Input variable types

#Primitive types --->1.boolean, 2.number, 3.string
#Complex types ---->1.list, 2.map, 3.object
#structure types--->1.structure,tuple



variable "AWS_REGION" {
  type = string
  default = "us-east-1"
}