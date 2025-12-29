# Azure Function App Deployment Commands

This document provides a complete checklist and all commands used to deploy the Azure Cost Management & Orphaned Resources Analyzer Function App on a Premium EP1 plan with managed identity, storage, and permissions.

---

## 1. Create the Premium Function App

```powershell
# Set variables
$resourceGroup = "YOUR-RESOURCE-GROUP"
$location = "westeurope"
$planName = "plan-cost-agent-ai"
$functionAppName = "YOUR-FUNCTION-APP-NAME"
$storageAccount = "rgaicostcseustorage"  # Use your existing storage account

# Create Premium plan (EP1, Linux)
az functionapp plan create `
  --resource-group $resourceGroup `
  --name $planName `
  --location $location `
  --number-of-workers 1 `
  --sku EP1 `
  --is-linux

# Create Function App with managed identity
az functionapp create `
  --resource-group $resourceGroup `
  --plan $planName `
  --name $functionAppName `
  --storage-account $storageAccount `
  --runtime python `
  --runtime-version 3.11 `
  --os-type Linux `
  --assign-identity
```

---

## 2. Assign Managed Identity Permissions

```powershell
# Get the managed identity principal ID
$principalId = az functionapp identity show `
  --name $functionAppName `
  --resource-group $resourceGroup `
  --query principalId -o tsv

# Get the root management group ID
$rootMgmtGroupId = az account management-group show --name "Root" --query id -o tsv

# Assign roles at the root management group
az role assignment create `
  --assignee $principalId `
  --role "Reader" `
  --scope $rootMgmtGroupId

az role assignment create `
  --assignee $principalId `
  --role "Cost Management Reader" `
  --scope $rootMgmtGroupId

az role assignment create `
  --assignee $principalId `
  --role "Advisor Recommendations Contributor" `
  --scope $rootMgmtGroupId
```

---

## 3. Grant Storage Account Permissions

```powershell
# Assign Storage Blob Data Owner on the storage account
$storageScope = "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$resourceGroup/providers/Microsoft.Storage/storageAccounts/$storageAccount"

az role assignment create `
  --assignee $principalId `
  --role "Storage Blob Data Owner" `
  --scope $storageScope
```

---

## 4. Prepare the Deployment Package

```powershell
# Create deployment ZIP (include all code, config, and required folders)
-DestinationPath deploy.ziCompress-Archive -Path function_app.py,host.json,requirements.txt p -Force
```

---

## 5. Deploy to Azure Function App

### Option A: Using Azure Functions Core Tools
```powershell
func azure functionapp publish YOUR-FUNCTION-APP-NAME --python
```

### Option B: Using Azure CLI ZIP Deploy
```powershell
az functionapp deployment source config-zip `
  --resource-group $resourceGroup `
  --name $functionAppName `
  --src deploy.zip
```

---

## 6. Verify Deployment

```powershell
az functionapp function list `
  --resource-group $resourceGroup `
  --name $functionAppName `
  --output table

az functionapp log stream `
  --resource-group $resourceGroup `
  --name $functionAppName
```

---

## 7. Set Application Settings (Optional)

```powershell
az functionapp config appsettings set `
  --name $functionAppName `
  --resource-group $resourceGroup `
  --settings "ENVIRONMENT=production"
```

---

## 8. Manual ZIP Upload & Run-From-Package (Alternative)

  ```powershell
  # Upload ZIP to storage
  $storageKey = az storage account keys list `
    --account-name $storageAccount `
    --resource-group $resourceGroup `
    --query "[0].value" --output tsv

  az storage blob upload `
    --account-name $storageAccount `
    --account-key $storageKey `
    --container-name "deploymentpackage" `
    --name "functionapp.zip" `
    --file "deploy.zip" `
    --overwrite

  # Generate SAS URL
  $blobSas = az storage blob generate-sas `
    --account-name $storageAccount `
    --account-key $storageKey `
    --container-name "deploymentpackage" `
    --name "functionapp.zip" `
    --permissions r `
    --expiry (Get-Date).AddDays(1).ToString("yyyy-MM-dd") `
    --output tsv

  $blobUrl = "https://$storageAccount.blob.core.windows.net/deploymentpackage/functionapp.zip?$blobSas"

  # Configure Function App to run from package
  az functionapp config appsettings set `
    --resource-group $resourceGroup `
    --name $functionAppName `
    --settings "WEBSITE_RUN_FROM_PACKAGE=$blobUrl"

  az functionapp restart --resource-group $resourceGroup --name $functionAppName
  ```

---

## 9. Troubleshooting
- Ensure all required blob containers exist in the storage account:
  - `azure-webjobs-hosts`, `azure-webjobs-secrets`, `deploymentpackage`, `scm-deployments`, `azure-functions-deployment`
- If you get 404 errors, verify storage account linkage and permissions.
- Use log streaming to debug deployment issues.

---

## 10. Post-Deployment
- Update agent configuration files in `Agents/` with the new function app name and keys.
- Test all endpoints and integration with Azure AI Foundry.

---



To test your function directly from the Azure Portal, you need to allow CORS for https://portal.azure.com. Here’s how to do it:


 az functionapp cors add -g YOUR-RESOURCE-GROUP -n YOUR-FUNCTION-APP-NAME --allowed-origins https://portal.azure.com                   


Test in azure portal - 
{
    "subscription_id": "YOUR-SUBSCRIPTION-ID",
    "query_type": "subscription",
    "start_date": "2025-09-01T00:00:00Z",
    "end_date": "2025-09-30T23:59:59Z",
    "granularity": "Daily"



    {
  "single_subscription_analysis": {
    "subscription_id": "YOUR-SUBSCRIPTION-ID",
    "resource_types": [
      "Public IP",
      "Managed Disk",
      "Snapshot",
      "Network Interface"
    ],
    "resource_group": "your-resource-group",
    "location": "eastus"
  },
  "tenant_wide_analysis": {
    "resource_types": [
      "Public IP",
      "Managed Disk"
    ],
    "location": "eastus",
    "subscription_name": "Production Subscription"
  },
  "all_resources_all_subscriptions": {
    "description": "Analyze all resource types across all subscriptions in the tenant"
  }
}