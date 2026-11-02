#Requires -Version 5.1
<#
.SYNOPSIS
    Updates the local IPv4 address in Gym mobile project config files.

.DESCRIPTION
    Detects the current Wi-Fi/Ethernet IPv4 address and replaces the hardcoded
    IP in:
      - lib\core\constants\api_constants.dart                  (ApiConstants.baseUrl)
      - android\app\src\debug\res\xml\network_security_config.xml

    Run this whenever your IPv4 address changes (e.g. every few days), then
    hot-restart or rebuild the mobile app.

.PARAMETER Port
    Backend port. Defaults to 8080.

.EXAMPLE
    .\update-ip.ps1
    .\update-ip.ps1 -Port 9090
#>
param(
    [int]$Port = 8080
)

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot

# ── 1. Detect current IPv4 (skip loopback / link-local / virtual) ────────────
try {
    $ip = (
        Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
        Where-Object {
            $_.IPAddress -notmatch '^(127\.|169\.254\.)' -and
            $_.SuffixOrigin -ne 'WellKnown'
        } |
        Sort-Object { [version]$_.IPAddress } -Descending |
        Select-Object -First 1 -ExpandProperty IPAddress
    )
} catch {
    $ip = (
        [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
        Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -ne 'Loopback' } |
        ForEach-Object { $_.GetIPProperties().UnicastAddresses } |
        Where-Object {
            $_.Address.AddressFamily -eq 'InterNetwork' -and
            $_.Address.IPAddressToString -notmatch '^(127\.|169\.254\.)' -and
            $_.SuffixOrigin -ne 'WellKnown'
        } |
        ForEach-Object { $_.Address.IPAddressToString } |
        Sort-Object { [version]$_ } -Descending |
        Select-Object -First 1
    )
}

if (-not $ip) {
    Write-Error "No suitable IPv4 address found. Connect to a network first."
    exit 1
}

Write-Host ""
Write-Host "  Detected IPv4 : $ip"   -ForegroundColor Cyan
Write-Host "  Backend port  : $Port" -ForegroundColor Cyan
Write-Host ""

$changed = $false

# ── 2. Update api_constants.dart (ApiConstants.baseUrl) ──────────────────────
$apiConstantsPath = Join-Path $Root "lib\core\constants\api_constants.dart"
if (Test-Path $apiConstantsPath) {
    $content = Get-Content $apiConstantsPath -Raw
    $updated = $content -replace 'http://[^:/]+:\d+(?=/api/v1)', "http://${ip}:${Port}"
    if ($updated -ne $content) {
        Set-Content $apiConstantsPath -Value $updated -NoNewline
        Write-Host "  [UPDATED]  api_constants.dart          ->  http://${ip}:${Port}/api/v1" -ForegroundColor Green
        $changed = $true
    } else {
        Write-Host "  [OK]       api_constants.dart          already uses ${ip}:${Port}" -ForegroundColor DarkGray
    }
} else {
    Write-Warning "File not found, skipping: $apiConstantsPath"
}

# ── 3. Update network_security_config.xml (keep emulator 10.0.2.2) ────────────
$netSecPath = Join-Path $Root "android\app\src\debug\res\xml\network_security_config.xml"
if (Test-Path $netSecPath) {
    $content = Get-Content $netSecPath -Raw
    $updated = $content -replace '(?<=<domain includeSubdomains="false">)(?!10\.0\.2\.2)[0-9.]+', $ip
    if ($updated -ne $content) {
        Set-Content $netSecPath -Value $updated -NoNewline
        Write-Host "  [UPDATED]  network_security_config.xml ->  $ip" -ForegroundColor Green
        $changed = $true
    } else {
        Write-Host "  [OK]       network_security_config.xml already uses $ip" -ForegroundColor DarkGray
    }
} else {
    Write-Warning "File not found, skipping: $netSecPath"
}

# ── 4. Done ──────────────────────────────────────────────────────────────────
Write-Host ""
if ($changed) {
    Write-Host "  Done! Hot-restart or rebuild the mobile app to pick up changes." -ForegroundColor Cyan
} else {
    Write-Host "  No changes needed." -ForegroundColor Cyan
}
Write-Host ""
