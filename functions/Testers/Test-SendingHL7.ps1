<#
.SYNOPSIS
Test-SendingHL7

.DESCRIPTION
Test-SendingHL7

.INPUTS
Test-SendingHL7 - The name of Test-SendingHL7

.OUTPUTS
None

.EXAMPLE
Test-SendingHL7

.EXAMPLE
Test-SendingHL7


#>
function Test-SendingHL7() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InterfaceEngineHost
    )

    Write-Verbose 'Test-SendingHL7: Starting'

    # from http://www.mieweb.com/wiki/Sample_HL7_Messages#ADT.5EA01
    [string] $message = @"
MSH|^~\&|SENDING_APPLICATION|SENDING_FACILITY|RECEIVING_APPLICATION|RECEIVING_FACILITY|20110613083617||ADT^A01|934576120110613083617|P|2.3||||
EVN|A01|20110613083617|||
PID|1||135769||MOUSE^MICKEY^||19281118|M|||123 Main St.^^Lake Buena Vista^FL^32830||(407)939-1289^^^theMainMouse@disney.com|||||1719|99999999||||||||||||||||||||
PV1|1|O|||||^^^^^^^^|^^^^^^^^
"@

    $leadingCharacter = [char]11
    $endingCharacter1 = [char]28
    $endingCharacter2 = [char]13
    # [string] $command = "${leadingCharacter}${message}${endingCharacter1}${endingCharacter2}"
    # [string] $command = $leadingCharacter + $message + $endingCharacter1 + $endingCharacter2
    # [string] $command = [System.Convert]::ToChar(11) + $leadingCharacter + $message + [System.Convert]::ToChar(28) + [System.Convert]::ToChar(13)

    [string] $command = $leadingCharacter + $message + $endingCharacter1 + $endingCharacter2

    $data = [System.Text.ASCIIEncoding]::ASCII.GetBytes($command)

    [int] $port = 6661

    [System.Net.IPAddress] $ipaddress = [System.Net.IPAddress]::Parse($InterfaceEngineHost);

    [System.Net.IPEndPoint] $ipe = New-Object System.Net.IPEndPoint($ipaddress, $port)
    [System.Net.Sockets.SocketType] $socketType = [System.Net.Sockets.SocketType]::Stream

    [System.Net.Sockets.Socket] $tempSocket = New-Object System.Net.Sockets.Socket($ipe.AddressFamily, `
                                                                     $socketType, [System.Net.Sockets.ProtocolType]::Tcp);

    $tempSocket.Connect($ipe)

    $tempSocket.Send($data, $data.Length, 0);

    $tempSocket.ReceiveTimeout = 30000;

    [int] $bytes = 0

    $bytesReceived = new-object System.Byte[] 1024
    $bytes = $tempSocket.Receive($bytesReceived, $bytesReceived.Length, 0)
    [string] $page = [System.Text.ASCIIEncoding]::ASCII.GetString($bytesReceived, 0, $bytes);

    Write-Host "------------- Response ------------"
    Write-Host $page
    Write-Host "------------- End of Response ------------"

    $tempSocket.Close()

    if($page.Contains("MSA|AA")){
        Write-Host "Successfully received response from interface engine"
    }
    else {
        Write-Error "Failed to get correct response from interface engine"
    }
    Write-Verbose 'Test-SendingHL7: Done'

}

Export-ModuleMember -Function 'Test-SendingHL7'