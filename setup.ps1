# Azure Cost Management Solution - Quick Setup Script
# Run this script in PowerShell with Administrator privileges

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "swedencentral",
    
    [Parameter(Mandatory=$false)]
    [string]$FunctionAppPrefix = "func-cost-analyzer-ai"
)

# Script configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host "🚀 Azure Cost Management Solution - Quick Setup" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green

# Function to check prerequisites
function Test-Prerequisites {
    Write-Host "✅ Checking prerequisites..." -ForegroundColor Yellow
    
    # Check Azure CLI
    try {
        $azVersion = az --version 2>$null
        Write-Host "   ✓ Azure CLI installed" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Azure CLI not found. Please install: https://docs.microsoft.com/cli/azure/install-azure-cli"
        exit 1
    }
    
    # Check Python 3.11
    try {
        $pythonVersion = python --version 2>$null
        if ($pythonVersion -match "Python 3\.11") {
            Write-Host "   ✓ Python 3.11 found: $pythonVersion" -ForegroundColor Green
        } else {
            Write-Warning "   ⚠️  Python version: $pythonVersion (3.11 recommended)"
        }
    }
    catch {
        Write-Error "❌ Python not found. Please install Python 3.11"
        exit 1
    }
    
    # Check Azure Functions Core Tools
    try {
        $funcVersion = func --version 2>$null
        Write-Host "   ✓ Azure Functions Core Tools: $funcVersion" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Azure Functions Core Tools not found. Please install: https://docs.microsoft.com/azure/azure-functions/functions-run-local"
        exit 1
    }
    
    # Check Azure login
    try {
        $account = az account show --query "name" -o tsv 2>$null
        Write-Host "   ✓ Logged into Azure: $account" -ForegroundColor Green
    }
    catch {
        Write-Host "   ⚠️  Not logged into Azure. Running az login..." -ForegroundColor Yellow
        az login
    }
}

# Function to generate random suffix
function Get-RandomSuffix {
    return -join ((65..90) + (97..122) | Get-Random -Count 6 | ForEach-Object {[char]$_})
}

# Main setup function
function Deploy-Solution {
    param($rgName, $loc, $funcPrefix)
    
    Write-Host "🏗️  Starting Azure resource deployment..." -ForegroundColor Yellow
    
    # Generate unique names
    $randomSuffix = Get-RandomSuffix
    $functionAppName = "$funcPrefix-$randomSuffix"
    $storageAccountName = "sa$($randomSuffix.ToLower())"
    $appServicePlan = "plan-cost-analyzer-$randomSuffix"
    $subscriptionId = az account show --query id -o tsv
    
    Write-Host "📋 Configuration:" -ForegroundColor Cyan
    Write-Host "   Resource Group: $rgName"
    Write-Host "   Location: $loc"
    Write-Host "   Function App: $functionAppName"
    Write-Host "   Storage Account: $storageAccountName"
    Write-Host "   Service Plan: $appServicePlan"
    Write-Host ""
    
    # Create resource group
    Write-Host "📁 Creating resource group..." -ForegroundColor Yellow
    az group create --name $rgName --location $loc --output none
    Write-Host "   ✓ Resource group created" -ForegroundColor Green
    
    # Create storage account
    Write-Host "💾 Creating storage account..." -ForegroundColor Yellow
    az storage account create `
        --name $storageAccountName `
        --resource-group $rgName `
        --location $loc `
        --sku Standard_LRS `
        --kind StorageV2 `
        --output none
    Write-Host "   ✓ Storage account created" -ForegroundColor Green
    
    # Create service plan
    Write-Host "⚡ Creating App Service Plan (Premium EP1)..." -ForegroundColor Yellow
    az functionapp plan create `
        --resource-group $rgName `
        --name $appServicePlan `
        --location $loc `
        --number-of-workers 1 `
        --sku EP1 `
        --is-linux `
        --output none
    Write-Host "   ✓ App Service Plan created" -ForegroundColor Green
    
    # Create Function App
    Write-Host "🔧 Creating Function App..." -ForegroundColor Yellow
    $createResult = az functionapp create `
        --resource-group $rgName `
        --plan $appServicePlan `
        --name $functionAppName `
        --storage-account $storageAccountName `
        --runtime python `
        --runtime-version 3.11 `
        --os-type Linux `
        --assign-identity `
        --functions-version 4 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create Function App. Error: $createResult"
        throw "Function App creation failed"
    }
    
    Write-Host "   ✓ Function App created with Managed Identity" -ForegroundColor Green
    
    # Wait for function app to be fully provisioned
    Write-Host "   ⏳ Waiting for Function App to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    
    # Get Managed Identity Principal ID
    Write-Host "🆔 Configuring Managed Identity permissions..." -ForegroundColor Yellow
    
    # Retry logic for getting principal ID (can take time to propagate)
    $retryCount = 0
    $maxRetries = 5
    $principalId = $null
    
    while ($retryCount -lt $maxRetries -and [string]::IsNullOrEmpty($principalId)) {
        $principalId = az functionapp identity show --name $functionAppName --resource-group $rgName `
            --query principalId -o tsv 2>$null
        
        if ([string]::IsNullOrEmpty($principalId)) {
            $retryCount++
            Write-Host "   ⏳ Waiting for Managed Identity to be ready (attempt $retryCount/$maxRetries)..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
        }
    }
    
    if ([string]::IsNullOrEmpty($principalId)) {
        Write-Error "Failed to retrieve Managed Identity Principal ID after $maxRetries attempts"
        throw "Managed Identity configuration failed"
    }
    $storageScope = "/subscriptions/$subscriptionId/resourceGroups/$rgName/providers/Microsoft.Storage/storageAccounts/$storageAccountName"
    az role assignment create `
        --assignee $principalId `
        --role "Storage Blob Data Owner" `
        --scope $storageScope `
        --output none
    
    # Assign subscription-level permissions
    $subscriptionScope = "/subscriptions/$subscriptionId"
    
    az role assignment create `
        --assignee $principalId `
        --role "Reader" `
        --scope $subscriptionScope `
        --output none
    
    az role assignment create `
        --assignee $principalId `
        --role "Cost Management Reader" `
        --scope $subscriptionScope `
        --output none
    
    az role assignment create `
        --assignee $principalId `
        --role "Advisor Recommendations Contributor" `
        --scope $subscriptionScope `
        --output none
    
    Write-Host "   ✓ Managed Identity permissions configured" -ForegroundColor Green
    
    # Configure application settings
    Write-Host "⚙️  Configuring application settings..." -ForegroundColor Yellow
    az functionapp config appsettings set `
        --name $functionAppName `
        --resource-group $rgName `
        --settings `
            "ENVIRONMENT=production" `
            "AZURE_CLIENT_ID=$principalId" `
            "ENABLE_ORYX_BUILD=true" `
            "SCM_DO_BUILD_DURING_DEPLOYMENT=true" `
            "PYTHON_ENABLE_WORKER_EXTENSIONS=1" `
        --output none
    Write-Host "   ✓ Application settings configured" -ForegroundColor Green
    
    # Deploy function code (if in project directory)
    if (Test-Path "function_app.py") {
        Write-Host "📦 Deploying function code..." -ForegroundColor Yellow
        Write-Host "   This may take 2-3 minutes..." -ForegroundColor Yellow
        
        $deployOutput = func azure functionapp publish $functionAppName --python 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✓ Function code deployed successfully" -ForegroundColor Green
        }
        else {
            Write-Host "   ⚠️  Function deployment encountered an error" -ForegroundColor Yellow
            Write-Host "   Error details: $deployOutput" -ForegroundColor Red
            Write-Host "   💡 You can deploy manually with: func azure functionapp publish $functionAppName" -ForegroundColor Cyan
        }
    } else {
        Write-Host "   ⚠️  function_app.py not found in current directory. Skipping code deployment." -ForegroundColor Yellow
        Write-Host "   💡 Navigate to the project directory and run: func azure functionapp publish $functionAppName" -ForegroundColor Cyan
    }
    
    # Get function keys
    Write-Host "🔑 Retrieving function keys..." -ForegroundColor Yellow
    
    # Retry logic for getting function keys (can take time after deployment)
    $retryCount = 0
    $maxRetries = 3
    $masterKey = $null
    
    while ($retryCount -lt $maxRetries -and [string]::IsNullOrEmpty($masterKey)) {
        Start-Sleep -Seconds 10
        $masterKey = az functionapp keys list `
            --name $functionAppName `
            --resource-group $rgName `
            --query "masterKey" -o tsv 2>$null
        
        if ([string]::IsNullOrEmpty($masterKey)) {
            $retryCount++
            Write-Host "   ⏳ Waiting for function keys to be available (attempt $retryCount/$maxRetries)..." -ForegroundColor Yellow
        }
    }
    
    if ([string]::IsNullOrEmpty($masterKey)) {
        Write-Host "   ⚠️  Could not retrieve function keys automatically. Get them from Azure Portal." -ForegroundColor Yellow
        $masterKey = "GET_FROM_PORTAL"
    } else {
        Write-Host "   ✓ Function keys retrieved" -ForegroundColor Green
    }
    
    # Create Application Insights
    Write-Host "📊 Creating Application Insights..." -ForegroundColor Yellow
    az monitor app-insights component create `
        --app "appinsights-$randomSuffix" `
        --resource-group $rgName `
        --location $loc `
        --output none
    
    $appInsightsKey = az monitor app-insights component show `
        --app "appinsights-$randomSuffix" `
        --resource-group $rgName `
        --query "instrumentationKey" -o tsv
    
    az functionapp config appsettings set `
        --name $functionAppName `
        --resource-group $rgName `
        --settings "APPINSIGHTS_INSTRUMENTATIONKEY=$appInsightsKey" `
        --output none
    
    Write-Host "   ✓ Application Insights configured" -ForegroundColor Green
    
    return @{
        FunctionAppName = $functionAppName
        ResourceGroup = $rgName
        StorageAccount = $storageAccountName
        PrincipalId = $principalId
        MasterKey = $masterKey
        SubscriptionId = $subscriptionId
    }
}

# Function to display next steps
function Show-NextSteps {
    param($deploymentInfo)
    
    Write-Host ""
    Write-Host "🎉 Deployment completed successfully!" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Deployment Summary:" -ForegroundColor Cyan
    Write-Host "   Function App Name: $($deploymentInfo.FunctionAppName)" -ForegroundColor White
    Write-Host "   Resource Group: $($deploymentInfo.ResourceGroup)" -ForegroundColor White
    Write-Host "   Function URL: https://$($deploymentInfo.FunctionAppName).azurewebsites.net" -ForegroundColor White
    Write-Host "   Managed Identity ID: $($deploymentInfo.PrincipalId)" -ForegroundColor White
    
    if ($deploymentInfo.MasterKey -ne "GET_FROM_PORTAL") {
        Write-Host "   Master Key: $($deploymentInfo.MasterKey)" -ForegroundColor Yellow
        Write-Host "   ⚠️  IMPORTANT: Store this key securely!" -ForegroundColor Red
    } else {
        Write-Host "   Master Key: Available in Azure Portal" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "🔗 Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Test your function endpoints:"
    Write-Host "   GET  https://$($deploymentInfo.FunctionAppName).azurewebsites.net/api/orphaned-resources-example"
    Write-Host "   GET  https://$($deploymentInfo.FunctionAppName).azurewebsites.net/api/cost-example"
    Write-Host ""
    Write-Host "2. Configure Azure AI Foundry agents:"
    Write-Host "   - Update Agents/Agent-OrphanedResources.txt with function details"
    Write-Host "   - Update Agents/Agent-Orphaned-Cost.txt with function details"
    Write-Host "   - Replace YOUR-FUNCTION-APP-NAME with: $($deploymentInfo.FunctionAppName)"
    Write-Host "   - Replace YOUR-FUNCTION-KEY with your master key"
    Write-Host ""
    Write-Host "3. Set up security pipeline (if not done):"
    Write-Host "   - Install pre-commit hooks: pip install pre-commit && pre-commit install"
    Write-Host "   - Configure GitHub branch protection rules"
    Write-Host ""
    Write-Host "4. Monitor your deployment:"
    Write-Host "   - Azure Portal: Resource Groups → $($deploymentInfo.ResourceGroup)"
    Write-Host "   - Application Insights for monitoring and logs"
    Write-Host ""
    Write-Host "📚 Full documentation available in INSTRUCTIONS.md" -ForegroundColor Green
}

# Main execution
try {
    Test-Prerequisites
    $deploymentResult = Deploy-Solution -rgName $ResourceGroupName -loc $Location -funcPrefix $FunctionAppPrefix
    Show-NextSteps -deploymentInfo $deploymentResult
    
    # Create summary file
    $summaryFile = "deployment-summary-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    $deploymentResult | Out-File -FilePath $summaryFile
    Write-Host "💾 Deployment details saved to: $summaryFile" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check the error and try again, or refer to INSTRUCTIONS.md for manual setup." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "✨ Setup completed! Your Azure Cost Management solution is ready to use." -ForegroundColor Green