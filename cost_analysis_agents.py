"""
Azure Cost Analysis Multi-Agent System using Microsoft Agent Framework

This module implements a two-agent workflow for Azure cost optimization:
1. OrphanedResourceAgent: Identifies orphaned Azure resources
2. CostAnalysisAgent: Calculates cost impact of identified resources

The agents work together to provide comprehensive cost analysis and recommendations.
"""

import asyncio
import json
import logging
from datetime import datetime, timedelta, timezone
from typing import List, Dict, Any, Optional
import aiohttp
from dataclasses import dataclass

from agent_framework import (
    ChatAgent,
    ChatMessage,
    Executor,
    WorkflowBuilder,
    WorkflowContext,
    WorkflowOutputEvent,
    Role,
    handler,
)
from agent_framework_azure_ai import AzureAIAgentClient
from azure.identity.aio import DefaultAzureCredential

# Configuration
FUNCTION_APP_BASE_URL = "https://func-costanalysis-prod-001.azurewebsites.net/api"
AZURE_AI_ENDPOINT = "<your-foundry-project-endpoint>"  # Replace with your Azure AI Foundry endpoint
MODEL_DEPLOYMENT_NAME = "<your-model-deployment>"      # Replace with your model deployment name

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class OrphanedResource:
    """Represents an orphaned Azure resource."""
    resource_type: str
    resource_id: str
    name: str
    location: str
    resource_group: str
    subscription_id: str

@dataclass
class CostAnalysisResult:
    """Represents cost analysis results."""
    subscription_id: str
    total_cost: float
    currency: str
    resource_costs: List[Dict[str, Any]]

class AzureFunctionClient:
    """Client for interacting with Azure Functions endpoints."""
    
    def __init__(self, base_url: str, function_key: Optional[str] = None):
        self.base_url = base_url
        self.function_key = function_key
        self.session = None
    
    async def __aenter__(self):
        self.session = aiohttp.ClientSession()
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()
    
    def _get_headers(self) -> Dict[str, str]:
        """Get headers for API requests."""
        headers = {"Content-Type": "application/json"}
        if self.function_key:
            headers["x-functions-key"] = self.function_key
        return headers
    
    async def analyze_orphaned_resources(
        self, 
        subscription_id: Optional[str] = None,
        resource_types: Optional[List[str]] = None,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        include_costs: bool = True
    ) -> Dict[str, Any]:
        """Call the orphaned resources analysis endpoint."""
        
        payload = {
            "include_costs": include_costs
        }
        
        if subscription_id:
            payload["subscription_id"] = subscription_id
        
        if resource_types:
            payload["resource_types"] = resource_types
        
        if start_date and end_date:
            payload["start_date"] = start_date
            payload["end_date"] = end_date
        
        url = f"{self.base_url}/analyze"
        headers = self._get_headers()
        
        logger.info(f"Calling orphaned resources analysis: {url}")
        logger.info(f"Payload: {json.dumps(payload, indent=2)}")
        
        async with self.session.post(url, json=payload, headers=headers) as response:
            if response.status == 200:
                result = await response.json()
                logger.info(f"Analysis completed successfully. Found {len(result.get('resources', []))} orphaned resources")
                return result
            else:
                error_text = await response.text()
                logger.error(f"Analysis failed with status {response.status}: {error_text}")
                raise Exception(f"Analysis failed: {response.status} - {error_text}")
    
    async def analyze_costs(
        self,
        subscription_id: str,
        query_type: str = "specific_resources",
        resource_ids: Optional[List[str]] = None,
        start_date: str = None,
        end_date: str = None,
        granularity: str = "Daily"
    ) -> Dict[str, Any]:
        """Call the cost analysis endpoint."""
        
        payload = {
            "subscription_id": subscription_id,
            "query_type": query_type,
            "start_date": start_date,
            "end_date": end_date,
            "granularity": granularity
        }
        
        if resource_ids:
            payload["resource_ids"] = resource_ids
        
        url = f"{self.base_url}/cost-analysis"
        headers = self._get_headers()
        
        logger.info(f"Calling cost analysis: {url}")
        logger.info(f"Payload: {json.dumps(payload, indent=2)}")
        
        async with self.session.post(url, json=payload, headers=headers) as response:
            if response.status == 200:
                result = await response.json()
                logger.info(f"Cost analysis completed. Total cost: {result.get('total_cost', 0)} {result.get('currency', 'USD')}")
                return result
            else:
                error_text = await response.text()
                logger.error(f"Cost analysis failed with status {response.status}: {error_text}")
                raise Exception(f"Cost analysis failed: {response.status} - {error_text}")

class OrphanedResourceAnalyzerExecutor(Executor):
    """
    Agent 1: Azure Orphaned Resource Analyzer
    
    This executor identifies orphaned Azure resources across subscriptions.
    It calls the /analyze endpoint and forwards results to the cost analysis agent.
    """
    
    agent: ChatAgent
    function_client: AzureFunctionClient
    
    def __init__(self, agent: ChatAgent, function_client: AzureFunctionClient, id: str = "orphaned_resource_analyzer"):
        self.agent = agent
        self.function_client = function_client
        super().__init__(id=id)
    
    def _parse_user_request(self, user_message: str) -> Dict[str, Any]:
        """Parse user request to extract subscription ID, resource types, and date range."""
        # Default parameters
        params = {
            "subscription_id": None,
            "resource_types": None,
            "start_date": None,
            "end_date": None,
            "include_costs": True
        }
        
        # Set default date range to last 30 days
        end_date = datetime.now(timezone.utc)
        start_date = end_date - timedelta(days=30)
        params["start_date"] = start_date.isoformat()
        params["end_date"] = end_date.isoformat()
        
        # TODO: Add more sophisticated parsing based on user message
        # For now, use defaults - could be enhanced with NLP
        
        return params
    
    @handler
    async def handle_analysis_request(
        self, 
        message: ChatMessage, 
        ctx: WorkflowContext[List[Dict[str, Any]]]
    ) -> None:
        """
        Handle user request for orphaned resource analysis.
        
        This method:
        1. Parses the user request to extract parameters
        2. Calls the Azure Function to analyze orphaned resources
        3. Processes the results and forwards them to the cost analysis agent
        """
        
        user_text = message.contents[0].text if message.contents else str(message)
        logger.info(f"Processing orphaned resource analysis request: {user_text}")
        
        # Let the agent understand and process the request
        agent_messages = [message]
        agent_response = await self.agent.run(agent_messages)
        
        # Parse the user request to get analysis parameters
        params = self._parse_user_request(user_text)
        
        try:
            # Call the Azure Function to analyze orphaned resources
            analysis_result = await self.function_client.analyze_orphaned_resources(
                subscription_id=params["subscription_id"],
                resource_types=params["resource_types"],
                start_date=params["start_date"],
                end_date=params["end_date"],
                include_costs=params["include_costs"]
            )
            
            # Process results by subscription
            resources_by_subscription = {}
            for resource in analysis_result.get("resources", []):
                sub_id = resource.get("subscription_id")
                if sub_id not in resources_by_subscription:
                    resources_by_subscription[sub_id] = []
                resources_by_subscription[sub_id].append(resource)
            
            # Send results to cost analysis agent for each subscription
            for subscription_id, resources in resources_by_subscription.items():
                resource_ids = [r["resource_id"] for r in resources]
                
                cost_analysis_request = {
                    "subscription_id": subscription_id,
                    "resource_ids": resource_ids,
                    "start_date": params["start_date"],
                    "end_date": params["end_date"],
                    "resources": resources,
                    "original_request": user_text
                }
                
                await ctx.send_message(cost_analysis_request)
                
            if not resources_by_subscription:
                # No orphaned resources found
                await ctx.send_message({
                    "subscription_id": params.get("subscription_id", "all"),
                    "resource_ids": [],
                    "resources": [],
                    "message": "No orphaned resources found",
                    "original_request": user_text
                })
                
        except Exception as e:
            logger.error(f"Error during orphaned resource analysis: {str(e)}")
            error_message = f"Failed to analyze orphaned resources: {str(e)}"
            
            await ctx.send_message({
                "error": error_message,
                "original_request": user_text
            })

class CostAnalysisExecutor(Executor):
    """
    Agent 2: Azure Cost Analysis Agent
    
    This executor calculates the cost impact of orphaned resources identified by Agent 1.
    It calls the /cost-analysis endpoint and provides final recommendations.
    """
    
    agent: ChatAgent
    function_client: AzureFunctionClient
    
    def __init__(self, agent: ChatAgent, function_client: AzureFunctionClient, id: str = "cost_analysis_agent"):
        self.agent = agent
        self.function_client = function_client
        super().__init__(id=id)
    
    @handler
    async def handle_cost_analysis(
        self, 
        analysis_data: Dict[str, Any], 
        ctx: WorkflowContext[None, str]
    ) -> None:
        """
        Handle cost analysis for orphaned resources.
        
        This method:
        1. Receives orphaned resource data from Agent 1
        2. Calls the cost analysis endpoint to calculate costs
        3. Generates final recommendations and insights
        """
        
        logger.info(f"Processing cost analysis for subscription: {analysis_data.get('subscription_id')}")
        
        # Check if this is an error message from Agent 1
        if "error" in analysis_data:
            error_response = f"❌ **Error in Analysis**\n\n{analysis_data['error']}\n\nPlease check your Azure permissions and try again."
            await ctx.yield_output(error_response)
            return
        
        # Check if no resources were found
        if not analysis_data.get("resource_ids"):
            no_resources_response = f"""✅ **No Orphaned Resources Found**

Great news! No orphaned resources were detected in the specified scope.

**Analysis Summary:**
- Subscription: {analysis_data.get('subscription_id', 'All accessible subscriptions')}
- Search completed successfully
- No cost optimization opportunities identified

Your Azure resources appear to be properly utilized! 🎉"""
            
            await ctx.yield_output(no_resources_response)
            return
        
        try:
            # Call cost analysis for the identified resources
            cost_result = await self.function_client.analyze_costs(
                subscription_id=analysis_data["subscription_id"],
                query_type="specific_resources",
                resource_ids=analysis_data["resource_ids"],
                start_date=analysis_data["start_date"],
                end_date=analysis_data["end_date"]
            )
            
            # Generate comprehensive analysis message for the agent
            resources_summary = []
            for resource in analysis_data.get("resources", []):
                resources_summary.append(f"- {resource.get('resource_type', 'Unknown')}: {resource.get('name', 'Unnamed')} in {resource.get('location', 'Unknown location')}")
            
            cost_context = ChatMessage(
                role=Role.USER,
                text=f"""Analyze the following orphaned Azure resources and their associated costs:

**Subscription:** {analysis_data['subscription_id']}
**Analysis Period:** {analysis_data['start_date']} to {analysis_data['end_date']}

**Orphaned Resources Found ({len(analysis_data.get('resources', []))}):**
{chr(10).join(resources_summary)}

**Cost Analysis Results:**
- Total Cost: {cost_result.get('total_cost', 0)} {cost_result.get('currency', 'USD')}
- Analysis Type: {cost_result.get('analysis_type', 'specific_resources')}

Please provide:
1. A summary of the cost impact
2. Prioritized recommendations for cost savings
3. Risk assessment for removing these resources
4. Next steps for optimization

Format your response with clear sections and actionable insights."""
            )
            
            # Get agent's analysis and recommendations
            agent_response = await self.agent.run([cost_context])
            final_response = agent_response.text
            
            # Add structured summary
            structured_summary = f"""
## 💰 **Cost Analysis Summary**

**Total Potential Savings:** {cost_result.get('total_cost', 0)} {cost_result.get('currency', 'USD')}
**Resources Analyzed:** {len(analysis_data.get('resources', []))} orphaned resources
**Subscription:** {analysis_data['subscription_id']}

---

{final_response}

---

## 🔧 **Quick Actions**
1. Review the orphaned resources list above
2. Verify that these resources are indeed unused
3. Plan removal during a maintenance window
4. Monitor cost savings after cleanup

*Analysis completed at {datetime.now(timezone.utc).isoformat()}*
"""
            
            await ctx.yield_output(structured_summary)
            
        except Exception as e:
            logger.error(f"Error during cost analysis: {str(e)}")
            error_response = f"""❌ **Cost Analysis Error**

Failed to analyze costs for the identified orphaned resources.

**Error Details:** {str(e)}

**Subscription:** {analysis_data.get('subscription_id', 'Unknown')}
**Resources Found:** {len(analysis_data.get('resources', []))} orphaned resources

Please check:
- Azure Cost Management API permissions
- Function App connectivity
- Subscription access rights

You can still manually review the orphaned resources and estimate potential savings."""
            
            await ctx.yield_output(error_response)

class AzureCostAnalysisWorkflow:
    """
    Main workflow orchestrator for the Azure Cost Analysis multi-agent system.
    """
    
    def __init__(
        self, 
        azure_ai_endpoint: str, 
        model_deployment: str,
        function_app_url: str,
        function_key: Optional[str] = None
    ):
        self.azure_ai_endpoint = azure_ai_endpoint
        self.model_deployment = model_deployment
        self.function_app_url = function_app_url
        self.function_key = function_key
    
    async def create_workflow(self):
        """Create and configure the multi-agent workflow."""
        
        # Create Azure AI client with credentials
        credential = DefaultAzureCredential()
        
        # Create function client
        function_client = AzureFunctionClient(
            base_url=self.function_app_url,
            function_key=self.function_key
        )
        
        # Create Agent 1: Orphaned Resource Analyzer
        orphaned_resource_agent = ChatAgent(
            chat_client=AzureAIAgentClient(
                project_endpoint=self.azure_ai_endpoint,
                model_deployment_name=self.model_deployment,
                async_credential=credential,
                agent_name="OrphanedResourceAnalyzer",
            ),
            instructions="""You are Agent 1 — the "Azure Orphaned Resource Analyzer."

🎯 **Your Goal:** Identify orphaned Azure resources across subscriptions that are consuming costs unnecessarily.

⚙️ **Your Capabilities:**
- Analyze Azure subscriptions for unused resources (Public IPs, Managed Disks, Network Interfaces, etc.)
- Support both single subscription and tenant-wide analysis
- Filter by resource types, resource groups, and locations
- Provide detailed resource inventories with locations and metadata

🕒 **Date Handling:**
- When users mention relative dates ("last month", "past 30 days"), calculate based on current date
- Default to last 30 days if no timeframe specified
- Always use ISO 8601 format for API calls

🎯 **Resource Types You Can Analyze:**
- Public IP addresses not attached to resources
- Managed Disks not attached to VMs
- Network Interfaces not attached to VMs
- Snapshots that are old or unused
- VMs without Azure Hybrid Benefit optimization
- Azure Advisor recommendations

**Communication Style:**
- Be clear and informative about what you're analyzing
- Explain the scope of your search (subscription vs tenant-wide)
- Highlight the potential impact of orphaned resources
- Use structured formatting for easy reading""",
        )
        
        # Create Agent 2: Cost Analysis Agent
        cost_analysis_agent = ChatAgent(
            chat_client=AzureAIAgentClient(
                project_endpoint=self.azure_ai_endpoint,
                model_deployment_name=self.model_deployment,
                async_credential=credential,
                agent_name="CostAnalysisAgent",
            ),
            instructions="""You are Agent 2 — the "Azure Cost Analysis Agent."

🎯 **Your Goal:** Calculate the cost impact of orphaned Azure resources and provide actionable optimization recommendations.

⚙️ **Your Capabilities:**
- Analyze costs for specific orphaned resources identified by Agent 1
- Calculate potential monthly and annual savings
- Provide risk assessments for resource removal
- Generate prioritized action plans for cost optimization

💰 **Cost Analysis Focus:**
- Quantify exact costs per resource type
- Calculate potential savings from cleanup
- Identify highest-impact optimization opportunities
- Consider regional pricing variations

🎯 **Recommendation Framework:**
1. **High Priority:** Resources with significant cost impact and low risk
2. **Medium Priority:** Moderate cost impact requiring verification
3. **Low Priority:** Small cost savings or higher risk removals

🛡️ **Risk Assessment:**
- Evaluate dependency risks before recommending removal
- Suggest verification steps for safety
- Recommend maintenance windows for changes
- Highlight resources that need stakeholder approval

**Communication Style:**
- Lead with total potential savings
- Use clear cost breakdowns with currency
- Provide step-by-step action plans
- Include risk warnings and safety checks
- Use emojis and formatting for visual clarity""",
        )
        
        # Create executors
        orphaned_executor = OrphanedResourceAnalyzerExecutor(
            agent=orphaned_resource_agent,
            function_client=function_client
        )
        
        cost_executor = CostAnalysisExecutor(
            agent=cost_analysis_agent,
            function_client=function_client
        )
        
        # Build the workflow
        workflow = (
            WorkflowBuilder()
            .add_edge(orphaned_executor, cost_executor)
            .set_start_executor(orphaned_executor)
            .build()
        )
        
        return workflow, function_client
    
    async def run_analysis(self, user_request: str) -> None:
        """Run the complete cost analysis workflow."""
        
        logger.info(f"Starting Azure cost analysis workflow for request: {user_request}")
        
        # Create workflow and function client
        workflow, function_client = await self.create_workflow()
        
        # Create user message
        user_message = ChatMessage(role=Role.USER, text=user_request)
        
        try:
            async with function_client:
                # Run the workflow with streaming
                print("🔍 **Starting Azure Cost Analysis...**\n")
                
                async for event in workflow.run_stream(user_message):
                    if isinstance(event, WorkflowOutputEvent):
                        print("📊 **Analysis Complete!**\n")
                        print(event.data)
                        print("\n" + "="*80 + "\n")
                        break
                    else:
                        # Log other events for debugging
                        logger.debug(f"Workflow event: {event}")
                        
        except Exception as e:
            logger.error(f"Workflow execution failed: {str(e)}")
            print(f"❌ **Workflow Error:** {str(e)}")

# Example usage and main function
async def main():
    """Example usage of the Azure Cost Analysis multi-agent system."""
    
    # Configuration - Update these values for your environment
    config = {
        "azure_ai_endpoint": AZURE_AI_ENDPOINT,
        "model_deployment": MODEL_DEPLOYMENT_NAME,
        "function_app_url": FUNCTION_APP_BASE_URL,
        "function_key": None  # Add your function key if needed
    }
    
    # Validate configuration
    if "<your-" in config["azure_ai_endpoint"] or "<your-" in config["model_deployment"]:
        print("❌ **Configuration Error**")
        print("Please update the following configuration values:")
        print("- AZURE_AI_ENDPOINT: Your Azure AI Foundry project endpoint")
        print("- MODEL_DEPLOYMENT_NAME: Your model deployment name")
        print("\nExample:")
        print('AZURE_AI_ENDPOINT = "https://your-project.cognitiveservices.azure.com"')
        print('MODEL_DEPLOYMENT_NAME = "gpt-4"')
        return
    
    # Create workflow instance
    workflow_manager = AzureCostAnalysisWorkflow(
        azure_ai_endpoint=config["azure_ai_endpoint"],
        model_deployment=config["model_deployment"],
        function_app_url=config["function_app_url"],
        function_key=config["function_key"]
    )
    
    # Example analysis requests
    example_requests = [
        "Analyze orphaned resources in all my Azure subscriptions for the last month",
        "Find unused managed disks and public IPs that are costing money",
        "Check for orphaned resources in subscription 12345678-1234-1234-1234-123456789abc",
        "Show me potential cost savings from cleaning up unused Azure resources"
    ]
    
    print("🚀 **Azure Cost Analysis Multi-Agent System**")
    print("="*60)
    print("\nExample requests you can try:")
    for i, request in enumerate(example_requests, 1):
        print(f"{i}. {request}")
    
    print("\n" + "="*60)
    
    # Run an example analysis
    user_request = input("\nEnter your cost analysis request (or press Enter for example): ").strip()
    
    if not user_request:
        user_request = example_requests[0]
        print(f"Using example request: {user_request}")
    
    print("\n" + "="*60 + "\n")
    
    # Execute the analysis
    await workflow_manager.run_analysis(user_request)

if __name__ == "__main__":
    # Install required packages if not already installed
    print("📦 Installing required packages...")
    print("Run: pip install agent-framework-azure-ai --pre")
    print("Run: pip install aiohttp azure-identity")
    print("\n" + "="*60 + "\n")
    
    # Run the main workflow
    asyncio.run(main())