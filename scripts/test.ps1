<#
.SYNOPSIS
    PowerShell equivalent of test.sh
#>
param(
    [string]$NodeServerIp,
    [string]$DeviceId
)

$ErrorActionPreference = "Stop"
$ScriptPath = $PSScriptRoot
$ProjectDir = Split-Path -Path $ScriptPath -Parent

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
}

Write-Host "Project Directory: $ProjectDir"

# Determine Node Server IP
if ([string]::IsNullOrWhiteSpace($NodeServerIp)) {
    # Try to find the primary IPv4 address
    # Filtering out loopback and ensuring the interface is up
    $ipObj = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
        $_.InterfaceAlias -notmatch "Loopback" -and $_.Status -eq "Up" -and $_.IPAddress -notmatch "^169\.254"
    } | Sort-Object InterfaceIndex | Select-Object -First 1
    
    if ($null -ne $ipObj) {
        $NodeServerIp = $ipObj.IPAddress
    }
}

$env:NODE_SERVER_IP = $NodeServerIp
Write-Host "Node Server IP: $env:NODE_SERVER_IP"

if ([string]::IsNullOrWhiteSpace($env:NODE_SERVER_IP)) {
    Write-ErrorMsg "No Server IP found"
    exit 1
}

$Failed = 0
$JobProcesses = @()

# Cleanup function to be called on exit
function Cleanup {
    Write-Host "Cleaning up background processes..."
    foreach ($proc in $JobProcesses) {
        if (-not $proc.HasExited) {
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        }
    }
}

try {
    # Start chromedriver if needed
    if ($DeviceId -eq "chrome") {
        $chromeDriverPath = Join-Path $ProjectDir "tool\chromedriver.exe"
        if (Test-Path $chromeDriverPath) {
            Write-Host "Starting chromedriver..."
            $p = Start-Process -FilePath $chromeDriverPath -ArgumentList "--port=4444" -PassThru -NoNewWindow
            $JobProcesses += $p
        } else {
            Write-Warning "chromedriver.exe not found at $chromeDriverPath"
        }
    }

    # Run env.dart
    Write-Host "Running env.dart..."
    dart (Join-Path $ProjectDir "tool\env.dart")

    # Start Node Server
    Write-Host "Starting Node Server..."
    Push-Location (Join-Path $ProjectDir "test_node_server")
    $nodeProcess = Start-Process -FilePath "node" -ArgumentList "index.js" -PassThru -NoNewWindow
    $JobProcesses += $nodeProcess
    Pop-Location

    # Android specific configuration
    try {
        adb shell "echo '_ --disable-digital-asset-link-verification-for-url=\""https://flutter.dev\""' > /data/local/tmp/chrome-command-line" 2>$null
    } catch {
        # Ignore errors
    }

    Write-Host "Checking Flutter Environment..."
    flutter --version
    flutter devices
    
    # Run clean/pub get but ignore errors (e.g. missing pubspec.yaml at root)
    try { flutter clean } catch {}
    try { flutter pub get } catch {}

    Push-Location (Join-Path $ProjectDir "flutter_inappwebview\example")
    
    Write-Host "Running Flutter Clean in example..."
    flutter clean

    $driverArgs = @("--driver=test_driver/integration_test.dart", "--target=integration_test/webview_flutter_test.dart")
    if (-not [string]::IsNullOrWhiteSpace($DeviceId)) {
        $driverArgs += "--device-id=$DeviceId"
    }

    Write-Host "Starting Flutter Driver Tests..."
    # Execute flutter driver directly
    & flutter driver $driverArgs --verbose
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Integration tests passed successfully."
    } else {
        Write-ErrorMsg "Some integration tests failed."
        $Failed = 1
    }

} catch {
    Write-ErrorMsg "An error occurred: $_"
    $Failed = 1
} finally {
    Pop-Location
    Cleanup
}

exit $Failed
