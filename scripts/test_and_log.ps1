<#
.SYNOPSIS
    PowerShell equivalent of test_and_log.sh
#>
param(
    [string]$NodeServerIp,
    [string]$DeviceId
)

$ScriptPath = $PSScriptRoot
$ProjectDir = Split-Path -Path $ScriptPath -Parent
$LogFile = Join-Path $ProjectDir "flutter_driver_tests.log"
$TestScript = Join-Path $ScriptPath "test.ps1"

Write-Host "Running tests and logging to $LogFile"

& $TestScript -NodeServerIp $NodeServerIp -DeviceId $DeviceId 2>&1 | Tee-Object -FilePath $LogFile
