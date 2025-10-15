output "resource_group" {
  description = "The name of the resource group created"
  value       = azurerm_resource_group.rg.name
}

output "load_balancer_public_ip" {
  description = "The public IP address of the load balancer"
  value       = azurerm_public_ip.lb_pip.ip_address
}

output "application_gateway_public_ip" {
  description = "The public IP address of the application gateway"
  value       = azurerm_public_ip.lb_pip.ip_address
}

output "sql_fqdn" {
  description = "The fully qualified domain name of the Azure SQL Server"
  value       = azurerm_mssql_server.sqlserver.fully_qualified_domain_name
}

output "key_vault_id" {
  description = "The ID of the created Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "database_vm_private_ip" {
  description = "Private IP address of the DB VM"
  value       = azurerm_network_interface.db_nic.private_ip_address
}

output "backup_vault_id" {
  description = "The ID of the Backup Vault"
  value       = azurerm_recovery_services_vault.backup_vault.id
}

