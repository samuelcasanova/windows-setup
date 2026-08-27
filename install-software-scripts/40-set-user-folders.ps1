#Requires -Version 5.1
<#
.SYNOPSIS
    Points this user's Documents/Music/Pictures/Videos known folders at the homeserver Samba shares.

.DESCRIPTION
    Run once per account, logged in as that account, from a NON-elevated PowerShell.

    Tries the official shell API (SHSetKnownFolderPath) first, verifies the result by reading the
    registry back, and falls back to writing the User Shell Folders values directly if the API did
    not take. Also stores the share credential, pins folders to Quick Access and restarts Explorer.

.EXAMPLE
    .\40-set-user-folders.ps1 -User judit

.EXAMPLE
    .\40-set-user-folders.ps1 -User samuel -WhatIf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('samuel', 'judit', 'victor', 'alex')]
    [string]$User,

    [SecureString]$SmbPassword,

    [switch]$SkipCredentials
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\support-files\utils.ps1"

$Config = Import-PowerShellDataFile -Path "$PSScriptRoot\support-files\network-folders.psd1"
$Server = $Config.Server
$UserConfig = $Config.Users[$User]

$ExplorerKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
$UserShellFolders = "$ExplorerKey\User Shell Folders"
$ShellFolders = "$ExplorerKey\Shell Folders"

$RegistryValueName = @{
    Documents = 'Personal'
    Music     = 'My Music'
    Pictures  = 'My Pictures'
    Videos    = 'My Video'
}

function Test-IsElevated {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $identity).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-CurrentFolderPath {
    param([string]$ValueName)
    $item = Get-ItemProperty -Path $UserShellFolders -Name $ValueName -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    $item.$ValueName
}

function Set-FolderPathViaRegistry {
    param([string]$ValueName, [string]$Path)
    foreach ($key in @($UserShellFolders, $ShellFolders)) {
        New-ItemProperty -Path $key -Name $ValueName -Value $Path -PropertyType ExpandString -Force | Out-Null
    }
}

function Get-QuickAccessPath {
    $quickAccess = (New-Object -ComObject shell.application).Namespace('shell:::{679F85CB-0220-4080-B29B-5540CC05AAB6}')
    if ($null -eq $quickAccess) { return @() }
    @($quickAccess.Items() | ForEach-Object { $_.Path })
}

if (Test-IsElevated) {
    throw 'Run this from a normal (non-elevated) PowerShell. An admin shell is a different user context, so the redirect would land on the wrong profile.'
}

# Windows often truncates the profile/account name (samuel -> samue), so accept either as a prefix.
if (-not ($env:USERNAME -like "$User*" -or $User -like "$($env:USERNAME)*")) {
    Write-Warning "Logged in as '$env:USERNAME' but configuring '$User'. This only ever changes the CURRENT user's folders - press Ctrl+C now if that is not what you want."
}

Write-Host "Configuring network folders for '$User' on $Server" -ForegroundColor Cyan

$backupDir = Join-Path $env:LOCALAPPDATA 'windows-setup\backup'
$backupFile = Join-Path $backupDir ("{0}-{1}.reg" -f $User, (Get-Date -Format 'yyyyMMdd-HHmmss'))
if ($PSCmdlet.ShouldProcess($backupFile, 'Back up current Explorer folder keys')) {
    New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    & reg.exe export 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer' $backupFile /y | Out-Null
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $backupFile)) {
        throw "Could not write the rollback backup to '$backupFile' (reg export exit code $LASTEXITCODE). Refusing to change anything without it."
    }
    Write-Host "  backup   $backupFile"
}

if (-not $SkipCredentials) {
    if ($PSCmdlet.ShouldProcess($Server, "Store share credential for '$User'")) {
        if (-not $SmbPassword) {
            $SmbPassword = Read-Host -Prompt "Samba password for '$User'" -AsSecureString
        }
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SmbPassword)
        try {
            $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
            & cmdkey.exe "/add:$Server" "/user:$User" "/pass:$plain" | Out-Null
        }
        finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
            Remove-Variable plain -ErrorAction SilentlyContinue
        }
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "cmdkey failed (exit code $LASTEXITCODE). The shares may prompt for credentials; the redirect below can still fall back to the registry method."
        }
        Write-Host "  cmdkey   $Server as $User"
    }
}

foreach ($folder in @('Documents', 'Music', 'Pictures', 'Videos')) {
    $target = $UserConfig.Folders[$folder]
    $valueName = $RegistryValueName[$folder]

    if ((Get-CurrentFolderPath $valueName) -eq $target) {
        Write-Host ("  {0,-9} unchanged  {1}" -f $folder, $target)
        continue
    }

    if (-not $PSCmdlet.ShouldProcess($target, "Redirect $folder")) { continue }

    $method = 'api'
    try {
        Set-KnownFolderPath -KnownFolder $folder -Path $target
    }
    catch {
        Write-Verbose "SHSetKnownFolderPath failed for ${folder}: $($_.Exception.Message)"
        $method = 'registry'
    }

    if ($method -eq 'api' -and (Get-CurrentFolderPath $valueName) -ne $target) {
        Write-Verbose "SHSetKnownFolderPath reported success for $folder but the registry did not change."
        $method = 'registry'
    }

    # The API only writes User Shell Folders; mirror into the legacy Shell Folders cache the way
    # Windows itself does at logon, so apps that still read it agree with Explorer before reboot.
    Set-FolderPathViaRegistry -ValueName $valueName -Path $target

    if ((Get-CurrentFolderPath $valueName) -ne $target) {
        throw "Failed to redirect $folder to '$target' by either method."
    }

    Write-Host ("  {0,-9} {1,-10} {2}" -f $folder, $method, $target)
}

if ($UserConfig.ContainsKey('QuickAccess')) {
    $pinned = @(Get-QuickAccessPath)
    foreach ($path in $UserConfig.QuickAccess) {
        if ($pinned -contains $path) {
            Write-Host ("  pin       unchanged  {0}" -f $path)
            continue
        }
        if (-not (Test-Path $path -ErrorAction SilentlyContinue)) {
            Write-Warning "Cannot reach '$path' - skipping Quick Access pin."
            continue
        }
        if ($PSCmdlet.ShouldProcess($path, 'Pin to Quick Access')) {
            $namespace = (New-Object -ComObject shell.application).Namespace($path)
            if ($null -eq $namespace) {
                Write-Warning "Shell could not open '$path' - skipping Quick Access pin."
                continue
            }
            $namespace.Self.InvokeVerb('pintohome')
            Write-Host ("  pin       added      {0}" -f $path)
        }
    }
}

if ($PSCmdlet.ShouldProcess('explorer.exe', 'Restart to apply')) {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Write-Host '  explorer restarted'
}

Write-Host "Done. Verify with: [Environment]::GetFolderPath('MyDocuments')" -ForegroundColor Green
