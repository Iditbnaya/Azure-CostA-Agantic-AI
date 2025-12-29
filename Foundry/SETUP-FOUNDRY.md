# 🤖 Azure AI Foundry Agent Deployment Guide

Complete guide for deploying AI agents in Azure AI Foundry (formerly Azure AI Studio) for intelligent cost optimization and orphaned resource management.

## 📋 Prerequisites

Before configuring AI Foundry agents, ensure you have:

- [ ] **Azure Functions deployed** ([SETUP-FUNCTIONS.md](SETUP-FUNCTIONS.md))
- [ ] Function App URL and Master Key
- [ ] Azure AI Foundry access ([ai.azure.com](https://ai.azure.com))
- [ ] Appropriate permissions to create agents
- [ ] OpenAI or Azure OpenAI deployment

## 🚀 Quick Start

### Step 1: Gather Required Information

From your Azure Functions deployment, collect:

```powershell
# Get Function App details
$functionApp = "your-function-app-name"
$resourceGroup = "your-resource-group"

# Get Function URL
$functionUrl = "https://$functionApp.azurewebsites.net"
Write-Host "Function URL: $functionUrl"

# Get Master Key
$masterKey = az functionapp keys list `
  --name $functionApp `
  --resource-group $resourceGroup `
  --query masterKey -o tsv
Write-Host "Master Key: $masterKey"
```

**Save these values** - you'll need them for agent configuration.

## 🔧 Agent Configuration

### Agent 1: Orphaned Resources Agent

#### Purpose
Identifies and analyzes orphaned Azure resources (unattached disks, unused public IPs, idle network interfaces).

#### Configuration Steps

**1. Update Agent Schema File**

Edit [Foundry/Agents/Agent-OrphanedResources.txt](Foundry/Agents/Agent-OrphanedResources.txt):

```json
{
  "name": "orphaned-resources-analyzer",
  "model": "gpt-4o",
  "instructions": "You are an Azure cost optimization expert...",
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "analyze_orphaned_resources",
        "description": "Detect orphaned Azure resources",
        "parameters": {
          "type": "object",
          "properties": {
            "subscription_id": {
              "type": "string",
              "description": "Azure subscription ID"
            },
            "resource_types": {
              "type": "array",
              "items": {
                "type": "string",
                "enum": ["PublicIPAddresses", "NetworkInterfaces", "Disks"]
              }
            }
          },
          "required": ["subscription_id"]
        }
      }
    }
  ],
  "tool_config": {
    "analyze_orphaned_resources": {
      "url": "https://YOUR-FUNCTION-APP-NAME.azurewebsites.net/api/orphaned-resources",
      "method": "POST",
      "headers": {
        "x-functions-key": "YOUR-FUNCTION-KEY"
      }
    }
  }
}
```

**2. Replace Placeholders**

- Replace `YOUR-FUNCTION-APP-NAME` with your function app name
- Replace `YOUR-FUNCTION-KEY` with your master key

**3. Deploy in Azure AI Foundry**

1. Navigate to [Azure AI Foundry](https://ai.azure.com)
2. Go to **Agents** section
3. Click **Create New Agent**
4. Copy configuration from `Agent-OrphanedResources.txt`
5. Paste into agent configuration
6. Click **Create**

### Agent 2: Cost Analysis Agent

#### Purpose
Provides intelligent cost analysis, trends, and optimization recommendations.

#### Configuration Steps

**1. Update Agent Schema File**

Edit [Foundry/Agents/Agent-Orphaned-Cost.txt](Foundry/Agents/Agent-Orphaned-Cost.txt):

```json
{
  "name": "azure-cost-analyzer",
  "model": "gpt-4o",
  "instructions": "You are an Azure cost management expert...",
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "analyze_costs",
        "description": "Analyze Azure costs and provide insights",
        "parameters": {
          "type": "object",
          "properties": {
            "subscription_id": {
              "type": "string",
              "description": "Azure subscription ID"
            },
            "scope": {
              "type": "string",
              "enum": ["subscription", "resource_group"],
              "description": "Analysis scope"
            },
            "time_period": {
              "type": "string",
              "enum": ["last7days", "last30days", "last90days"],
              "default": "last30days"
            }
          },
          "required": ["subscription_id", "scope"]
        }
      }
    }
  ],
  "tool_config": {
    "analyze_costs": {
      "url": "https://YOUR-FUNCTION-APP-NAME.azurewebsites.net/api/cost-analysis",
      "method": "POST",
      "headers": {
        "x-functions-key": "YOUR-FUNCTION-KEY"
      }
    }
  }
}
```

**2. Replace Placeholders**

- Replace `YOUR-FUNCTION-APP-NAME` with your function app name
- Replace `YOUR-FUNCTION-KEY` with your master key

**3. Deploy in Azure AI Foundry**

1. Navigate to [Azure AI Foundry](https://ai.azure.com)
2. Go to **Agents** section
3. Click **Create New Agent**
4. Copy configuration from `Agent-Orphaned-Cost.txt`
5. Paste into agent configuration
6. Click **Create**

## 🔗 Configure Agent Connections

### Set Up Function App Connection

**Option 1: Using Azure AI Foundry UI**

1. In Azure AI Foundry, go to **Connections**
2. Click **Add Connection**
3. Select **Custom Connection**
4. Configure:
   - **Name**: `azure-functions-cost-analyzer`
   - **URL**: `https://YOUR-FUNCTION-APP-NAME.azurewebsites.net`
   - **Authentication**: API Key
   - **API Key**: Your master function key
5. Click **Create**

**Option 2: Using Azure CLI**

```powershell
$projectName = "your-ai-foundry-project"
$resourceGroup = "your-ai-foundry-rg"

az ml connection create `
  --name "azure-functions-cost-analyzer" `
  --type custom `
  --workspace-name $projectName `
  --resource-group $resourceGroup `
  --set target="https://$functionApp.azurewebsites.net" `
  --set credentials.key="$masterKey"
```

## 🧪 Test Your Agents

### Test Orphaned Resources Agent

**In Azure AI Foundry Playground:**

```
User: Analyze orphaned resources in subscription 12345678-1234-1234-1234-123456789012

Expected Response: The agent will call your function and provide insights about:
- Unattached disks and their costs
- Unused public IP addresses
- Idle network interfaces
- Total potential savings
```

### Test Cost Analysis Agent

**In Azure AI Foundry Playground:**

```
User: Show me cost analysis for the last 30 days for subscription 12345678-1234-1234-1234-123456789012

Expected Response: The agent will provide:
- Total spending over the period
- Cost breakdown by service
- Top resource groups by cost
- Cost trends and insights
- Optimization recommendations
```

## 🔄 Multi-Agent Workflows (Optional)

### Configure Connected Agents Workflow

For advanced scenarios, configure agents to work together:

**1. Create Workflow File**

Edit [Foundry/Agents/connected-agents.txt](Foundry/Agents/connected-agents.txt):

```json
{
  "name": "comprehensive-cost-optimization",
  "description": "Complete cost optimization analysis",
  "agents": [
    {
      "id": "orphaned-resources-analyzer",
      "trigger": "on_request"
    },
    {
      "id": "azure-cost-analyzer",
      "trigger": "after:orphaned-resources-analyzer"
    }
  ],
  "flow": {
    "1": {
      "agent": "orphaned-resources-analyzer",
      "input": "user_request",
      "output_to": "step_2"
    },
    "2": {
      "agent": "azure-cost-analyzer",
      "input": "step_1_results",
      "output_to": "final_response"
    }
  }
}
```

**2. Deploy Workflow**

Use [Foundry/mcp/workflows/orphaned-resources-agent-trigger.json](Foundry/mcp/workflows/orphaned-resources-agent-trigger.json) for MCP integration.

## 📊 Monitor Agent Performance

### View Agent Metrics

```powershell
# Navigate to Azure AI Foundry
# Go to Agents > Your Agent > Analytics

# Key metrics to monitor:
# - Request count
# - Average response time
# - Success rate
# - Error rate
# - Token usage
```

### Enable Agent Logging

In Azure AI Foundry:
1. Go to **Settings** > **Diagnostics**
2. Enable **Agent Execution Logs**
3. Configure log retention period
4. Set up alerts for errors

## 🔒 Security Best Practices

### Secure Function Keys

```powershell
# Rotate function keys regularly
az functionapp keys set `
  --name $functionApp `
  --resource-group $resourceGroup `
  --key-name master `
  --key-value $(New-Guid).Guid
```

### Use Azure Key Vault (Recommended)

```powershell
# Store function key in Key Vault
$keyVaultName = "kv-cost-analyzer"
az keyvault secret set `
  --vault-name $keyVaultName `
  --name "function-master-key" `
  --value $masterKey

# Grant AI Foundry access to Key Vault
$aiFoundryIdentity = "your-ai-foundry-managed-identity"
az keyvault set-policy `
  --name $keyVaultName `
  --object-id $aiFoundryIdentity `
  --secret-permissions get list
```

### Configure Agent Permissions

Ensure agents have minimal required permissions:
- Read access to Cost Management API
- Read access to Resource Graph API
- No write permissions (view-only)

## 🆘 Troubleshooting

### Agent Not Calling Function

**Check:**
- Function URL is correct and accessible
- Function key is valid
- Function app is running
- CORS configured if needed

```powershell
# Test function endpoint directly
Invoke-RestMethod `
  -Uri "https://$functionApp.azurewebsites.net/api/orphaned-resources-example" `
  -Method GET
```

### Authentication Errors

```powershell
# Verify function key
az functionapp keys list `
  --name $functionApp `
  --resource-group $resourceGroup

# Test with key
$headers = @{
    "x-functions-key" = $masterKey
}
Invoke-RestMethod `
  -Uri "https://$functionApp.azurewebsites.net/api/orphaned-resources" `
  -Method POST `
  -Headers $headers `
  -Body '{"subscription_id":"test"}' `
  -ContentType "application/json"
```

### Agent Response Issues

1. Check Application Insights for function errors
2. Review agent execution logs in AI Foundry
3. Verify JSON schema matches function expectations
4. Test function independently before agent integration

## 🎯 Next Steps

After successful agent deployment:

- [ ] Test both agents in AI Foundry Playground
- [ ] Create example prompts for users
- [ ] Set up monitoring alerts
- [ ] Train team on using agents
- [ ] Integrate agents into existing workflows
- [ ] Consider setting up scheduled agent runs
- [ ] Configure notifications for high-cost findings

## 📚 Additional Resources

### Azure AI Foundry Documentation
- [Creating Agents](https://learn.microsoft.com/azure/ai-services/agents/)
- [Function Calling](https://learn.microsoft.com/azure/ai-services/openai/how-to/function-calling)
- [Agent Best Practices](https://learn.microsoft.com/azure/ai-services/agents/best-practices)

### Integration Examples
- [Agent API Reference](https://learn.microsoft.com/azure/ai-services/agents/api-reference)
- [Workflow Orchestration](https://learn.microsoft.com/azure/ai-services/agents/workflows)
- [MCP Integration](./Foundry/mcp/README.md)

---

**🎉 Agent Deployment Complete!** Your AI agents are ready to provide intelligent cost optimization insights.
