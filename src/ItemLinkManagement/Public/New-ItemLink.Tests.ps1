$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "New-ItemLink" -Tag 'Unit' {

    $testDrive = Convert-Path 'TestDrive:\'

    # Note: All our test files will be hidden files, for the sake of Windows

    # Source of truth
    $testFileFullName = Join-Path $testDrive '.testfile'
    $testDirectoryFullName = Join-Path $testDrive '.testdirectory'

    # Link
    $testFileLinkFullName = Join-Path $testDrive '.testfilelink'
    $testDirectoryLinkFullName = Join-Path $testDrive '.testdirectorylink'

    AfterEach {
        # Powershell 5 requires a special way to remove a SymbolicLink, see: https://stackoverflow.com/a/63172492
        if ($PSVersionTable.PSVersion.Major -le 5) {
            Get-ChildItem "$testDrive/*" -Attributes ReparsePoint | % { $_.Delete() }
        }
        Get-Item "$testDrive/*" -Force | Remove-Item -Recurse -Force
    }

    Context 'Exceptions' {

        It "Should throw when ItemType is invalid" {
            $testFile = New-Item $testFileFullName -ItemType File -Force
            $testFile.Attributes += 'Hidden'
            $params = @{
                ItemType = 'foo'
                Path = $testFileLinkFullName
                Value = $testFile.FullName
                ErrorAction = 'Stop'
            }

            { New-ItemLink @params } | Should -Throw 'does not belong to the set'
        }
    }

    Context 'Error stream' {

        It "Should output to error stream" {
            $testFile = New-Item $testFileFullName -ItemType File -Force
            $testFile.Attributes += 'Hidden'
            $params = @{
                ItemType = 'SymbolicLink'
                Path = $testFile.FullName # Deliberately simulate an error by trying to create a link in place of its file
                Value = $testFile.FullName
                ErrorVariable = 'err'
                ErrorAction = 'Continue'
            }

            $err = New-ItemLink @params 2>&1

            $err | ? { $_ -is [System.Management.Automation.ErrorRecord] } | Should -Not -Be $null
        }

        It "Should not output to error stream" {
            $testFile = New-Item $testFileFullName -ItemType File -Force
            $testFile.Attributes += 'Hidden'
            $params = @{
                ItemType = 'SymbolicLink'
                Path = $testFile.FullName # Deliberately simulate an error by trying to create a link in place of its file
                Value = $testFile.FullName
                ErrorAction = 'SilentlyContinue'
            }

            $err = New-ItemLink @params 2>&1

            $err | ? { $_ -is [System.Management.Automation.ErrorRecord] } | Should -Be $null
        }

    }

    Context 'Behavior' {

        It "Should create HardLink for file" {
            $testFile = New-Item $testFileFullName -ItemType File -Force
            $testFile.Attributes += 'Hidden'
            $params = @{
                ItemType = 'HardLink'
                Path = $testFileLinkFullName
                Value = $testFile.FullName
                ErrorAction = 'Stop'
            }

            $result = New-ItemLink @params

            $result | Should -BeOfType [System.IO.FileInfo]
            $result.LinkType | Should -Be $params['ItemType']
        }

        It 'Should create a HardLink for file even if it already exists when using -Force' {
            $testFile = New-Item $testFileFullName -ItemType File -Force
            $testFile.Attributes += 'Hidden'
            $testFileLink = New-Item $testFileLinkFullName -Value $testFile.FullName -ItemType 'HardLink' -Force
            $testFileLink.Attributes += 'Hidden'
            $params = @{
                ItemType = 'HardLink'
                Path = $testFileLink.FullName
                Value = $testFile.FullName
                Force = $true
                ErrorAction = 'Stop'
            }

            $result = New-ItemLink @params

            $result | Should -BeOfType [System.IO.FileInfo]
            $result.LinkType | Should -Be $params['ItemType']
        }

        It "Should create SymbolicLink for file" {
            $testFile = New-Item $testFileFullName -ItemType File -Force
            $testFile.Attributes += 'Hidden'
            $params = @{
                ItemType = 'SymbolicLink'
                Path = $testFileLinkFullName
                Value = $testFile.FullName
                ErrorAction = 'Stop'
            }

            $result = New-ItemLink @params

            $result | Should -BeOfType [System.IO.FileInfo]
            $result.LinkType | Should -Be $params['ItemType']
        }

        It "Should create Junction for directory (Windows)" {
            if ($env:OS -eq 'Windows_NT') {
                $testDirectory = New-Item $testDirectoryFullName -ItemType Directory -Force
                $testDirectory.Attributes += 'Hidden'
                $params = @{
                    ItemType = 'Junction'
                    Path = $testDirectoryLinkFullName
                    Value = $testDirectory.FullName
                    ErrorAction = 'Stop'
                }

                $result = New-ItemLink @params

                $result | Should -BeOfType [System.IO.DirectoryInfo]
                $result.LinkType | Should -Be $params['ItemType']
            }else {
                $true
            }
        }

        It 'Should create a Junction for directory even if it already exists when using -Force (Windows)' {
            if ($env:OS -eq 'Windows_NT') {
                $testDirectory = New-Item $testDirectoryFullName -ItemType Directory -Force
                $testDirectory.Attributes += 'Hidden'
                $testDirectoryLink = New-Item $testDirectoryLinkFullName -Value $testDirectory.FullName -ItemType 'Junction' -Force
                $testDirectoryLink.Attributes += 'Hidden'
                $params = @{
                    ItemType = 'Junction'
                    Path = $testDirectoryLink.FullName
                    Value = $testDirectory.FullName
                    Force = $true
                    ErrorAction = 'Stop'
                }

                $result = New-ItemLink @params

                $result | Should -BeOfType [System.IO.DirectoryInfo]
                $result.LinkType | Should -Be $params['ItemType']
            }else {
                $true
            }
        }

        It "Should create SymbolicLink for directory" {
            $testDirectory = New-Item $testDirectoryFullName -ItemType Directory -Force
            $testDirectory.Attributes += 'Hidden'
            $params = @{
                ItemType = 'SymbolicLink'
                Path = $testDirectoryLinkFullName
                Value = $testDirectory.FullName
                ErrorAction = 'Stop'
            }

            $result = New-ItemLink @params

            $result | Should -BeOfType [System.IO.DirectoryInfo]
            $result.LinkType | Should -Be $params['ItemType']
        }

        It 'Should create a SymbolicLink for directory even if it already exists when using -Force' {
            $testDirectory = New-Item $testDirectoryFullName -ItemType Directory -Force
            $testDirectory.Attributes += 'Hidden'
            $testDirectoryLink = New-Item $testDirectoryLinkFullName -Value $testDirectory.FullName -ItemType 'SymbolicLink' -Force
            $testDirectoryLink.Attributes += 'Hidden'
            $params = @{
                ItemType = 'SymbolicLink'
                Path = $testDirectoryLink.FullName
                Value = $testDirectory.FullName
                Force = $true
                ErrorAction = 'Stop'
            }

            $result = New-ItemLink @params

            $result | Should -BeOfType [System.IO.DirectoryInfo]
            $result.LinkType | Should -Be $params['ItemType']
        }

    }
}
