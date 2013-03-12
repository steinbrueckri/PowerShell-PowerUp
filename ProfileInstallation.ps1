$Metadata = @{
	Title = "Profile Installation"
	Filename = "ProfileInstallation.ps1"
	Description = ""
	Tags = "powershell, profile, installation"
	Project = ""
	Author = "Janik von Rotz"
	AuthorEMail = "contact@janikvonrotz.ch"
	CreateDate = "07.01.2013"
	LastEditDate = "12.03.2013"
	Version = "2.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.�
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@

}

if($Host.Version.Major -ne 3){
    throw "Only compatible with Powershell version 3"
}else{

    #--------------------------------------------------#
    #  Settings
    #--------------------------------------------------#
    [string]$WorkingPath = Get-Location
    $ModulesPath = "\Modules"
    $FunctionPath = "\Functions"

    #--------------------------------------------------#
    # Includes
    #--------------------------------------------------#
    Set-Location ($WorkingPath + $FunctionPath)
    get-childitem | foreach {. .\$_}
     # Go back to working directory
    Set-Location $WorkingPath

    #--------------------------------------------------#
    # Main
    #--------------------------------------------------#

    # LoadConfig
    $Configuration = Get-XmlConfig Config.xml

    # Registry Settings
    foreach ($RegistryEntry in $Configuration.RegistryEntries.RegistryEntry)
    {
	    Set-ItemProperty -Path $RegistryEntry.Path -Name $RegistryEntry.Name -Value $RegistryEntry.Value
    }

    # Import Pscx Extension
    $env:PSModulePath += ";"+ $WorkingPath + $ModulesPath
    Import-Module Pscx

    # Add System Variables
    foreach ($SystemVariable in $Configuration.SystemVariables.SystemVariable)
    {
	    if($SystemVariable.RelativePath -eq "true")
	    {
		    $SystemVariable.Value = ($(Get-Location).Path + $SystemVariable.Value)
		    Add-PathVariable -Value $SystemVariable.Value -Name $SystemVariable.Name -Target $SystemVariable.Target
	    }else{
		    Add-PathVariable -Value $SystemVariable.Value -Name $SystemVariable.Name -Target $SystemVariable.Target
	    }
    }

    # Enable Open Powershell here
    Enable-OpenPowerShellHere

    #--------------------------------------------------#
    # Powershell Default Profile
    #--------------------------------------------------#

    # Create Powershell Profile
    if (!(Test-Path $Profile)){

	      # Create a profile
	    New-Item -path $Profile -type file -force
    }

    # Link Powershell Profile
    $SourcePath = Split-Path $profile -parent
    $ScriptName = $MyInvocation.MyCommand.Name

    if (!(Test-Path ($SourcePath + "\" + $ScriptName) -PathType Leaf))
    {
	    # Rename default source
	    Rename-Item $SourcePath ($SourcePath + "-Obsolete")
	 
	    # Create a shortcut to the existing powershell profile
	    New-Symlink $SourcePath $WorkingPath
    }
}