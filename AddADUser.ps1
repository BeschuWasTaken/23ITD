# Import required module
Import-Module ActiveDirectory

# Set variables
$csvPath = "C:\Scripts\Input\AddADUsers.csv"
$domainController = "BENENG-DC01"
$domain = "fsi-beneng.com"
$baseOU = "OU=Users,OU=FSI-BENENG,DC=fsi-beneng,DC=com"

# Read CSV file
try {
    $users = Import-Csv -Path $csvPath -Delimiter "," -Encoding UTF8
}
catch {
    Write-Error "Error reading CSV file: $_"
    exit
}

# Process each user
foreach ($user in $users) {
    try {
        # Create name in required format
        $name = if ([string]::IsNullOrWhiteSpace($user.MiddleInitial)) {
            "$($user.Surname), $($user.GivenName)"
        } else {
            "$($user.Surname), $($user.GivenName) $($user.MiddleInitial)"
        }
        $displayName = if ([string]::IsNullOrWhiteSpace($user.MiddleInitial)) {
            "$($user.GivenName) $($user.Surname)"
        } else {
            "$($user.GivenName) $($user.MiddleInitial) $($user.Surname)"
        }

        # Create initials, handling empty MiddleInitial
        $initials = if ([string]::IsNullOrWhiteSpace($user.MiddleInitial)) {
            "$($user.GivenName.Substring(0,1))$($user.Surname.Substring(0,1))"
        } else {
            "$($user.GivenName.Substring(0,1))$($user.MiddleInitial)$($user.Surname.Substring(0,1))"
        }

        # Set user properties
        $userProps = @{
            'Name' = $name
            'DisplayName' = $displayName
            'GivenName' = $user.GivenName
            'Surname' = $user.Surname
            'Initials' = $initials
            'SamAccountName' = $user.SamAccountName
            'UserPrincipalName' = "$($user.SamAccountName)@$domain"
            'Department' = $user.Department
            'MobilePhone' = $user.Mobile
            'Enabled' = $false
            'ChangePasswordAtLogon' = $true
            'AccountPassword' = (ConvertTo-SecureString "Passord1234567" -AsPlainText -Force)
            'Path' = "OU=$($user.Department),$baseOU"
        }

        # Create new user
        New-ADUser @userProps -Server $domainController

        Write-Host "User $($user.SamAccountName) created successfully."
        
        #Show what each of the values would be
        #Write-Host "User properties for $($user.SamAccountName):"
        #$userProps | Format-Table -AutoSize | Out-String | Write-Host
    }
    catch {
        Write-Error "Error creating user $($user.SamAccountName): $_"
        exit
    }
}

Write-Host "All users processed successfully."