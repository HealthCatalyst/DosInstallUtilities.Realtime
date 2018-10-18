$filename = $($(Split-Path -Leaf MyInvocation.MyCommand.Path).Replace('.Tests.ps1',''))

Describe "$filename Unit Tests" -Tags 'Unit' {
    It "TestMethod" {
    }
}

Describe "$filename Integration Tests" -Tags 'Integration' {
    It "Can Download Certificate" {
        $result = $(Test-DownloadCertificate -CertificateHost "104.42.156.207")

        $result | Should Not BeNullOrEmpty
        $result.CertData | Should Not BeNullOrEmpty
    }
}