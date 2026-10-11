$ErrorActionPreference = 'Continue'
function Pause-Toolkit { Read-Host 'Press Enter to return to the menu' | Out-Null }
function Show-SystemInfo {
    Write-Host "`n--- System Information ---" -ForegroundColor Cyan
    Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,OSArchitecture,LastBootUpTime | Format-List
    Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer,Model,TotalPhysicalMemory | Format-List
}
function Show-NetworkInfo {
    Write-Host "`n--- Network Configuration ---" -ForegroundColor Cyan

    (Get-NetIPConfiguration | ForEach-Object {
    [PSCustomObject]@{
        Adapter = $_.InterfaceAlias
        IPv4Address = ($_.IPv4Address.IPAddress -join ', ')
        DefaultGateway = ($_.IPv4DefaultGateway.NextHop -join ', ')
        DNSServers = ($_.DNSServer.ServerAddresses -join ', ')
    }
} | Format-List | Out-String)
function Test-Connectivity {
    Write-Host "`n--- Connectivity Checks ---" -ForegroundColor Cyan
    foreach ($target in @('1.1.1.1','example.com')) {
        Write-Host "Testing $target"
        Test-Connection -ComputerName $target -Count 2 -ErrorAction SilentlyContinue | Select-Object Address,ResponseTime,Status | Format-Table -AutoSize
    }
    Write-Host 'If IP connectivity works but DNS name fails, investigate DNS settings.'
}
function Show-StartupApps {
    Write-Host "`n--- Startup Items (read only) ---" -ForegroundColor Cyan
    Get-CimInstance Win32_StartupCommand | Select-Object Name,Command,Location | Format-Table -Wrap
    Write-Host 'Review startup apps in Settings > Apps > Startup. Nothing has been changed.'
}
function Show-InstalledApps {
    Write-Host "`n--- Installed Applications (read only) ---" -ForegroundColor Cyan
    $paths = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')
    Get-ItemProperty $paths -ErrorAction SilentlyContinue | Where-Object DisplayName | Sort-Object DisplayName -Unique | Select-Object DisplayName,DisplayVersion,Publisher | Format-Table -AutoSize
    Write-Host 'To uninstall apps, use Settings > Apps > Installed apps. Nothing has been removed.'
}
function Show-DiskSpace {
    Write-Host "`n--- Disk Space ---" -ForegroundColor Cyan
    Get-PSDrive -PSProvider FileSystem | Select-Object Name,@{N='UsedGB';E={[math]::Round($_.Used/1GB,2)}},@{N='FreeGB';E={[math]::Round($_.Free/1GB,2)}} | Format-Table -AutoSize
}
function Export-Report {
    $path = Join-Path ([Environment]::GetFolderPath('Desktop')) ('WindowsToolkit-Report-{0}.txt' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    $info = @('Windows Optimization Toolkit - Diagnostic Report',('Generated: ' + (Get-Date)),'','OS:',(Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,OSArchitecture | Format-List | Out-String),'Disk:',(Get-PSDrive -PSProvider FileSystem | Select-Object Name,Used,Free | Format-Table | Out-String),'Network:',(Get-NetIPConfiguration | Select-Object InterfaceAlias,IPv4Address,IPv4DefaultGateway | Format-List | Out-String))
    $info | Out-File -FilePath $path -Encoding utf8
    Write-Host "Report saved: $path" -ForegroundColor Green
    Write-Warning 'Reports can include device and network information. Review before sharing.'
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
    Write-Host '7. Export basic diagnostic report to Desktop'
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
            default { Write-Host 'Invalid selection.'; Pause-Toolkit }
        }
    } catch { Write-Warning "Operation failed: $($_.Exception.Message)"; Pause-Toolkit }
} while ($choice -ne '0')
