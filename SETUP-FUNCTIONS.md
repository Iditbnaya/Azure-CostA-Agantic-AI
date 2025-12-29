# 🔧 Azure Functions Deployment Guide

Complete guide for deploying the Azure Functions backend for Cost Management & Orphaned Resources Analyzer.

## 📋 Prerequisites Checklist

- [ ] Azure CLI installed and logged in (`az login`)
- [ ] PowerShell 5.1 or PowerShell Core
- [ ] Python 3.11 installed
- [ ] Azure Functions Core Tools v4 installed
- [ ] Valid Azure subscription with appropriate permissions
- [ ] Git installed (for code deployment)

### Verify Prerequisites

```powershell
# Check Azure CLI
az --version

# Check Python version
python --version  # Should be 3.11.x

# Check Azure Functions Core Tools
func --version  # Should be 4.x

# Verify Azure login
az account show
```

## ⚡ Quick Start (Automated)

### Run Automated Deployment Script

```powershell
# Navigate to repository
cd Azure-CostA-Agantic-AI

# Run automated setup
.\setup.ps1 -ResourceGroupName "rg-cost-analyzer-prodv1

# Optional: Specify location
.\setup.ps1 -ResourceGroupName "rg-cost-analyzer-prod" -Location "eastus2"
```

### What the Script Does

- ✅ Validates all prerequisites
- ✅ Creates Azure Resource Group
- ✅ Creates Storage Account (required for Functions)
- ✅ Creates Premium Function App with Python 3.11
- ✅ Configures System-Assigned Managed Identity
- ✅ Assigns required RBAC permissions (Reader, Cost Management Reader)
- ✅ Deploys function code from local directory
- ✅ Sets up Application Insights for monitoring
- ✅ Retrieves and displays function keys
- ✅ Validates deployment with health checks

## 📖 Manual Deployment Steps

### Step 1: Create Resource Group

```powershell
$resourceGroup = "rg-cost-analyzer-prodv1
$location = "eastus2"

az group create `
  --name $resourceGroup `
  --location $location
```

### Step 2: Create Storage Account

```powershell
$storageAccount = "stcostanalyzer$(Get-Random -Minimum 1000 -Maximum 9999)"

az storage account create `
  --name $storageAccount `
  --resource-group $resourceGroup `
  --location $location `
  --sku Standard_LRS
```

### Step 3: Create Application Insights

```powershell
$appInsights = "ai-cost-analyzerv1

az monitor app-insights component create `
  --app $appInsights `
  --resource-group $resourceGroup `
  --location $location `
  --application-type web
```

### Step 4: Create Function App

```powershell
$functionApp = "func-cost-analyzer-$(Get-Random -Minimum 1000 -Maximum 9999)"

az functionapp create `
  --name $functionApp `
  --resource-group $resourceGroup `
  --storage-account $storageAccount `
  --consumption-plan-location $location `
  --runtime python `
  --runtime-version 3.11 `
  --functions-version 4 `
  --os-type Linux `
  --app-insights $appInsights
```

**Note**: For production, consider using Premium plan (EP1, EP2, EP3) for better performance.

### Step 5: Enable Managed Identity

```powershell
az functionapp identity assign `
  --name $functionApp `
  --resource-group $resourceGroup
```

### Step 6: Assign RBAC Permissions

```powershell
# Get subscription ID
$subscriptionId = (az account show --query id -o tsv)

# Get Managed Identity Principal ID
$principalId = az functionapp identity show `
  --name $functionApp `
  --resource-group $resourceGroup `
  --query principalId -o tsv

# Assign Reader role
az role assignment create `
  --assignee $principalId `
  --role "Reader" `
  --scope "/subscriptions/$subscriptionId"

# Assign Cost Management Reader role
az role assignment create `
  --assignee $principalId `
  --role "Cost Management Reader" `
  --scope "/subscriptions/$subscriptionId"
```

### Step 7: Deploy Function Code

```powershell
# Install Python dependencies locally
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Deploy to Azure
func azure functionapp publish $functionApp
```

### Step 8: Retrieve Function Keys

```powershell
# Get master key
$masterKey = az functionapp keys list `
  --name $functionApp `
  --resource-group $resourceGroup `
  --query masterKey -o tsv

Write-Host "Master Key: $masterKey"

# Get function URL
$functionUrl = "https://$functionApp.azurewebsites.net"
Write-Host "Function URL: $functionUrl"
```

## 🧪 Testing Your Deployment

### Test Example Endpoints (No Authentication)

```powershell
$functionApp = "your-function-app-name"

# Test orphaned resources example
Invoke-RestMethod -Uri "https://$functionApp.azurewebsites.net/api/orphaned-resources-example"

# Test cost example
Invoke-RestMethod -Uri "https://$functionApp.azurewebsites.net/api/cost-example"
```

### Test Authenticated Endpoints

```powershell
$functionApp = "your-function-app-name"
$masterKey = "your-master-key"
$subscriptionId = "your-subscription-id"

# Test orphaned resources detection
$payload = @{
    subscription_id = $subscriptionId
    resource_types = @("PublicIPAddresses", "NetworkInterfaces", "Disks")
} | ConvertTo-Json

Invoke-RestMethod `
  -Uri "https://$functionApp.azurewebsites.net/api/orphaned-resources?code=$masterKey" `
  -Method POST `
  -Body $payload `
  -ContentType "application/json"

# Test cost analysis
$costPayload = @{
    subscription_id = $subscriptionId
    scope = "subscription"
    time_period = "last30days"
} | ConvertTo-Json

Invoke-RestMethod `
  -Uri "https://$functionApp.azurewebsites.net/api/cost-analysis?code=$masterKey" `
  -Method POST `
  -Body $costPayload `
  -ContentType "application/json"
```

## 🔍 Verify Deployment

### Check Function App Status

```powershell
az functionapp show `
  --name $functionApp `
  --resource-group $resourceGroup `
  --query "{Name:name, State:state, DefaultHostName:defaultHostName}"
```

### View Function Logs

```powershell
# Stream logs in real-time
az functionapp log tail `
  --name $functionApp `
  --resource-group $resourceGroup
```

### Check Application Insights

```powershell
# Get Application Insights instrumentation key
az monitor app-insights component show `
  --app $appInsights `
  --resource-group $resourceGroup `
  --query instrumentationKey -o tsv
```

## 📊 Available API Endpoints

| Endpoint | Method | Authentication | Purpose |
|----------|--------|---------------|---------|
| `/api/orphaned-resources` | POST | Required | Detect orphaned resources |
| `/api/orphaned-resources-example` | GET | None | Example response |
| `/api/cost-analysis` | POST | Required | Analyze costs |
| `/api/cost-example` | GET | None | Example response |

## 🔒 Security Configuration

### Enable Security Features

```powershell
# Enable HTTPS only
az functionapp update `
  --name $functionApp `
  --resource-group $resourceGroup `
  --set httpsOnly=true

# Set minimum TLS version
az functionapp config set `
  --name $functionApp `
  --resource-group $resourceGroup `
  --min-tls-version 1.2
```

### Configure CORS (if needed)

```powershell
az functionapp cors add `
  --name $functionApp `
  --resource-group $resourceGroup `
  --allowed-origins "https://yourdomain.com"
```

## 🔧 Configuration Settings

### Set Application Settings

```powershell
az functionapp config appsettings set `
  --name $functionApp `
  --resource-group $resourceGroup `
  --settings @(
    "ENABLE_ORYX_BUILD=true"
    "SCM_DO_BUILD_DURING_DEPLOYMENT=true"
    "PYTHON_ENABLE_WORKER_EXTENSIONS=1"
  )
```

## 🆘 Troubleshooting

### Common Issues

**Issue**: Function app deployment fails
```powershell
# Check deployment logs
az functionapp log deployment show `
  --name $functionApp `
  --resource-group $resourceGroup
```

**Issue**: Permission denied errors
```powershell
# Verify role assignments
az role assignment list `
  --assignee $principalId `
  --subscription $subscriptionId
```

**Issue**: Function not responding
```powershell
# Restart function app
az functionapp restart `
  --name $functionApp `
  --resource-group $resourceGroup
```

## 📈 Monitoring Setup

### Enable Diagnostic Settings

```powershell
az monitor diagnostic-settings create `
  --name "diag-func-cost-analyzer" `
  --resource "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Web/sites/$functionApp" `
  --logs '[{"category": "FunctionAppLogs", "enabled": true}]' `
  --metrics '[{"category": "AllMetrics", "enabled": true}]' `
  --workspace "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.OperationalInsights/workspaces/$workspace"
```

## 🎯 Next Steps

After successful function deployment:

- [ ] Test all endpoints to verify functionality
- [ ] Review Application Insights for any errors
- [ ] Document your function URLs and keys securely
- [ ] Set up monitoring alerts in Azure Monitor
- [ ] Configure auto-scaling if using Premium plan
- [ ] Proceed to [SETUP-FOUNDRY.md](SETUP-FOUNDRY.md) for AI Foundry agent deployment

## 📚 Additional Resources

- [Azure Functions Python Developer Guide](https://learn.microsoft.com/azure/azure-functions/functions-reference-python)
- [Managed Identity Best Practices](https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview)
- [Azure Cost Management API](https://learn.microsoft.com/rest/api/cost-management/)
- [Application Insights for Azure Functions](https://learn.microsoft.com/azure/azure-functions/functions-monitoring)

---

**✅ Deployment Complete!** Your Azure Functions backend is ready. Continue to [SETUP-FOUNDRY.md](SETUP-FOUNDRY.md) to configure AI agents.
