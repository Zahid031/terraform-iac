resource "aws_key_pair" "test_key" {
    key_name =   var.key_name
    public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_instance" "test_machine" {
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = aws_key_pair.test_key.key_name
}

connection {
    host = aws_instance.test_machine.public_ip
    type = "ssh"    
    user = var.INSTANCE_USER
    private_key = file(var.PATH_TO_PRIVATE_KEY)
}