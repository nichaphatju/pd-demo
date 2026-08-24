<#
.SYNOPSIS
    Registers the Salesforce Platform MCP servers and the Atlassian (Jira/Confluence)
    remote MCP server for the current project, then triggers the one-time OAuth
    sign-in for each.

.DESCRIPTION
    Copy this script into any project directory and run it from inside that
    directory. It adds the MCP servers at "local" scope (the Claude Code
    default) so they belong to this project + this machine only, matching
    how MCP servers are already configured in this project.

    OAuth consent still requires one interactive browser click per server the
    first time - that step cannot be scripted away. This script opens the
    browser for you immediately after each server is added so you only have
    to click "Allow" instead of hunting down URLs or typing add commands.

.USAGE
    cd C:\path\to\other-project
    ..\AgentforcePsn\scripts\setup-mcp.ps1

    # Headless/SSH session (prints the URL instead of opening a browser):
    ..\AgentforcePsn\scripts\setup-mcp.ps1 -NoBrowser
#>

param(
    [switch]$NoBrowser
)

$ErrorActionPreference = "Stop"

function Test-ClaudeCli {
    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
        Write-Host "Claude Code CLI ('claude') was not found on PATH. Install it first." -ForegroundColor Red
        exit 1
    }
}

function Add-McpServer {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][ValidateSet("http", "sse")][string]$Transport
    )

    $existing = claude mcp list 2>$null | Select-String -SimpleMatch "$Name`:"
    if ($existing) {
        Write-Host "MCP server '$Name' is already configured - skipping add." -ForegroundColor Yellow
        return
    }

    Write-Host "Adding MCP server '$Name' ($Transport transport)..." -ForegroundColor Cyan
    claude mcp add --transport $Transport $Name $Url
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to add '$Name'." -ForegroundColor Red
        exit 1
    }
}

function Connect-McpServer {
    param([Parameter(Mandatory)][string]$Name)

    Write-Host "Signing in to '$Name'..." -ForegroundColor Cyan
    if ($NoBrowser) {
        claude mcp login $Name --no-browser
    } else {
        claude mcp login $Name
    }
}

Test-ClaudeCli

# --- Salesforce Platform MCP servers (hosted, org-scoped via OAuth) ---
Add-McpServer -Name "sf-sobject-all"     -Url "https://api.salesforce.com/platform/mcp/v1/platform/sobject-all"     -Transport "http"
Add-McpServer -Name "sf-metadata-expert" -Url "https://api.salesforce.com/platform/mcp/v1/platform/metadata-experts" -Transport "http"

# --- Atlassian (Jira + Confluence) remote MCP server ---
Add-McpServer -Name "atlassian" -Url "https://mcp.atlassian.com/v1/sse" -Transport "sse"

Write-Host ""
Write-Host "Servers registered. Completing one-time sign-in for each..." -ForegroundColor Green

foreach ($name in @("sf-sobject-all", "sf-metadata-expert", "atlassian")) {
    Connect-McpServer -Name $name
}

Write-Host ""
Write-Host "Done. Verify with: claude mcp list" -ForegroundColor Green
