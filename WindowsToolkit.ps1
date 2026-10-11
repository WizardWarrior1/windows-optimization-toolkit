# Simple Little Project
# Windows Optimization Toolkit | Help Desk Portfolio Project
# Read-only diagnostics for Windows 10/11.
# No administrator privileges required for typical use.
# Diagnostic reports may contain sensitive device/network information.

$ErrorActionPreference = 'Stop'

function Pause-Toolkit {
    [void](Read-Host 'Press Enter to return to the menu')
}

function Get-NetworkSummary {
    Get-NetIPConfiguration | ForEach-Object {
        [PSCustomObject]@{
            Adapter        = $_.InterfaceAlias
            IPv4Address    = ($_.IPv4Address.IPAddress -join ', ')
            DefaultGateway = ($_.IPv4DefaultGateway.NextHop -join ', ')
            DNSServers     = ($_.DNSServer.ServerAddresses -join ', ')
        }
    }
}

function Show-SystemInfo {
    Write-Host "`n--- System Information ---" -ForegroundColor Cyan

    Get-CimInstance Win32_OperatingSystem |
        Select-Object Caption, Version, OSArchitecture, LastBootUpTime |
        Format-List

    Get-CimInstance Win32_ComputerSystem |
        Select-Object Manufacturer, Model,
            @{Name='RAM_GB';Expression={
                [math]::Round($_.TotalPhysicalMemory / 1GB, 2)
            }} |
        Format-List
}

function Show-NetworkInfo {
    Write-Host "`n--- Network Configuration ---" -ForegroundColor Cyan

    Get-NetworkSummary | Format-List
}

function Test-Connectivity {
    Write-Host "`n--- Connectivity Checks ---" -ForegroundColor Cyan

    foreach ($target in @('1.1.1.1', 'example.com')) {
        Write-Host "Testing $target" -ForegroundColor Yellow

        $result = Test-Connection -ComputerName $target -Count 2 -ErrorAction SilentlyContinue

        if ($result) {
            $result |
                Select-Object Address, ResponseTime, Status |
                Format-Table -AutoSize
        }
        else {
            Write-Warning "No ping response from $target. ICMP may be blocked; this alone does not prove the network is down."
        }
    }

    try {
        Resolve-DnsName example.com -ErrorAction Stop |
            Where-Object Type -eq 'A' |
            Select-Object -First 3 Name, IPAddress |
            Format-Table -AutoSize
    }
    catch {
        Write-Warning "DNS lookup failed: $($_.Exception.Message)"
    }
}

function Show-StartupApps {
    Write-Host "`n--- Startup Items (read only) ---" -ForegroundColor Cyan

    Get-CimInstance Win32_StartupCommand |
        Select-Object Name, Command, Location |
        Format-Table -Wrap

    Write-Host 'Review startup apps in Settings > Apps > Startup. No changes made.'
}

function Show-InstalledApps {
    Write-Host "`n--- Installed Applications (read only) ---" -ForegroundColor Cyan

    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    Get-ItemProperty $paths -ErrorAction SilentlyContinue |
        Where-Object DisplayName |
        Sort-Object DisplayName -Unique |
        Select-Object DisplayName, DisplayVersion, Publisher |
        Format-Table -AutoSize

    Write-Host 'To remove software, use Settings > Apps > Installed apps. No changes made.'
}

function Show-DiskSpace {
    Write-Host "`n--- Disk Space ---" -ForegroundColor Cyan

    Get-PSDrive -PSProvider FileSystem |
        Select-Object Name,
            @{Name='UsedGB';Expression={
                [math]::Round($_.Used / 1GB, 2)
            }},
            @{Name='FreeGB';Expression={
                [math]::Round($_.Free / 1GB, 2)
            }} |
        Format-Table -AutoSize
}

function Export-Report {
    $desktop = [Environment]::GetFolderPath('Desktop')

    if (-not $desktop -or -not (Test-Path -LiteralPath $desktop -PathType Container)) {
        $desktop = [Environment]::GetFolderPath('MyDocuments')
        Write-Warning 'Desktop folder unavailable; using Documents instead.'
    }

    if (-not $desktop -or -not (Test-Path -LiteralPath $desktop -PathType Container)) {
        throw 'Neither Desktop nor Documents is available for report export.'
    }

    $path = Join-Path $desktop (
        'WindowsToolkit-Report-{0}.txt' -f (Get-Date -Format 'yyyyMMdd-HHmmss')
    )

    $report = @(
        'Windows Optimization Toolkit - Diagnostic Report'
        ('Generated: ' + (Get-Date))
        ''
        'Operating System:'
        (Get-CimInstance Win32_OperatingSystem |
            Select-Object Caption, Version, OSArchitecture |
            Format-List | Out-String)

        'Disk Space:'
        (Get-PSDrive -PSProvider FileSystem |
            Select-Object Name,
                @{Name='UsedGB';Expression={
                    [math]::Round($_.Used / 1GB, 2)
                }},
                @{Name='FreeGB';Expression={
                    [math]::Round($_.Free / 1GB, 2)
                }} |
            Format-Table -AutoSize | Out-String)

        'Network Configuration:'
        (Get-NetworkSummary | Format-List | Out-String)
    )

    $report | Out-File -LiteralPath $path -Encoding utf8

    Write-Host "Report saved: $path" -ForegroundColor Green
    Write-Warning 'Report contains device and network information. Review and redact before sharing.'
}

do {
    Clear-Host

    Write-Host '=== Windows Optimization Toolkit ===' -ForegroundColor Cyan
    Write-Host '1. View system information'
    Write-Host '2. View network configuration'
    Write-Host '3. Test internet and DNS connectivity'
    Write-Host '4. Review startup applications (read-only)'
    Write-Host '5. Review installed applications (read-only)'
    Write-Host '6. Check disk space'
    Write-Host '7. Export diagnostic report to Desktop (or Documents)'
    Write-Host '0. Exit'

    $choice = Read-Host 'Choose an option'

    try {
        switch ($choice) {
            '1' { Show-SystemInfo; Pause-Toolkit }
            '2' { Show-NetworkInfo; Pause-Toolkit }
            '3' { Test-Connectivity; Pause-Toolkit }
            '4' { Show-StartupApps; Pause-Toolkit }
            '5' { Show-InstalledApps; Pause-Toolkit }
            '6' { Show-DiskSpace; Pause-Toolkit }
            '7' { Export-Report; Pause-Toolkit }
            '0' { Write-Host 'Goodbye!' }
            default {
                Write-Host 'Invalid selection.'
                Pause-Toolkit
            }
        }
    }
    catch {
        Write-Warning "Operation failed: $($_.Exception.Message)"
        Pause-Toolkit
    }

} while ($choice -ne '0')
