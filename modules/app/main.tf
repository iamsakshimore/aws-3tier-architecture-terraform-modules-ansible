resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  vpc_id      = var.vpc_id
  description = "Allow traffic only from web tier"

  # Allow ONLY web tier to access app
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.web_sg_id]
  }

  # OPTIONAL: SSH only for admin (better remove in production)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.web_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}
resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = var.key_name

  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 php php-mysql -y

              systemctl start apache2
              systemctl enable apache2

              cat <<'PHP' > /var/www/html/submit.php
              <?php
              $conn = new mysqli("DB_ENDPOINT","admin","password","mydb");

              if ($conn->connect_error) {
                  die("Connection failed");
              }

              $name  = $_POST['name'];
              $email = $_POST['email'];

              $sql = "INSERT INTO users(name,email) VALUES('$name','$email')";
              $conn->query($sql);

              echo "Data inserted successfully";
              ?>
              PHP
              EOF

  tags = {
    Name = "app-instance"
  }
}