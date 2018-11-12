### This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
### Author: George Roehsner

# This script will prompt a user for systems and the credentials for them. It will save those credentials in a file spcecified in this script.
# The credentials, both username and password, are encrypted using windows dpapi features.
Start-Transcript -Path "c:\automation\logs\ManageCredentials$(get-date -format FileDateTime).log" -Append

# Update where to save file of encrypted credentials
$CredentialsFile = "C:\automation\scripts\sources\automationdata.xml"

# read existing file
try {
    # file was saved with export-clixml so import it if it exists
    $ListOfCredentials = Import-Clixml $CredentialsFile -ErrorAction Stop
} catch {
    # if file is not found then create new dictionary object
    Write-Host "Can't read existing file. Starting new file of credentials"
    $ListOfCredentials = @{}
}

Write-Host "Add new or update existing credentials. Start by entering a name to identify what the credentials are for. Then enter the username, then password."
# loop through reading credential objects until q or quit is entered
:MainLoop While ($True) {
    $CredentialsFor = Read-Host -Prompt "Enter Name of system. s or save to write file, q or quit to exit"
    switch -regex ($CredentialsFor) {
        '^q(uit)?$' {
            # user chose to quit script. exit this while loop, then finish up any necessary script cleanup.
            Write-Host "Exiting the script"
            break MainLoop
        }
        '^s(ave)?$' {
            # user chose to save. save file, catching and reporting errors, then start main loop over.
            Write-Host "Saving file"
            try {
                # save hashtable object as xml file
                $ListOfCredentials | Export-Clixml $CredentialsFile -ErrorAction Stop
            } catch {
                # there was an error writing file, notify user and then end script
                Write-Host "There was an error writing the file:" -ForegroundColor Red
                Write-Host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
                Write-Host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
                
                # allow user to review error message. Wait for them to return before ending script
                Read-Host -Prompt "Nothing was saved. Ending the script now. Return when ready."
                break MainLoop
            }
            # if we're here then the file was saved without error.
            Write-Host "Credentials saved to file $CredentialsFile"
        }

        default {
            # user started a credential creation/update process. Get username and password now.
            # prompt user for the information, retrieving it as an encrypted value (AsSecureString)
            # then converting it to an actual string, still encrypted, so we can save it in a file.
            $CredentialsUsername = Read-Host -Prompt "Username for system" -AsSecureString | ConvertFrom-SecureString
            $CredentialsPassword = Read-Host -Prompt "Password for system" -AsSecureString | ConvertFrom-SecureString

            # now that we have all of the information. Add this credential to the list
            $ListOfCredentials.$CredentialsFor = @{"Username"=$CredentialsUsername;"Password"=$CredentialsPassword}
        }
    }

}
Stop-Transcript