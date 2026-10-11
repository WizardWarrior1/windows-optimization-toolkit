# Windows Optimization Toolkit

A beginner-friendly **PowerShell IT support portfolio project** for Windows 10/11. It provides a menu of read-only diagnostic and maintenance review tools that help demonstrate basic help desk troubleshooting workflows.

## Features

- View Windows OS and hardware information
- Inspect IP addresses, gateways, and DNS configuration
- Check connectivity by IP address and hostname
- Review startup applications without modifying them
- Review installed desktop applications without removing them
- Check available disk space
- Export a basic system/network diagnostic report to the Desktop

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or later
- Most options do not require administrator privileges; access to certain system details may vary

## Run

1. Download `WindowsToolkit.ps1` from this repository.
2. Open Windows PowerShell.
3. Navigate to the folder containing the script, e.g. `cd "$HOME\Downloads"`.
4. Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WindowsToolkit.ps1` **only after reviewing the script**. This changes execution policy for that process only; it does not change your system-wide policy.
5. Select a number from the menu.

## Safety

The script **does not uninstall applications, delete files, edit the registry, disable services, or disable security features**. Review diagnostic reports before sharing because they can contain device or network details. Only run scripts you understand and trust.

## Help desk skills demonstrated

Windows administration fundamentals, PowerShell scripting, IP/DNS diagnostics, application inventory, startup review, disk capacity checks, troubleshooting documentation.

## Next steps

- Add screenshots of the menu and output (redact personal/device information)
- Add structured error logging and unit tests
- Test on multiple Windows versions and document results

## Project status

Starter portfolio project; test on your own Windows machine before describing it as validated or production-ready.
