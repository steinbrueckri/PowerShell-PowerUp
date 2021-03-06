<#
$Metadata = @{
	Title = "Get Path And Filename"
	Filename = "Get-PathAndFilename.ps1"
	Description = ""
	Tags = ""
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-02-05"
	LastEditDate = "2014-02-05"
	Url = ""
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-PathAndFilename{

<#
.SYNOPSIS
    Function detects path and filename from unspecific path.

.DESCRIPTION
	Function detects path and filename from unspecific path. It resolves environment variables, powershell variables and relative paths.

.PARAMETER Path
	Unspecific path.

.EXAMPLE
    PS C:\Users\vonrotz> Get-PathAndFilename C:\Benutzer\..\Windows\calculator.exe

    Name                           Value                                                                                                                                                                                                           
    ----                           -----                                                                                                                                                                                                           
    Path                           C:\Windows                                                                                                                                                                                                      
    Filename                       calculator.exe    
    
.EXAMPLE
    PS C:\Users\vonrotz> Get-PathAndFilename $home\..\Windows\calculator.exe

    Name                           Value                                                                                                                                                                                                           
    ----                           -----                                                                                                                                                                                                           
    Path                           C:\Users\Windows                                                                                                                                                                                                
    Filename                       calculator.exe  
    
.EXAMPLE
    PS C:\Users\vonrotz> Get-PathAndFilename calculator.exe

    Name                           Value                                                                                                                                                                                                           
    ----                           -----                                                                                                                                                                                                           
    Path                                                                                                                                                                                                                                           
    Filename                       calculator.exe   
    
.EXAMPLE
    PS C:\Users\vonrotz> Get-PathAndFilename "%SystemRoot%\Git\bin\"

    Name                           Value                                                                                                                                                                                                           
    ----                           -----                                                                                                                                                                                                           
    Path                           C:\Windows\Git\bin\                                                                                                                                                                                             
    Filename                                              
    
#>

    [CmdletBinding()]
    param(

		[Parameter( Mandatory=$true)]
		[String]
		$Path
	)

    # system variables
    $Path = [System.Environment]::ExpandEnvironmentVariables($Path)
    
    # powershell variables
    if($Path.contains("$")){
        $Path = Invoke-Expression "`"$Path`""
    }

    # relative paths
    if($Path.StartsWith("\")){
        $Path = Join-Path -Path $(Get-Location).Path -Childpath $Path
    }
    
    # if is only filename
    if(-not $Path.Contains("\")){
    
        $Filename = $Path
        $Path = $null
    
    }else{
    
        # folder up paths
        $ResolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
        $Path = $ResolvedPath + $(if($Path.EndsWith("\") -and -not $ResolvedPath.EndsWith("\")){"\"})

        # check for filename
        if($Path.EndsWith("\")){
        
            $Filename = $null
        
        }else{
            
            $Filename = Split-Path $Path -Leaf
            $Path = Split-Path $Path -Parent         
        }
    }
    
    @{
        Path = $Path
        Filename = $FileName    
    }
}