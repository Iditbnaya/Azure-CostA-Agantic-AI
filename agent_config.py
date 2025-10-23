"""
Azure Cost Analysis Agents - Environment Configuration Helper

This module provides environment configuration loading for the Azure Cost Analysis agents.
"""

import os
from typing import Optional
from dataclasses import dataclass

@dataclass
class AgentConfig:
    """Configuration for Azure Cost Analysis Agents."""
    azure_ai_endpoint: str
    model_deployment_name: str
    function_app_base_url: str
    function_app_key: Optional[str] = None
    default_subscription_id: Optional[str] = None
    log_level: str = "INFO"

def load_config() -> AgentConfig:
    """Load configuration from environment variables or defaults."""
    
    # Try to load from .env file if available
    try:
        from dotenv import load_dotenv
        load_dotenv()
    except ImportError:
        pass  # dotenv is optional
    
    # Load configuration with fallbacks
    config = AgentConfig(
        azure_ai_endpoint=os.getenv(
            "AZURE_AI_ENDPOINT", 
            "https://your-project-name.cognitiveservices.azure.com"
        ),
        model_deployment_name=os.getenv(
            "MODEL_DEPLOYMENT_NAME", 
            "gpt-4"
        ),
        function_app_base_url=os.getenv(
            "FUNCTION_APP_BASE_URL", 
            "https://func-costanalysis-prod-001.azurewebsites.net/api"
        ),
        function_app_key=os.getenv("FUNCTION_APP_KEY"),
        default_subscription_id=os.getenv("DEFAULT_SUBSCRIPTION_ID"),
        log_level=os.getenv("LOG_LEVEL", "INFO")
    )
    
    return config

def validate_config(config: AgentConfig) -> bool:
    """Validate that the configuration is complete."""
    
    issues = []
    
    if "your-project-name" in config.azure_ai_endpoint:
        issues.append("AZURE_AI_ENDPOINT needs to be updated with your actual endpoint")
    
    if not config.azure_ai_endpoint.startswith("https://"):
        issues.append("AZURE_AI_ENDPOINT should start with https://")
    
    if not config.model_deployment_name or config.model_deployment_name == "gpt-4":
        issues.append("MODEL_DEPLOYMENT_NAME should be set to your actual deployment name")
    
    if not config.function_app_base_url.startswith("https://"):
        issues.append("FUNCTION_APP_BASE_URL should start with https://")
    
    if issues:
        print("❌ Configuration Issues Found:")
        for issue in issues:
            print(f"   - {issue}")
        print("\n📖 Please check AGENTS_SETUP.md for configuration instructions")
        return False
    
    print("✅ Configuration looks good!")
    return True

def print_config(config: AgentConfig) -> None:
    """Print current configuration (without sensitive data)."""
    
    print("🔧 Current Configuration:")
    print(f"   Azure AI Endpoint: {config.azure_ai_endpoint}")
    print(f"   Model Deployment: {config.model_deployment_name}")
    print(f"   Function App URL: {config.function_app_base_url}")
    print(f"   Function Key: {'Set' if config.function_app_key else 'Not set'}")
    print(f"   Default Subscription: {config.default_subscription_id or 'Not set'}")
    print(f"   Log Level: {config.log_level}")