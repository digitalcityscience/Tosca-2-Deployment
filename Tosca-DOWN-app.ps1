# Deployment Script for TOSCA

# Function to display error messages and exit
function Show-Error {
    param (
        [string]$message
    )
    Write-Host "$message" -ForegroundColor Red
    Write-Host "Press 'q' to exit..."
    while ($true) {
        $key = [System.Console]::ReadKey($true)
        if ($key.KeyChar -eq 'q') {
            exit 1
        }
    }
}

try {
    # Check if .env file exists in the current directory
    if (-Not (Test-Path -Path ".env")) {
        Show-Error "Error: .env file not found. Please create a .env file in the current directory."
    }

    # Check if Docker Desktop is running
    $dockerProcess = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
    if (-Not $dockerProcess) {
        Show-Error "Error: Docker Desktop is not running. Please start Docker Desktop and try again."
    }

    # Check if docker-compose or docker compose command is available
    $dockerComposeCommand = "docker-compose"
    if (-Not (Get-Command $dockerComposeCommand -ErrorAction SilentlyContinue)) {
        $dockerComposeCommand = "docker compose"
        if (-Not (Get-Command $dockerComposeCommand -ErrorAction SilentlyContinue)) {
            Show-Error "Error: Neither 'docker-compose' nor 'docker compose' command found. Please ensure Docker Compose is installed and available in PATH."
        }
    }

    # Run Docker Compose to build and start the system
    Write-Host "Starting TOSCA system..."
    Invoke-Expression "$dockerComposeCommand -f docker-compose-production.yml down"

    Write-Host "TOSCA system closed successfully." -ForegroundColor Green

    # Display Docker logs
    Write-Host "Showing Docker logs..."
    Invoke-Expression "$dockerComposeCommand -f docker-compose-production.yml logs --tail=50"

    Write-Host "Press 'q' to exit..."
    while ($true) {
        $key = [System.Console]::ReadKey($true)
        if ($key.KeyChar -eq 'q') {
            exit 0
        }
    }
} catch {
    Show-Error "An unexpected error occurred: $_"
}
