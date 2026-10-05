output "public_subnet_a_id" { value = aws_subnet.public_a.id }
output "public_subnet_b_id" { value = aws_subnet.public_b.id }
output "public_subnet_ids" { value = [aws_subnet.public_a.id, aws_subnet.public_b.id] }
output "private_app_subnet_ids" { value = [aws_subnet.private_app_a.id, aws_subnet.private_app_b.id] }
output "private_db_subnet_ids" { value = [aws_subnet.private_db_a.id, aws_subnet.private_db_b.id] }
