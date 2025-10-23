#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick deployment script for Azure Cost Management Functions

.DESCRIPTION
    This script provides a simplified deployment experience with minimal parameters.
    It creates a resource group and deploys all resources in one command.

.PARAMETER SubscriptionId
    Azure subscription ID to deploy to

.PARAMETER Location
    Azure region to deploy to (default: East US)

.PARAMETER Environment
    Environment suffix for resource naming (default: prod)

.EXAMPLE
    .\quick-deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012"

.EXAMPLE
    .\quick-deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -Location "West US 2" -Environment "dev"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "East US",
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("dev", "test", "prod")]
    [string]$Environment = "prod"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Generate names
$ResourceGroupName = "rg-costanalysis-$Environment"
$DeploymentName = "CostAnalysis-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host ""
Write-Host "=================================================" -ForegroundColor Green
Write-Host "🚀 Quick Azure Cost Management Deployment" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Deployment Details:" -ForegroundColor Cyan
Write-Host "   Subscription: $SubscriptionId" -ForegroundColor White
Write-Host "   Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "   Location: $Location" -ForegroundColor White
Write-Host "   Environment: $Environment" -ForegroundColor White
Write-Host ""

# Set subscription
Write-Host "🔧 Setting active subscription..." -ForegroundColor Yellow
try {
    az account set --subscription $SubscriptionId
    $currentSub = az account show --query "name" -o tsv
    Write-Host "✅ Active subscription: $currentSub" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to set subscription: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Create resource group
Write-Host ""
Write-Host "📁 Creating resource group..." -ForegroundColor Yellow
try {
    $rgExists = az group exists --name $ResourceGroupName
    if ($rgExists -eq "true") {
        Write-Host "✅ Resource group '$ResourceGroupName' already exists" -ForegroundColor Green
    } else {
        az group create --name $ResourceGroupName --location $Location
        Write-Host "✅ Resource group '$ResourceGroupName' created successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Failed to create resource group: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Deploy resources
Write-Host ""
Write-Host "🏗️ Deploying Azure resources..." -ForegroundColor Yellow
try {
    $deploymentResult = az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file "$ScriptDir/simple.bicep" `
        --parameters environment=$Environment location=$Location `
        --name $DeploymentName `
        --query 'properties.outputs' `
        --output json | ConvertFrom-Json

    Write-Host "✅ Infrastructure deployment completed successfully!" -ForegroundColor Green
    
    # Extract outputs
    $functionAppName = $deploymentResult.functionAppName.value
    $functionAppUrl = $deploymentResult.functionAppUrl.value
    
    Write-Host ""
    Write-Host "📊 Deployment Results:" -ForegroundColor Cyan
    Write-Host "   Function App Name: $functionAppName" -ForegroundColor White
    Write-Host "   Function App URL: $functionAppUrl" -ForegroundColor White
    
} catch {
    Write-Host "❌ Infrastructure deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Deploy function code
Write-Host ""
Write-Host "📦 Deploying function code..." -ForegroundColor Yellow
try {
    Push-Location
    Set-Location (Split-Path $ScriptDir -Parent)  # Go to project root
    
    # Check if function code exists
    if (Test-Path "function_app.py") {
        func azure functionapp publish $functionAppName --python
        Write-Host "✅ Function code deployed successfully!" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Function code not found. Skipping code deployment." -ForegroundColor Yellow
        Write-Host "   Run 'func azure functionapp publish $functionAppName --python' later to deploy your code." -ForegroundColor White
    }
} catch {
    Write-Host "⚠️ Function code deployment failed: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "   You can manually deploy later using: func azure functionapp publish $functionAppName --python" -ForegroundColor White
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "🎉 Deployment completed!" -ForegroundColor Green
Write-Host ""
Write-Host "🔗 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Test your functions at: $functionAppUrl" -ForegroundColor White
Write-Host "2. Get function keys from: Azure Portal → Function App → Functions → Function Keys" -ForegroundColor White
Write-Host "3. Update your Azure AI Foundry agent configurations with the new endpoints" -ForegroundColor White
Write-Host ""
Write-Host "📋 Useful Commands:" -ForegroundColor Cyan
Write-Host "   View logs: func azure functionapp logstream $functionAppName" -ForegroundColor White
Write-Host "   Monitor: https://portal.azure.com/#@/resource/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$functionAppName" -ForegroundColor White
Write-Host ""