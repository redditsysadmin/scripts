<# CAPI_to_userCertificate.ps1
  PURPOSE: The purpose of this script is to select and publish the public certificates in a user's certificate store
           to their AD userscertificates attribute. The certificate selected must have have the purpose of smart card authentication. 
  
  USAGE:   The script should be run as a logon script as the current user (no privledge elevation is required)
  
  CREDITS: Code to select the certificate based on the the purpose was found here: http://poshcode.org/2207
           The Function to Get the AD user and properties was found here: 
           http://stackoverflow.com/questions/2184692/updating-active-directory-user-properties-in-active-directory-using-powershell?rq=1
           If you are able to use the ActiveDirectory Module you can avoid the search function below and implement something like the post by Lain Robertson here:
           http://social.technet.microsoft.com/Forums/en-US/winserversecurity/thread/65a993c7-0d67-4059-aa3f-47dc8a388de5/

  AUTHOR: Andy Edwards
  DATE: 01/24/2013
  Modified: 03/15/2013 Added better error reporting
  TODO: All info should be sent to application logs for splunk checking. Maybe have some better error catching. Try moving the smtp send to a multiline command
        to improve readability.
  #>

# This function is needed to query AD for the properties of the logged on user.
# It prevents having to use either the Active Directory module or the Quest AD module

function Get-UserAccount( [string]$samid=$env:username){
     $searcher=New-Object DirectoryServices.DirectorySearcher
     # Enter the OU or container that you want the script to look at.
     # If you don't want to limit the search I think you can simply comment the following line.
     $OU = New-Object System.DirectoryServices.DirectoryEntry("LDAP://OU=Users,dc=example,dc=com")
     $searcher.Filter="(&(objectcategory=person)(objectclass=user)(sAMAccountname=$samid))"
     $searcher.SearchRoot = $OU
     $searcher.SearchScope = "Subtree"
     $aduser=$searcher.FindOne()
      if ($aduser -ne $null ){
          $aduser.getdirectoryentry()
     }
}

# Set a few variables
$user = $env:USERNAME
$domain= $env:USERDOMAIN
$ekuName = "Smart Card Logon"
$sccert = ""
$lastrun = ""
$smtpserver = "mailserver.fqdn"
$mailfrom = "noreply@example.com"
$mailto = "Alertme@example.com"


# Go through every certificate in the current user's "My" store
foreach($cert in Get-ChildItem cert:\CurrentUser\My)
{
    # Make sure we are only checking certs that have not expired
    if ( (Get-Date $cert.NotAfter) -gt (Get-Date)){
        
        # For each of those, go through its extensions
        foreach($extension in $cert.Extensions)
        {
            # For each extension, go through its Enhanced Key Usages
            foreach($certEku in $extension.EnhancedKeyUsages)
            {
                # If the friendly name matches, output that certificate
                if($certEku.FriendlyName -eq $ekuName)
                {
                    if( !$sccert ) {
                        $sccert = $cert
                        # write-host "sccert was empty"
                    } else {
                        if( ( Get-Date $cert.NotAfter ) -gt ( Get-Date $sccert.NotAfter)) {
                            $sccert = $cert
                            # write-host "sccert was not empty"
                        }
                    }
                }
            }
        }
   }
}

# We now need to check for a last try file. Whose name matches the cert thumbprint
if( Test-Path $env:APPDATA\CertImport.log ) {
    $lastrun = Get-Content $env:APPDATA\CertImport.log
} 

if ( ($sccert) -and  ( $sccert.thumbprint -ne $lastrun ) ) { 
    # debugging only
    # $sccert.RawData
    
    # There is no record of publishing the certificate for this user on this computer previously
    # Proceed to check the user's attribute to see if the most recent certificate exists.
    $aduser = Get-UserAccount $user
    if ($aduser){
        # Check that the user's lastname (sn attribute) can be found in the certificate subject.
        if ( ($?) -and ( $sccert.Subject -match $aduser.sn) ) {
            # Check to see if the certificate in AD is the same as the one we found
            if ( ($?) -and !($aduser.userCertificate -match $sccert.RawData) ) {
    
                # The the thumprints do not match or there is no certificate published for the user
                # Proceed to publish the most recent certificate
                $aduser.InvokeSet("userCertificate", $sccert.Rawdata)
                $aduser.CommitChanges()

                if ( !$? ) {
                    #send email alert that publishing certificate failed for the specified user
                    Send-MailMessage -From $mailfrom -Subject "publishing certificate failed" -To $mailto -Body "Publishing the Smart Card Certificate for $domain\$user on  computer: $env:COMPUTERNAME failed with error $Error. `n$sccert  Please follow up." -Priority High -SmtpServer $smtpserver
                } Else {
                    #Write a log file with the certificates thumbprint so that we only update if the certificate changes.
                    Write-Host "Smart Card Certificate Successfully Imported into userCertificate attribute"
                    $sccert.Thumbprint > $env:APPDATA\CertImport.log
                }

            } Else {
                # Debugging only
                Write-Host "You already have the latest certificate published"
                $sccert.Thumbprint > $env:APPDATA\CertImport.log
            }
        } Else {
            Send-MailMessage -From $mailfrom -Subject "$user attempted to import someone else's certificate OR Last name is wrong in AD" -To $mailto -Body "User $user attempted to import smart card certificate of another user OR the last name in AD is not spelled correctly`nThe certificate attempted to be imported on $env:Computername is:`n$sccert`nPlease follow up with the user and remove the offending certificate(s) from the user's certificate store." -Priority High -SmtpServer $smtpserver
        }
    } Else {
        Write-Host "User $user was not found in the scope of the directory search. Nothing to do. Exiting."
    } 
} Else {
    # Debugging only
    Write-Host "CertImport.log shows we imported the latest version already. Or there was no valid certificate found."
}