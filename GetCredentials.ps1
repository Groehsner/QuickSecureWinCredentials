### This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
### Author: George Roehsner

# use this in scripts needing credentials. update the source and destination systems as necessary

# where to read file of encrypted credentials
# this script will use the credentials retrieved from here
$CredentialsFile = "C:\automation\scripts\sources\automationdata.xml"

# update these for the script we're in
$SourceSystem = "AWS"
$DestinationSystem = "Azure"

# read existing file
try {
    # file was saved with export-clixml so import it if it exists
    $ListOfCredentials = Import-Clixml $CredentialsFile -ErrorAction Stop
} catch {
    # if file is not found then you can send it to log or let transcript capture it if running
    # exit script because without login credentials you can't do anything
    Write-Host "Error reading credentials file"
    Stop-Transcript
    exit
}

# read the source system credentials into a username and password variable.
# get each value and convert it to a secure string
try {
    $SourceUsernameEncrypted = $ListOfCredentials.$SourceSystem.Username | ConvertTo-SecureString -ErrorAction Stop
    # now to get unencrypted username and password. 
    # copy secure string into unencrypted memory location and get a pointer for where the data is stored
    $SourceUsernameBinaryStringPointer = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SourceUsernameEncrypted)

    # read the data from memory and store in variable
    $SourceUsername = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($SourceUsernameBinaryStringPointer)

    # free the memory used by this process
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($SourceUsernameBinaryStringPointer)

    # same steps but for password
    $SourcePasswordEncrypted = $ListOfCredentials.$SourceSystem.Password | ConvertTo-SecureString
    $SourcePasswordBinaryStringPointer = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SourcePasswordEncrypted)
    $SourcePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($SourcePasswordBinaryStringPointer)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($SourcePasswordBinaryStringPointer)

    # same as for source but for destination
    $DestinationUsernameEncrypted = $ListOfCredentials.$DestinationSystem.Username | ConvertTo-SecureString
    $DestinationUsernameBinaryStringPointer = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($DestinationUsernameEncrypted)
    $DestinationUsername = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($DestinationUsernameBinaryStringPointer)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($DestinationUsernameBinaryStringPointer)
    $DestinationPasswordEncrypted = $ListOfCredentials.$DestinationSystem.Password | ConvertTo-SecureString
    $DestinationPasswordBinaryStringPointer = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($DestinationPasswordEncrypted)
    $DestinationPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($DestinationPasswordBinaryStringPointer)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($DestinationPasswordBinaryStringPointer)
} catch {
    Write-Host "Error reading encrypted string. Probably because a user or machine different from ones created with, is trying to read this."
    Stop-Transcript
    exit
}

