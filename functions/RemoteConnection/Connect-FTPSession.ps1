﻿function Connect-FTPSession{
    <#
	    .SYNOPSIS
		    Remote management for ftp sessions

	    .DESCRIPTION
		    Starts a ftp session with the parameters from the remote config file.

	    .PARAMETER  Names
		    Server names from the remote config file

	    .EXAMPLE
		   Connect-FTPSession -Names firewall

    #>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
        [parameter(Mandatory=$true)][string[]]
		$Names
	)

	$Metadata = @{
		Title = "Connect FTP Session"
		Filename = "Connect-FTPSession"
		Description = ""
		Tags = "powershell, remote, session, ftp"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-05-17"
		LastEditDate = "2013-05-17"
		Version = "1.0.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}


    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
   if (Get-Command "winscp.exe"){ 

        # Load Configurations
    	$Config = Get-RemoteConnections -Names $Names

        $Config | %{
    		
            # default settings
            $FTPPort = 21
            $Servername = $_.Server
            $Username = $_.User
            
    		#Get port
    		$_.Protocols | %{if ($_.Name -eq "ftp" -and $_.Port -ne ""){$FTPPort = $_.Port}}
            
            Invoke-Expression ("WinSCP.exe ftp://$Username@$Servername" + ":$FTPPort")
        }
    }
}