$filename = $($(Split-Path -Leaf MyInvocation.MyCommand.Path).Replace('.Tests.ps1',''))

Describe "$filename Unit Tests" -Tags 'Unit' {
    It "TestMethod" {
    }
}

Describe "$filename Integration Tests" -Tags 'Integration' {
    It "Can Connect to RabbitMq" {
        Test-RabbitMq -RabbitMqHost "104.42.156.207"
    }
}