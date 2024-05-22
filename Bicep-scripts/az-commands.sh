#!/bin/bash
SETUP_SCRIPT="C:\Users\jamie\Desktop\setup-azure-function.sh"


az login

# opret ressourcegruppe
ResourceGroup=AuktionsHusetRG
az group create --name $ResourceGroup --location northeurope

# deploy bicep fil

vaultIp=$(az deployment group create --resource-group $ResourceGroup --template-file auctionsGO.bicep --verbose  --query properties.outputs.vaultIp.value --o tsv)
echo "Key Vault URL: $vaultIp"

# her skal vi få vaultIp fra listen af container

$SETUP_SCRIPT $vaultIp
# Make a POST request to the Azure Function and save the response
