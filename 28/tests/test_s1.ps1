# Run from the repository root: powershell -ExecutionPolicy Bypass -File .\28\tests\test_s1.ps1
# Optional: powershell -ExecutionPolicy Bypass -File .\28\tests\test_s1.ps1 -RacketPath 'C:\Program Files\Racket\racket.exe'
[CmdletBinding()]
param(
    [string]$RacketPath = '',
    [int]$TimeoutSeconds = 15
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:Passed = 0

function Normalize-LineEndings {
    param([string]$Text)
    return ($Text -replace "\r\n", "`n")
}

function Invoke-RacketTest {
    param(
        [string]$AppendedCode
    )

    $tempName = [string]::Format("s1_test_{0}.test-tmp.rkt", [System.IO.Path]::GetRandomFileName())
    $tempFile = [System.IO.Path]::Combine($solutionDir, $tempName)
    try {
        [System.IO.File]::WriteAllText($tempFile, $solutionText + "`n" + $AppendedCode)
        $start = New-Object System.Diagnostics.ProcessStartInfo
        $start.FileName = $RacketPath
        $start.Arguments = '"{0}"' -f $tempFile
        $start.UseShellExecute = $false
        $start.CreateNoWindow = $true
        $start.RedirectStandardOutput = $true
        $start.RedirectStandardError = $true

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $start
        try {
            if (-not $process.Start()) { throw 'Could not start Racket process.' }
            $stdoutTask = $process.StandardOutput.ReadToEndAsync()
            $stderrTask = $process.StandardError.ReadToEndAsync()

            if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
                $process.Kill()
                $process.WaitForExit()
                throw "Racket execution exceeded ${TimeoutSeconds}s."
            }

            [pscustomobject]@{
                ExitCode = $process.ExitCode
                Stdout = $stdoutTask.GetAwaiter().GetResult()
                Stderr = $stderrTask.GetAwaiter().GetResult()
            }
        }
        finally {
            $process.Dispose()
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempFile) {
            Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
        }
    }
}

function Assert-Racket {
    param(
        [string]$Name,
        [string]$AppendedCode,
        [string]$ExpectedStdout,
        [int]$ExpectedExit = 0
    )

    $actual = Invoke-RacketTest -AppendedCode $AppendedCode
    $actualNorm = Normalize-LineEndings $actual.Stdout
    $expectedNorm = Normalize-LineEndings $ExpectedStdout

    if ($actual.ExitCode -ne $ExpectedExit -or $actualNorm -ne $expectedNorm -or $actual.Stderr -ne '') {
        throw ("{0}: expected exit {1} and stdout:`n{2}`ngot exit {3}`nstdout:`n{4}`nstderr:`n{5}" -f
            $Name, $ExpectedExit, $expectedNorm, $actual.ExitCode, $actualNorm, $actual.Stderr)
    }
    $script:Passed++
    Write-Output "PASS: $Name"
}

try {
    if ($TimeoutSeconds -lt 1 -or $TimeoutSeconds -gt 300) { throw 'TimeoutSeconds must be 1..300.' }

    $solutionPath = (Resolve-Path (Join-Path $PSScriptRoot '../code/28_q3.rkt')).Path
    $solutionDir = [System.IO.Path]::GetDirectoryName($solutionPath)
    $solutionText = [System.IO.File]::ReadAllText($solutionPath)

    if ($RacketPath -eq '') {
        $found = Get-Command racket -CommandType Application -ErrorAction SilentlyContinue
        if ($found) {
            $RacketPath = $found.Source
        }
        else {
            $commonPaths = @(
                (Join-Path $env:ProgramFiles 'Racket\racket.exe'),
                (Join-Path ${env:ProgramFiles(x86)} 'Racket\racket.exe'),
                (Join-Path $env:LOCALAPPDATA 'Programs\Racket\racket.exe')
            )
            foreach ($p in $commonPaths) {
                if ($p -and (Test-Path -LiteralPath $p)) {
                    $RacketPath = $p
                    break
                }
            }
            if ($RacketPath -eq '') {
                throw 'Racket was not found. Add racket to PATH or pass -RacketPath.'
            }
        }
    }

    # 1. Load-without-calls check: solution file must produce zero stdout and exit 0
    Assert-Racket 'load without calls produces no output' '' ''

    # Define standard trees used across tests
    $treeDefs = @"
(define t-empty '())
(define t-single '(42 () ()))
(define t-sym '(x () ()))
(define t1 '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))
(define t2 '(1 () (2 () (3 () ()))))
(define t3 '(a (b () ()) (c () ())))
(define t-left '(3 (2 (1 () ()) ()) ()))
(define t-right '(a () (b () (c () ()))))
(define t-mixed '(+ (x () ()) (42 () ())))
(define t-mixed-deep '(root (1 () (a () ())) (2 (b () ()) ())))
"@

    # 2. PDF Examples: Empty tree '()
    Assert-Racket 'empty tree: print-inorder' "$treeDefs`n(print-inorder t-empty)" "()`n"
    Assert-Racket 'empty tree: print-all-traversals' "$treeDefs`n(print-all-traversals t-empty)" "()`n()`n()`n"
    Assert-Racket 'empty tree: print-height-and-leaves' "$treeDefs`n(print-height-and-leaves t-empty)" "(0 0)`n"

    # 3. PDF Examples: t1
    Assert-Racket 't1: print-inorder' "$treeDefs`n(print-inorder t1)" "(1 2 3 4 5 6 7)`n"
    Assert-Racket 't1: print-all-traversals' "$treeDefs`n(print-all-traversals t1)" "(1 2 3 4 5 6 7)`n(4 2 1 3 6 5 7)`n(1 3 2 5 7 6 4)`n"
    Assert-Racket 't1: print-height-and-leaves' "$treeDefs`n(print-height-and-leaves t1)" "(3 4)`n"

    # 4. PDF Examples: t2
    Assert-Racket 't2: print-inorder' "$treeDefs`n(print-inorder t2)" "(1 2 3)`n"
    Assert-Racket 't2: print-all-traversals' "$treeDefs`n(print-all-traversals t2)" "(1 2 3)`n(1 2 3)`n(3 2 1)`n"
    Assert-Racket 't2: print-height-and-leaves' "$treeDefs`n(print-height-and-leaves t2)" "(3 1)`n"

    # 5. PDF Examples: t3 (symbol values)
    Assert-Racket 't3: print-inorder' "$treeDefs`n(print-inorder t3)" "(b a c)`n"
    Assert-Racket 't3: print-all-traversals' "$treeDefs`n(print-all-traversals t3)" "(b a c)`n(a b c)`n(b c a)`n"
    Assert-Racket 't3: print-height-and-leaves' "$treeDefs`n(print-height-and-leaves t3)" "(2 2)`n"

    # 6. Single node trees (numeric and symbol)
    Assert-Racket 'single numeric node: print-inorder' "$treeDefs`n(print-inorder t-single)" "(42)`n"
    Assert-Racket 'single numeric node: print-all-traversals' "$treeDefs`n(print-all-traversals t-single)" "(42)`n(42)`n(42)`n"
    Assert-Racket 'single numeric node: print-height-and-leaves' "$treeDefs`n(print-height-and-leaves t-single)" "(1 1)`n"
    Assert-Racket 'single symbol node: print-inorder' "$treeDefs`n(print-inorder t-sym)" "(x)`n"
    Assert-Racket 'single symbol node: print-all-traversals' "$treeDefs`n(print-all-traversals t-sym)" "(x)`n(x)`n(x)`n"
    Assert-Racket 'single symbol node: print-height-and-leaves' "$treeDefs`n(print-height-and-leaves t-sym)" "(1 1)`n"

    # 7. Left-only tree (left-skewed)
    Assert-Racket 'left-only tree: print-inorder' "$treeDefs`n(print-inorder t-left)" "(1 2 3)`n"
    Assert-Racket 'left-only tree: print-all-traversals' "$treeDefs`n(print-all-traversals t-left)" "(1 2 3)`n(3 2 1)`n(1 2 3)`n"
    Assert-Racket 'left-only tree: print-height-and-leaves' "$treeDefs`n(print-height-and-leaves t-left)" "(3 1)`n"

    # 8. Right-only tree (right-skewed)
    Assert-Racket 'right-only tree: print-inorder' "$treeDefs`n(print-inorder t-right)" "(a b c)`n"
    Assert-Racket 'right-only tree: print-all-traversals' "$treeDefs`n(print-all-traversals t-right)" "(a b c)`n(a b c)`n(c b a)`n"
    Assert-Racket 'right-only tree: print-height-and-leaves' "$treeDefs`n(print-height-and-leaves t-right)" "(3 1)`n"

    # 9. Mixed numeric and symbol values
    Assert-Racket 'mixed numeric/symbol: print-inorder' "$treeDefs`n(print-inorder t-mixed)" "(x + 42)`n"
    Assert-Racket 'mixed numeric/symbol: print-all-traversals' "$treeDefs`n(print-all-traversals t-mixed)" "(x + 42)`n(+ x 42)`n(x 42 +)`n"
    Assert-Racket 'mixed numeric/symbol: print-height-and-leaves' "$treeDefs`n(print-height-and-leaves t-mixed)" "(2 2)`n"

    # 10. Deeper mixed tree
    Assert-Racket 'mixed deep tree: print-inorder' "$treeDefs`n(print-inorder t-mixed-deep)" "(1 a root b 2)`n"
    Assert-Racket 'mixed deep tree: print-all-traversals' "$treeDefs`n(print-all-traversals t-mixed-deep)" "(1 a root b 2)`n(root 1 a 2 b)`n(a 1 b 2 root)`n"
    Assert-Racket 'mixed deep tree: print-height-and-leaves' "$treeDefs`n(print-height-and-leaves t-mixed-deep)" "(3 2)`n"

    # 11. Helper functions with custom tail
    Assert-Racket 'inorder-values with tail' "$treeDefs`n(display (inorder-values t1 '(tail-item)))(newline)" "(1 2 3 4 5 6 7 tail-item)`n"
    Assert-Racket 'preorder-values with tail' "$treeDefs`n(display (preorder-values t1 '(tail-item)))(newline)" "(4 2 1 3 6 5 7 tail-item)`n"
    Assert-Racket 'postorder-values with tail' "$treeDefs`n(display (postorder-values t1 '(tail-item)))(newline)" "(1 3 2 5 7 6 4 tail-item)`n"
    Assert-Racket 'tree-stats direct call' "$treeDefs`n(display (tree-stats t1))(newline)" "(3 4)`n"

    Write-Output "All $script:Passed S1 checks passed."
    exit 0
}
catch {
    [Console]::Error.WriteLine("FAIL after $script:Passed passed checks: $($_.Exception.Message)")
    exit 1
}
