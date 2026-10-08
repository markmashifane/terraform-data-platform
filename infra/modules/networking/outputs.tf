output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "data_subnet_id" {
  value = azurerm_subnet.data_subnet.id
}