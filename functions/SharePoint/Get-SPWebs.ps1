<#
$Metadata = @{
    Title = "Get SharePoint Websites"
	Filename = "Get-SPWebs.ps1"
	Description = ""
	Tags = ""powershell, sharepoint, function"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-07-29"
	LastEditDate = "2013-07-29"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-SPWebs{

<#

.SYNOPSIS
    Get SharePoint websites.

.DESCRIPTION
	Return websites of a SharePoint website recursively.
    
.PARAMETER Url
	Url of the SharePoint website including subsites.

.EXAMPLE
	PS C:\> Get-SPWebs -Url "http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx"

#>

	param(
		[Parameter(Mandatory=$false)]
		[string]$Url
	)
    
    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#
    if ((Get-PSSnapin “Microsoft.SharePoint.PowerShell” -ErrorAction SilentlyContinue) -eq $null) {
        Add-PSSnapin “Microsoft.SharePoint.PowerShell”
    }

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    
    if($Url){
    
        # extract spweb url
        [Uri]$SPWebUrl = $Url.ToString() -replace "/SitePages/Homepage.aspx",""
        
        # get spweb object
        $SPWeb = Get-SPWeb -Identity $SPWebUrl.OriginalString   
        
        # output the spweb object
        $SPWeb
        
        # run this function for every subsite
        if($SPWeb.webs.Count -ne 0){$SPWeb.webs | %{Get-SPWebs -Url $_.Url}}    
    
    }else{
    
        # get all websites
        Get-SPWebApplication | Get-SPsite -Limit all | %{
            $_ |  Get-SPWeb -Limit all
        }  
    }
}