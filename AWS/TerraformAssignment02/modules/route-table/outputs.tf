output "public_route_table_id" { value = aws_route_table.public.id }
output "private_app_route_table_id" { value = aws_route_table.private_app.id }
output "private_db_route_table_id" { value = aws_route_table.private_db.id }
