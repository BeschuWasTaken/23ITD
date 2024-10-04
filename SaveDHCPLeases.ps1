# Define the DHCP server details
$dhcpServer = "BENENG-DC02"
$dhcpServerIP = "172.16.13.11"

# Define the output CSV file path
$outputFile = "C:\DHCPLeases_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"

# Get all DHCP scopes
$scopes = Get-DhcpServerv4Scope -ComputerName $dhcpServer

# Initialize an array to store lease information
$leases = @()

# Iterate through each scope and get lease information
foreach ($scope in $scopes) {
    $scopeLeases = Get-DhcpServerv4Lease -ComputerName $dhcpServer -ScopeId $scope.ScopeId

    foreach ($lease in $scopeLeases) {
        $leaseInfo = [PSCustomObject]@{
            ScopeId      = $lease.ScopeId
            IPAddress    = $lease.IPAddress
            HostName     = $lease.HostName
            ClientID     = $lease.ClientId
            AddressState = $lease.AddressState
        }
        $leases += $leaseInfo
    }
}

# Export the lease information to CSV
$leases | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "DHCP lease information has been exported to: $outputFile"