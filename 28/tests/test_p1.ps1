param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:LF = ([char]10).ToString()

try {
    $repoRoot = (Get-Location).Path
    $script:SolutionPath = Join-Path $repoRoot '28\code\28_q1.pl'
    if (-not (Test-Path -LiteralPath $script:SolutionPath)) {
        throw "Missing solution file: $script:SolutionPath"
    }

    if ($env:SWIPL_EXE) {
        $script:SwiplPath = $env:SWIPL_EXE
    }
    else {
        $swiplCommand = Get-Command swipl.exe -ErrorAction SilentlyContinue
        if ($swiplCommand) {
            $script:SwiplPath = $swiplCommand.Source
        }
        elseif (Test-Path -LiteralPath 'C:\Program Files\swipl\bin\swipl.exe') {
            $script:SwiplPath = 'C:\Program Files\swipl\bin\swipl.exe'
        }
        else {
            throw 'SWI-Prolog executable not found. Put swipl.exe on PATH or set SWIPL_EXE.'
        }
    }

    if (-not (Test-Path -LiteralPath $script:SwiplPath)) {
        throw "SWI-Prolog executable not found: $script:SwiplPath"
    }

    function Invoke-SwiplExact {
        param(
            [Parameter(Mandatory = $true)][string]$Name,
            [Parameter(Mandatory = $true)][string]$Goal,
            [Parameter(Mandatory = $true)][string]$ExpectedStdout
        )

        $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = $script:SwiplPath
        $startInfo.Arguments = '-q -f "' + $script:SolutionPath + '" -g "' + $Goal + '" -t halt'
        $startInfo.UseShellExecute = $false
        $startInfo.CreateNoWindow = $true
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true

        $process = [System.Diagnostics.Process]::new()
        $process.StartInfo = $startInfo
        if (-not $process.Start()) {
            throw "Could not start SWI-Prolog for test '$Name'."
        }

        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        if (-not $process.WaitForExit(60000)) {
            $process.Kill()
            throw "SWI-Prolog timed out during test '$Name'."
        }

        if ($process.ExitCode -ne 0) {
            throw "Test '$Name' exited with code $($process.ExitCode). stderr: $stderr"
        }
        if (-not [string]::IsNullOrEmpty($stderr)) {
            throw "Test '$Name' wrote to stderr: $stderr"
        }

        $crlf = ([char]13).ToString() + ([char]10).ToString()
        $lf = ([char]10).ToString()
        $actualNormalized = $stdout.Replace($crlf, $lf)
        $expectedNormalized = $ExpectedStdout.Replace($crlf, $lf)
        if ($actualNormalized -cne $expectedNormalized) {
            throw ("Test '{0}' output mismatch.{1}Expected: [{2}]{1}Actual:   [{3}]" -f $Name, [Environment]::NewLine, $expectedNormalized, $actualNormalized)
        }

        Write-Host "PASS $Name"
    }

    # Independent oracle: enumerate the 24 permutations for each attribute in PowerShell,
    # then evaluate the PDF clues directly against those values. It does not call solution predicates.
    function Get-4Permutations {
        param([Parameter(Mandatory = $true)][string[]]$Values)

        if ($Values.Count -ne 4) {
            throw 'The independent oracle expects four values per attribute.'
        }

        $permutations = [System.Collections.Generic.List[object]]::new()
        for ($a = 0; $a -lt 4; $a++) {
            for ($b = 0; $b -lt 4; $b++) {
                for ($c = 0; $c -lt 4; $c++) {
                    for ($d = 0; $d -lt 4; $d++) {
                        if (($a -ne $b) -and ($a -ne $c) -and ($a -ne $d) -and
                            ($b -ne $c) -and ($b -ne $d) -and ($c -ne $d)) {
                            $permutations.Add([string[]]@($Values[$a], $Values[$b], $Values[$c], $Values[$d]))
                        }
                    }
                }
            }
        }
        return ,($permutations.ToArray())
    }

    $names = @('Alex', 'Ben', 'Carla', 'Dana')
    $departmentPermutations = Get-4Permutations -Values @('research', 'development', 'design', 'testing')
    $languagePermutations = Get-4Permutations -Values @('python', 'java', 'c++', 'javascript')
    $projectPermutations = Get-4Permutations -Values @('AI', 'web', 'embedded', 'data')
    $oracleTotal = 0
    $oracleSubset24 = 0
    $oracleOriginal = 0
    $oracleRepaired = 0

    foreach ($departments in $departmentPermutations) {
        foreach ($languages in $languagePermutations) {
            foreach ($projects in $projectPermutations) {
                $oracleTotal++

                $aiIndex = [Array]::IndexOf($projects, 'AI')
                $dataIndex = [Array]::IndexOf($projects, 'data')
                $javaIndex = [Array]::IndexOf($languages, 'java')
                $designIndex = [Array]::IndexOf($departments, 'design')
                $testingIndex = [Array]::IndexOf($departments, 'testing')

                $clue1 = ($departments[$aiIndex] -ne 'research') -and ($names[$aiIndex] -ne 'Dana')
                $clue2 = ($departments[0] -ne 'development') -and ($languages[0] -ne 'c++')
                $clue3 = ($languages[$testingIndex] -eq 'python')
                $clue4 = ($projects[1] -eq 'web') -and ($departments[1] -ne 'testing')
                $clue5 = ($departments[$javaIndex] -eq 'design')
                $clue6 = ($departments[2] -ne 'development') -and ($projects[2] -ne 'embedded')
                $clue7 = ($languages[3] -ne 'java') -and (($departments[3] -eq 'research') -or ($departments[3] -eq 'testing'))
                $clue8 = ($departments[$dataIndex] -eq 'research') -and ($languages[$dataIndex] -ne 'javascript')
                $clue9 = ($projects[$designIndex] -eq 'embedded')

                if ($clue2 -and $clue4) {
                    $oracleSubset24++
                }
                if ($clue1 -and $clue2 -and $clue3 -and $clue4 -and $clue5 -and $clue6 -and $clue7 -and $clue8) {
                    $oracleOriginal++
                    if ($clue9) {
                        $oracleRepaired++
                    }
                }
            }
        }
    }

    # Empty Active has 4! * 4! * 4! candidates. For clues [2,4], the
    # independent combinatorial count is 14 department * 18 language * 6 project assignments.
    if (($departmentPermutations.Count -ne 24) -or
        ($languagePermutations.Count -ne 24) -or
        ($projectPermutations.Count -ne 24) -or
        ($oracleTotal -ne 13824) -or
        ($oracleSubset24 -ne (14 * 18 * 6)) -or
        ($oracleOriginal -ne 3) -or
        ($oracleRepaired -ne 1)) {
        throw "Independent oracle mismatch: total=$oracleTotal subset24=$oracleSubset24 original=$oracleOriginal repaired=$oracleRepaired"
    }

    $candidateGoal = @'
findall(S,candidate_solution(S),All),sort(All,Unique),length(All,N),length(Unique,U),N=13824,U=N,sort([research,development,design,testing],ED),sort([python,java,'c++',javascript],EL),sort(['AI',web,embedded,data],EP),forall(member(S,All),(S=[p('Alex',D1,L1,P1),p('Ben',D2,L2,P2),p('Carla',D3,L3,P3),p('Dana',D4,L4,P4)],sort([D1,D2,D3,D4],ED),sort([L1,L2,L3,L4],EL),sort([P1,P2,P3,P4],EP))),writeln(candidate_permutations_unique_ok)
'@ -replace '[\r\n]+', ' '
    Invoke-SwiplExact -Name 'candidate uniqueness and attribute permutations' -Goal $candidateGoal -ExpectedStdout ('candidate_permutations_unique_ok' + $script:LF)

    $clueExamplesGoal = @'
(clue(1,[p('Alex',design,java,'AI'),p('Ben',testing,python,web),p('Carla',research,'c++',embedded),p('Dana',development,javascript,data)]) -> true ; throw(clue_1_should_succeed)),(\+ clue(1,[p('Alex',research,python,data),p('Ben',development,java,web),p('Carla',design,'c++',embedded),p('Dana',testing,javascript,'AI')]) -> true ; throw(clue_1_should_fail)),(clue(2,[p('Alex',design,java,web),p('Ben',research,python,'AI'),p('Carla',testing,'c++',embedded),p('Dana',development,javascript,data)]) -> true ; throw(clue_2_should_succeed)),(\+ clue(2,[p('Alex',development,java,web),p('Ben',research,python,'AI'),p('Carla',testing,'c++',embedded),p('Dana',design,javascript,data)]) -> true ; throw(clue_2_should_fail)),(clue(3,[p('Alex',testing,python,'AI'),p('Ben',research,java,web),p('Carla',design,'c++',embedded),p('Dana',development,javascript,data)]) -> true ; throw(clue_3_should_succeed)),(\+ clue(3,[p('Alex',testing,java,'AI'),p('Ben',research,python,web),p('Carla',design,'c++',embedded),p('Dana',development,javascript,data)]) -> true ; throw(clue_3_should_fail)),(clue(4,[p('Alex',research,python,'AI'),p('Ben',development,java,web),p('Carla',design,'c++',embedded),p('Dana',testing,javascript,data)]) -> true ; throw(clue_4_should_succeed)),(\+ clue(4,[p('Alex',research,python,'AI'),p('Ben',testing,java,web),p('Carla',design,'c++',embedded),p('Dana',development,javascript,data)]) -> true ; throw(clue_4_should_fail)),(clue(5,[p('Alex',design,java,'AI'),p('Ben',testing,python,web),p('Carla',research,'c++',embedded),p('Dana',development,javascript,data)]) -> true ; throw(clue_5_should_succeed)),(\+ clue(5,[p('Alex',design,python,'AI'),p('Ben',testing,java,web),p('Carla',research,'c++',embedded),p('Dana',development,javascript,data)]) -> true ; throw(clue_5_should_fail)),(clue(6,[p('Alex',research,python,'AI'),p('Ben',development,java,web),p('Carla',design,'c++',data),p('Dana',testing,javascript,embedded)]) -> true ; throw(clue_6_should_succeed)),(\+ clue(6,[p('Alex',research,python,'AI'),p('Ben',development,java,web),p('Carla',design,'c++',embedded),p('Dana',testing,javascript,data)]) -> true ; throw(clue_6_should_fail)),(clue(7,[p('Alex',development,python,'AI'),p('Ben',design,java,web),p('Carla',testing,'c++',embedded),p('Dana',research,javascript,data)]) -> true ; throw(clue_7_research_branch_should_succeed)),(clue(7,[p('Alex',research,python,'AI'),p('Ben',development,java,web),p('Carla',design,'c++',embedded),p('Dana',testing,javascript,data)]) -> true ; throw(clue_7_testing_branch_should_succeed)),(\+ clue(7,[p('Alex',research,python,'AI'),p('Ben',development,java,web),p('Carla',testing,'c++',embedded),p('Dana',design,javascript,data)]) -> true ; throw(clue_7_should_fail)),(clue(8,[p('Alex',design,python,'AI'),p('Ben',development,java,web),p('Carla',research,'c++',data),p('Dana',testing,javascript,embedded)]) -> true ; throw(clue_8_should_succeed)),(\+ clue(8,[p('Alex',research,python,'AI'),p('Ben',development,java,web),p('Carla',design,'c++',data),p('Dana',testing,javascript,embedded)]) -> true ; throw(clue_8_should_fail)),(clue(9,[p('Alex',design,java,embedded),p('Ben',development,javascript,web),p('Carla',testing,python,'AI'),p('Dana',research,'c++',data)]) -> true ; throw(clue_9_should_succeed)),(\+ clue(9,[p('Alex',design,java,'AI'),p('Ben',development,javascript,web),p('Carla',research,'c++',data),p('Dana',testing,python,embedded)]) -> true ; throw(clue_9_should_fail)),writeln(clue_examples_ok)
'@ -replace '[\r\n]+', ' '
    Invoke-SwiplExact -Name 'success and failure cases for every clue' -Goal $clueExamplesGoal -ExpectedStdout ('clue_examples_ok' + $script:LF)

    $activeGoal = @'
(satisfies_clues([],[]) -> true ; throw(empty_active_failed)),(satisfies_clues([2,4],[p('Alex',research,python,'AI'),p('Ben',development,java,web),p('Carla',design,'c++',embedded),p('Dana',testing,javascript,data)]) -> true ; throw(subset_active_failed)),once((solve([2,4],S),\+ clue(1,S))),writeln(empty_subset_active_ok)
'@ -replace '[\r\n]+', ' '
    Invoke-SwiplExact -Name 'empty and subset Active behavior' -Goal $activeGoal -ExpectedStdout ('empty_subset_active_ok' + $script:LF)

    Invoke-SwiplExact -Name 'empty Active count' -Goal "count_solutions([],N),format('empty_count=~d~n',[N])" -ExpectedStdout ("empty_count=$oracleTotal" + $script:LF)
    Invoke-SwiplExact -Name 'subset Active count' -Goal "count_solutions([2,4],N),format('subset_count=~d~n',[N])" -ExpectedStdout ("subset_count=$oracleSubset24" + $script:LF)
    Invoke-SwiplExact -Name 'original clues 1 through 8 count' -Goal "count_solutions([1,2,3,4,5,6,7,8],N),format('original_count=~d~n',[N])" -ExpectedStdout ("original_count=$oracleOriginal" + $script:LF)
    Invoke-SwiplExact -Name 'repaired clues 1 through 9 count' -Goal "count_solutions([1,2,3,4,5,6,7,8,9],N),format('repaired_count=~d~n',[N])" -ExpectedStdout ("repaired_count=$oracleRepaired" + $script:LF)

    $expectedMain = @(
        'Alex = [design, java, AI]',
        'Ben = [development, javascript, web]',
        'Carla = [research, c++, data]',
        'Dana = [testing, python, embedded]',
        ''
    ) -join $script:LF
    Invoke-SwiplExact -Name 'exact four-line main output' -Goal 'main' -ExpectedStdout $expectedMain

    Write-Host "Independent oracle: total=$oracleTotal subset[2,4]=$oracleSubset24 original=$oracleOriginal repaired=$oracleRepaired"
    Write-Host 'All P1 checks passed.'
    exit 0
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
