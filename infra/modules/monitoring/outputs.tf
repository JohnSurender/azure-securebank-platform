output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.this.id
}
output "app_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}
output "action_group_id" {
  description = "On-call action group ID"
  value       = azurerm_monitor_action_group.oncall.id
}
