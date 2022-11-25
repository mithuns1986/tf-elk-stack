output "secret_key" {
    value = aws_secretsmanager_secret.sandbox_pitstop_secretes.id
}
output "secret_key_name" {
    value = aws_secretsmanager_secret.sandbox_pitstop_secretes.name
}
