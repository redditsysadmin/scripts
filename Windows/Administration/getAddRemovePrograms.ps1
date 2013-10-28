<#
.SYNOPSIS
    Gets uninstall records from the registry.

.SOURCE
    http://stackoverflow.com/questions/4753051/how-do-i-check-if-a-particular-msi-is-installed

.DESCRIPTION
    This function returns information similar to the "Add or remove programs"
    Windows tool. The function normally works much faster and gets some more
    information.

    Another way to get installed products is: Get-WmiObject Win32_Product. But
    this command is usually slow and it returns only products installed by
    Windows Installer.

    x64 notes. 32 bit process: this function does not get installed 64 bit
    products. 64 bit process: this function gets both 32 and 64 bit products.
#>
function Get-Uninstall ( [string]$program )
{
    # paths: x86 and x64 registry keys are different
    if ([IntPtr]::Size -eq 4) {
        $path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    }
    else {
        $path = @(
            'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
            'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
        )
    }

    # get all data
    Get-ItemProperty $path |
    # use only with name and unistall information
    .{process{ if ($_.DisplayName -and $_.UninstallString) { $_ } }} |
    #Narrow Search Result
    where { $_.DisplayName -match $program} 
    # Uncomment the following line to limit the items returned to the subset below.
    # Select-Object DisplayName, Publisher, InstallDate, DisplayVersion, HelpLink, UninstallString |
    # and finally sort by name
    Sort-Object DisplayName
}

# Example of usage printing attributes for Firefox Uncomment the following lines to see what they return
$program = Get-Uninstall $args[0]
#$program.DisplayName
#$program.DisplayVersion
#$program.UninstallString
$program
