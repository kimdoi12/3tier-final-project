# Private Key 생성
resource "tls_private_key" "aws_private_keypair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Key Pair 생성 (AWS에 공개키 등록)
resource "aws_key_pair" "aws-ssh-keypair" {
  key_name   = "3teamkey-pair" # AWS에 등록할 키 쌍 이름
  public_key = tls_private_key.aws_private_keypair.public_key_openssh

  tags = {
    Name = "3teamkey-pair"
  }
}

# 로컬에 Private Key 저장
resource "local_file" "test_private_key" {
  content  = tls_private_key.aws_private_keypair.private_key_pem
  filename = "${path.module}/3teamkey-pair.pem"  # 로컬에 저장할 파일 이름
  file_permission = "0600"
}

# Base64로 인코딩된 Private Key
locals {
  encoded_private_key = base64encode(local_file.test_private_key.content)
}