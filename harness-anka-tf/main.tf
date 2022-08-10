data "aws_ami" "anka" {
  most_recent = true

  filter {
    name   = "name"
    values = ["anka-build-2.5.6.147-macos-12.4-marketplace-enterprise*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

#   owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "anka" {
  key_name   = "terraform-cristian-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/MmswVP5iGUL7+3uPtulM5oZr7lJd9Omm9RK1nlm//VdIXWhNiyAr1kdDWJCReocdWEhmMVZmjGLDzSKlpZO8Rc0XiU+ibgK+HuoQQmnj25dhhFEeMRZppUCWoA3VgIxpHRgjnT8hacxz2DMuAov5MFwh5r/tdffh2RilSFVIYIo9iSWZabk2rKAHEwQLNK9BSIv285TS4ZGBFlxjuzJ6HfeI0Y1qC6vcYXYadbA5AizcMkrfQabUXRQxHtB2ix4OrtZycU1rGIYIjr1qZjiKgDceNNCYZaU6HqUWfm12/LYMV3qR3dJUtwnKP/4888uD/MEGQc0TvALELR7MkJ4ih18MMqYn+ks3p02rVflVFHdNULrAM/3ZlK+KpyoTnlfRgh75V8DgAKioCNL4JKFvXeDuo0z3Cu/loPb4mp7CrCdAPha2/jJPpknKKrpBvAqThUVVGn13LhMJxIgV9PK1FSvU1EF3Ul+NpEIvt4sxnsWSbnOPVgEQdxPwbpdoJX0= cristianramirez@MacBook-Pro-de-Cristian.local"
}

resource "aws_security_group" "allow_sg" {
  name        = "terraform_anka_allow_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-72c6b71a"

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "anka from VPC"
    from_port        = 9079
    to_port          = 9079
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "anka from VPC"
    from_port        = 5900
    to_port          = 5900
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "anka-osx"
  }
}

resource "aws_ec2_host" "test" {
  instance_type     = "mac1.metal"
  availability_zone = "us-east-2b"
  host_recovery     = "off"
  auto_placement    = "on"

  tags = {
      Owner   = "Cristian Ramirez"
      Squad   = "SE LATAM"
      Name    = "anka-osx"
      ttl     = "-1"
      App     = "anka ios builds"
      Purpose = "Demo ios builds with Harness"
  }
}

data "template_file" "user_data" {
  template = file("../contrib/anka-vms/user-data.tpl")
  vars = {
    NEW_PASSWORD     = var.anka_host_password
    VERSION          = "12.5"
    VM_NAME          = "harness-osx-runner"
    RAM_SIZE         = "8G"
    CPU_COUNT        = "4"
    DISK_SIZE        = "100G"
    ANKA_VM_USERNAME = var.anka_vm_username
    ANKA_VM_PASSWORD = var.anka_vm_password
    POOL_NAME        = "osx-anka"
  }
}

resource "aws_instance" "anka" {
  depends_on                  = [aws_ec2_host.test]
  ami                         = data.aws_ami.anka.id
  instance_type               = "mac1.metal"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_sg.id]
  availability_zone           = "us-east-2b"
  tenancy                     = "host"
  key_name                    = aws_key_pair.anka.key_name
  user_data                   = data.template_file.user_data.rendered
  
  ebs_block_device {
      device_name = "/dev/sda1"
      iops        = "6000"
      volume_size = 500
      volume_type = "gp3"
      throughput  = "256"
  }

  tags = {
      Owner   = "Cristian Ramirez"
      Squad   = "SE LATAM"
      Name    = "anka-osx"
      ttl     = "-1"
      App     = "anka ios builds"
      Purpose = "Demo ios builds with Harness"
  }
}

output "anka-vm" {
  value = {
    ssh        = "ssh -i anka ec2-user@${aws_instance.anka.public_ip}"
    ip_address = aws_instance.anka.public_ip
  }
}