resource "aws_instance" "Bastion-Server" {
  ami                    = "ami-035da6a0773842f64"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.SEC-PUB-2A.id
  key_name               = "3teamkey-pair"
  source_dest_check      = false
  private_ip             = "10.10.7.77"
  user_data = templatefile("${path.module}/setting.sh", {
    private_key = local.encoded_private_key
  })
  vpc_security_group_ids = [aws_security_group.NAT-SG.id]
  
  tags = {
    Name = "Bastion-Server"
  }
}

resource "time_sleep" "mysql-delay" {
  depends_on = [aws_instance.Bastion-Server]
  create_duration = "30s"
}

resource "aws_instance" "DB-Server" {
  ami                    = "ami-042e76978adeb8c48"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.SEC-PRI-DB-2A.id
  vpc_security_group_ids = [aws_security_group.DB-SG.id]
  key_name               = "3teamkey-pair"
  user_data              = file("mysql.sh")
  
  private_ip             = "10.10.30.30"

  tags = {
    Name = "DB-Server"
  }
  
  depends_on = [ time_sleep.mysql-delay ]
}

resource "time_sleep" "db-delay" {
  depends_on = [aws_instance.DB-Server]
  create_duration = "30s"
}

resource "aws_instance" "DB-Replica-Server" {
  ami                    = "ami-042e76978adeb8c48"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.SEC-PRI-DB-2C.id
  vpc_security_group_ids = [aws_security_group.DB-SG.id]
  key_name               = "3teamkey-pair"
  user_data              = file("mysql1.sh")
  private_ip             = "10.10.130.30"
  tags = {
    Name = "DB-Replica-Server"
  }
  depends_on = [ time_sleep.db-delay ]
}

resource "time_sleep" "dbr-delay" {
  depends_on = [ aws_instance.DB-Replica-Server ]
  create_duration = "30s"
}

resource "aws_instance" "Tomcat-Server" {
  ami                    = "ami-042e76978adeb8c48"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.SEC-PRI-APP-2A.id
  vpc_security_group_ids = [aws_security_group.APP-SG.id]
  key_name               = "3teamkey-pair"
  user_data              = file("tomcat.sh")
  
  private_ip             = "10.10.20.20"

  tags = {
    Name = "Tomcat-Server"
  }
  depends_on = [ time_sleep.dbr-delay ]
}

resource "time_sleep" "tomcat-delay" {
  depends_on = [aws_instance.Tomcat-Server]
  create_duration = "3m"
}

resource "aws_instance" "Nginx-Server" {
  ami                    = "ami-08b09b6acd8d62254"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.SEC-PRI-WEB-2A.id
  vpc_security_group_ids = [aws_security_group.WEB-SG.id]
  key_name               = "3teamkey-pair"
  user_data              = file("nginx.sh")	// 파일로 작성해서 파일로 가져올 수 있다.
  private_ip             = "10.10.10.10"
  tags = {
    Name = "Nginx-Server"
  }
  depends_on = [ time_sleep.tomcat-delay ]
}

resource "time_sleep" "cicd-delay" {
  depends_on = [ aws_instance.Nginx-Server ]
  create_duration = "3m"
}

resource "aws_instance" "CICD-Server" {
  ami                    = "ami-042e76978adeb8c48"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.SEC-PUB-2C.id
  vpc_security_group_ids = [aws_security_group.NAT-SG.id]
  key_name               = "3teamkey-pair"
  user_data              = file("cicd.sh")
  private_ip             = "10.10.8.88"
  tags = {
    Name = "CICD-Server"
  }
  depends_on = [ time_sleep.cicd-delay ]
}