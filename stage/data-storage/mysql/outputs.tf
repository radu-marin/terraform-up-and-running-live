# provide db address and port to web server cluster
output "address" {
  value       = module.mysql_data.address
  description = "Connect to the database at this endpoint"
}
output "port" {
  value       = module.mysql_data.port
  description = "The port the database is listening on"
}