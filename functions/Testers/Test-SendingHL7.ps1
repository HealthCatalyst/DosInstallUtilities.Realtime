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
    [string] $command = "${leadingCharacter}${message}${endingCharacter1}${endingCharacter2}"

    [int] $port = 6661

    $tcpConnection = New-Object System.Net.Sockets.TcpClient($InterfaceEngineHost, $port)
    $tcpStream = $tcpConnection.GetStream()
    $reader = New-Object System.IO.StreamReader($tcpStream)
    $writer = New-Object System.IO.StreamWriter($tcpStream)
    $writer.AutoFlush = $true

    $buffer = new-object System.Byte[] 1024
    $encoding = new-object System.Text.AsciiEncoding

    Write-Host "Waiting for connection to $InterfaceEngineHost"
    while (!$tcpConnection.Connected) {
        Write-Host "." -NoNewline
    }

    [bool] $messageSent = $false

    while ($tcpConnection.Connected) {
        while ($tcpStream.DataAvailable) {
            $rawresponse = $reader.Read($buffer, 0, 1024)
            $response = $encoding.GetString($buffer, 0, $rawresponse)
            Write-Host "Response"
            Write-Host $response
        }

        if ($tcpConnection.Connected) {
            if (!$messageSent) {
                $messageSent = $true
                Write-Host "Sending message"
                $writer.WriteLine($command) | Out-Null
                Write-Host "Waiting for response from $InterfaceEngineHost"
            }
        }

        Write-Host "." -NoNewline
        start-sleep -Milliseconds 500
    }

    $reader.Close()
    $writer.Close()

    $tcpConnection.Close()

    Write-Verbose 'Test-SendingHL7: Done'

}

Export-ModuleMember -Function 'Test-SendingHL7'