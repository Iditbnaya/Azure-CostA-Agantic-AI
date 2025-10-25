# Azure Cost Analysis Agents - Configuration Guide

## Prerequisites

1. **Azure AI Foundry Project**: You need an Azure AI Foundry (formerly Azure AI Studio) project with a deployed model
2. **Function App**: Your Azure Function App is deployed at `fun-cost-agent-working.azurewebsites.net`
3. **Python Packages**: Install the Microsoft Agent Framework (preview)

## Setup Instructions

### 1. Install Required Packages

```bash
# Install Microsoft Agent Framework (preview)
pip install agent-framework-azure-ai --pre

# Install additional dependencies
pip install aiohttp azure-identity
```

### 2. Configure Azure AI Foundry

You need to update these configuration values in `cost_analysis_agents.py`:

```python
# Replace these with your actual values
AZURE_AI_ENDPOINT = "https://your-project-name.cognitiveservices.azure.com"
MODEL_DEPLOYMENT_NAME = "gpt-4"  # or your model deployment name
```

#### Finding Your Azure AI Foundry Endpoint:
1. Go to [Azure AI Foundry](https://ai.azure.com)
2. Select your project
3. Go to "Project settings" → "Properties"
4. Copy the "Endpoint" URL

#### Finding Your Model Deployment:
1. In Azure AI Foundry, go to "Models + endpoints"
2. Find your deployed model
3. Copy the "Deployment name"

### 3. Configure Function App Authentication (Optional)

If your Function App requires authentication, you can add a function key:

```python
function_key = "your-function-app-key"  # Optional
```

#### Getting Function App Key:
1. Go to Azure Portal → Your Function App
2. Go to "Functions" → "App keys"
3. Copy a function key (or create one)

### 4. Azure Authentication

The agents use `DefaultAzureCredential` for authentication. Make sure you're logged in:

```bash
# Login to Azure CLI
az login

# Set your default subscription (if needed)
az account set --subscription "your-subscription-id"
```

## Usage Examples

After configuration, you can run the agents with requests like:

1. **Tenant-wide analysis:**
   ```
   "Analyze orphaned resources in all my Azure subscriptions for the last month"
   ```

2. **Specific resource types:**
   ```
   "Find unused managed disks and public IPs that are costing money"
   ```

3. **Specific subscription:**
   ```
   "Check for orphaned resources in subscription 12345678-1234-1234-1234-123456789abc"
   ```

4. **Cost focus:**
   ```
   "Show me potential cost savings from cleaning up unused Azure resources"
   ```

## Agent Workflow

The system uses two coordinated agents:

1. **Agent 1 (Orphaned Resource Analyzer)**:
   - Identifies orphaned Azure resources
   - Calls `/analyze` endpoint on your Function App
   - Filters and categorizes resources

2. **Agent 2 (Cost Analysis Agent)**:
   - Calculates cost impact of identified resources
   - Calls `/cost-analysis` endpoint
   - Provides savings recommendations and risk assessment

## Current Status

✅ **Infrastructure Deployed:**
- Function App: `fun-cost-agent-working`
- Storage Account: `funcostagentworking`
- Resource Group: `funcostagentworking`
- RBAC Roles: Cost Management Reader, Storage Blob Data Contributor

⚠️ **Pending:**
- Function code deployment (blocked by storage access policy)
- Azure AI Foundry project configuration

## Next Steps

1. **Configure Azure AI Foundry** (update endpoints in code)
2. **Test the agents** with the configuration
3. **Resolve Function App deployment** (if needed)
4. **Deploy to production** with proper authentication

## Troubleshooting

### Common Issues:

1. **Authentication Errors:**
   - Run `az login` to authenticate
   - Verify your account has access to the Azure AI Foundry project

2. **Function App 404 Errors:**
   - The infrastructure is deployed but function code isn't deployed yet
   - You can still test the agent logic by updating endpoints temporarily

3. **Model Access Errors:**
   - Verify your Azure AI Foundry project has the model deployed
   - Check that your account has access to the project

4. **Permission Errors:**
   - Ensure you have Cost Management Reader role on subscriptions
   - Verify Azure AI Foundry project access permissions

## Support

For issues with:
- **Microsoft Agent Framework**: [GitHub Repository](https://github.com/microsoft/agent-framework)
- **Azure AI Foundry**: [Documentation](https://docs.microsoft.com/azure/ai-studio/)
- **Function App**: Check Azure Portal logs and Application Insights