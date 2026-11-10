param(
    [switch]$Check,
    # Keep regeneration reproducible across machines and SDK upgrades.
    [string]$FxcPath = "${env:ProgramFiles(x86)}/Windows Kits/10/bin/10.0.26100.0/x64/fxc.exe"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Read-ShaderBytes([string]$Path) {
    $text = [IO.File]::ReadAllText($Path)
    $match = [regex]::Match($text,
        '(?s)const\s+BYTE\s+kFrameCompareCs\s*\[\s*\]\s*=\s*\{(?<bytes>.*?)\}\s*;')
    if (-not $match.Success) {
        throw "Missing kFrameCompareCs byte array in $Path"
    }
    [byte[]]$bytes = @($match.Groups['bytes'].Value.Split(',') |
        Where-Object { $_.Trim().Length -gt 0 } |
        ForEach-Object { [byte]$_.Trim() })
    if ($bytes.Length -eq 0) {
        throw "Empty shader byte array in $Path"
    }
    return [Convert]::ToBase64String($bytes)
}

$shaderDirectory = Join-Path $PSScriptRoot '../windows/custom_platform_view'
$source = Join-Path $shaderDirectory 'frame_compare.hlsl'
$header = Join-Path $shaderDirectory 'frame_compare_cs.h'
if (-not (Test-Path -LiteralPath $FxcPath -PathType Leaf)) {
    throw "Install Windows SDK 10.0.26100.0 or pass -FxcPath to its fxc.exe. Missing: $FxcPath"
}

$temporaryHeader = [IO.Path]::GetTempFileName()
try {
    & $FxcPath /nologo /T cs_5_0 /E main /Vn kFrameCompareCs /Fh $temporaryHeader $source
    if ($LASTEXITCODE -ne 0) {
        throw "fxc failed with exit code $LASTEXITCODE"
    }
    $generatedBytes = Read-ShaderBytes $temporaryHeader
    if ($Check) {
        if ($generatedBytes -cne (Read-ShaderBytes $header)) {
            throw 'frame_compare_cs.h is stale. Run tool/update_frame_compare_shader.ps1 and commit the regenerated header.'
        }
        Write-Output 'frame_compare_cs.h matches frame_compare.hlsl.'
    } else {
        Copy-Item -LiteralPath $temporaryHeader -Destination $header
        Write-Output "Regenerated $header"
    }
} finally {
    Remove-Item -LiteralPath $temporaryHeader -Force
}
