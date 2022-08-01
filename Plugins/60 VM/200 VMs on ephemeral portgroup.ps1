$Title = "VMs on Ephemeral Portgroup"
$Header = "VMs on Ephemeral Portgroup: [count]"
$Comments = ""
$Display = "Table"
$Author = "Tim Williams (Modified by Douglas Wilkins)"
$PluginVersion = 1.1.1
$PluginCategory = "vSphere"

# Start of Settings
# End of Settings
 
# Obtain the Revision number of the VMWare.PowerCLI modules
$Revision=(Get-Module VMWare.PowerCLI -listavailable).Version.Revision

if ($Revision) {
    if ($Revision -ge 1012425) {
        $VersionOK = $true
        if ($Revision -ge 2548067) {
            #PowerCLI 6+
            if ((Get-Module -Name VMware.VimAutomation.Vds  -listavailable -ErrorAction SilentlyContinue))
            {
                Import-Module VMware.VimAutomation.Vds
            }
            else
            {
                # Add required Snap-In
                if (!(Get-PSSnapin -name VMware.VimAutomation.Vds -ErrorAction SilentlyContinue))
                {
                    Add-PSSnapin VMware.VimAutomation.Vds
                }
            }
        }
    }
}

if ($VersionOK) {
    $EphemeralReport = @()
     
    $EphemeralPG = Get-VDSwitch | Get-VDPortgroup | where {$_.PortBinding -eq "Ephemeral"}
    if ($EphemeralPG) {
        $vNetworkAdapter = $VM | Get-NetworkAdapter | where {$_.NetworkName -contains $EphemeralPG}
        ForEach ($v in $vNetworkAdapter) {
            $vDSSummary = "" | Select VMName, Portgroup
            $vDSSummary.Portgroup = $v.NetworkName
            $vDSSummary.VMName = $v.parent
            $EphemeralReport += $vDSSummary
        }
    }
    $EphemeralReport
} else {
   Write-Warning "PowerCLi version installed is lower than 5.1 Release 2"
   New-Object PSObject -Property @{"Message"="PowerCLi version installed is lower than 5.1 Release 2, please update to use this plugin"}
}

# Change Log
## 1.0 : Initial release
## 1.1 : Modified Where-Object filter to retreive result when there are more then one $EphemeralPG object
## 1.1.1 : Added check for PowerCLI version installed
