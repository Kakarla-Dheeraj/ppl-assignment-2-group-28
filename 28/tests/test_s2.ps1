# S2 tests for 28/code/28_q4.rkt.
# Run from the repository root:  powershell -ExecutionPolicy Bypass -File .\28\tests\test_s2.ps1
# Optional: -RacketPath 'C:\Program Files\Racket\racket.exe'  -TimeoutSeconds 60
#
# Each case copies the solution to a temporary *.test-tmp.rkt file next to it
# (ignored by .gitignore), appends grader-style calls that use only the
# assignment's allowed built-ins, runs racket as a separate process with the
# given stdin, and compares stdout exactly (only CRLF -> LF is normalised).
# A case passes only if the exit code is 0, stderr is empty and stdout matches.
# The solution file itself is never written; its hash is checked at the end.
[CmdletBinding()]
param([string]$RacketPath = '', [int]$TimeoutSeconds = 60)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:Passed = 0
$script:Failed = 0
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Normalize-Newlines([string]$Text) { return $Text.Replace("`r`n", "`n") }

function Invoke-Racket {
    param([string]$File, [string]$Stdin = '')

    $start = New-Object System.Diagnostics.ProcessStartInfo
    $start.FileName = $RacketPath
    $start.Arguments = '"{0}"' -f $File
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.RedirectStandardInput = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $start
    try {
        if (-not $process.Start()) { throw 'Could not start Racket.' }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        $process.StandardInput.Write($Stdin)
        $process.StandardInput.Close()   # EOF, so a stray extra read cannot hang
        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
            $process.Kill()
            $process.WaitForExit()
            throw "Racket exceeded ${TimeoutSeconds}s."
        }
        [pscustomobject]@{
            ExitCode = $process.ExitCode
            Stdout   = Normalize-Newlines $stdoutTask.GetAwaiter().GetResult()
            Stderr   = Normalize-Newlines $stderrTask.GetAwaiter().GetResult()
        }
    }
    finally { $process.Dispose() }
}

function Format-Short([string]$Text) {
    if ($Text.Length -le 300) { return $Text }
    return $Text.Substring(0, 300) + ('... [{0} chars total]' -f $Text.Length)
}

function Report-Result {
    param([string]$Name, $Actual, [string]$Expected)

    if ($Actual.ExitCode -eq 0 -and $Actual.Stderr -eq '' -and $Actual.Stdout -ceq $Expected) {
        $script:Passed++
        Write-Output "PASS: $Name"
        return
    }
    $script:Failed++
    Write-Output "FAIL: $Name"
    Write-Output ('  exit:     {0}' -f $Actual.ExitCode)
    Write-Output ('  expected: {0}' -f (Format-Short $Expected))
    Write-Output ('  stdout:   {0}' -f (Format-Short $Actual.Stdout))
    if ($Actual.Stderr -ne '') { Write-Output ('  stderr:   {0}' -f (Format-Short $Actual.Stderr)) }
}

# Appends $Calls to a temporary copy of the solution, runs it with $Stdin and
# compares stdout with $Expected exactly.
function Assert-Output {
    param([string]$Name, [string]$Calls, [string]$Expected, [string]$Stdin = '')

    $temp = Join-Path $codeDir ('28_q4.{0}.test-tmp.rkt' -f [guid]::NewGuid().ToString('N'))
    try {
        [System.IO.File]::WriteAllText($temp, $solutionText + "`n" + $Calls + "`n", $Utf8NoBom)
        $actual = Invoke-Racket -File $temp -Stdin $Stdin
        Report-Result -Name $Name -Actual $actual -Expected $Expected
    }
    catch {
        $script:Failed++
        Write-Output "FAIL: $Name"
        Write-Output "  harness error: $($_.Exception.Message)"
    }
    finally {
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
    }
}

# A call whose value is shown with display and one newline.
function Show([string]$Expr) { return "(display $Expr) (newline)" }

# Runs (print-insert-result) on the given stdin; expects the line plus "\n".
function Assert-Stdin {
    param([string]$Name, [string]$Stdin, [string]$ExpectedLine)
    Assert-Output -Name $Name -Calls '(print-insert-result)' -Stdin $Stdin -Expected ($ExpectedLine + "`n")
}

# Generators for the large cases (PowerShell builds input and expected text).
function New-Seq([int]$From, [int]$To) { return (($From..$To) | ForEach-Object { $_.ToString() }) -join ' ' }
function New-Repeat([string]$Item, [int]$Count) { return ((1..$Count) | ForEach-Object { $Item }) -join ' ' }
function New-Nest([int]$Depth, [string]$Inner, [string]$Prefix = '') {
    return ('(' + $Prefix) * $Depth + $Inner + ')' * $Depth
}

$exitCode = 0
try {
    if ($TimeoutSeconds -lt 1 -or $TimeoutSeconds -gt 600) { throw 'TimeoutSeconds must be 1..600.' }
    $solution = (Resolve-Path (Join-Path $PSScriptRoot '../code/28_q4.rkt')).Path
    $codeDir = Split-Path -Parent $solution
    if ($RacketPath -eq '') {
        $found = Get-Command racket -CommandType Application -ErrorAction SilentlyContinue
        if ($found) { $RacketPath = @($found)[0].Source }
        else {
            $usualPath = Join-Path $env:ProgramFiles 'Racket/racket.exe'
            if (Test-Path -LiteralPath $usualPath) { $RacketPath = $usualPath }
            else { throw 'Racket was not found. Add racket to PATH or pass -RacketPath.' }
        }
    }
    $solutionText = [System.IO.File]::ReadAllText($solution)
    $hashBefore = (Get-FileHash -LiteralPath $solution -Algorithm SHA256).Hash

    # --- Static shape of the solution file -------------------------------
    $firstLine = (Normalize-Newlines $solutionText).Split("`n")[0].Trim()
    $defCount = ([regex]::Matches($solutionText, '\(define\s+\(insert-if-short\s')).Count
    if ($firstLine -ceq '#lang racket/base' -and $defCount -eq 1) {
        $script:Passed++; Write-Output 'PASS: #lang racket/base header and exactly one insert-if-short definition'
    }
    else {
        $script:Failed++; Write-Output "FAIL: header/definitions (first line '$firstLine', insert-if-short definitions: $defCount)"
    }

    # --- Loading the original file with no calls -------------------------
    try {
        $load = Invoke-Racket -File $solution
        Report-Result -Name 'loading the original file prints nothing' -Actual $load -Expected ''
    }
    catch { $script:Failed++; Write-Output "FAIL: loading the original file`n  harness error: $($_.Exception.Message)" }

    # --- PDF examples, direct calls ---------------------------------------
    Assert-Output 'PDF 1: 42 ((1 2) (3 4 5) (6) ()) 3' (Show "(insert-if-short 42 '((1 2) (3 4 5) (6) ()) 3)") "((42 1 2) (3 4 5) (42 6) (42))`n"
    Assert-Output 'PDF 2: 0 (((1) 2) (3) ((4 5 6) ())) 3' (Show "(insert-if-short 0 '(((1) 2) (3) ((4 5 6) ())) 3)") "((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))`n"
    Assert-Output 'PDF 3: 7 () 3' (Show "(insert-if-short 7 '() 3)") "(7)`n"
    Assert-Output 'PDF 4: 7 () 0' (Show "(insert-if-short 7 '() 0)") "()`n"

    # --- Empty top-level and nested lists ---------------------------------
    Assert-Output 'empty top-level, n=1' (Show "(insert-if-short 'z '() 1)") "(z)`n"
    Assert-Output 'single empty sublist, n=1 (top length 1 measured before insertion)' (Show "(insert-if-short 'z '(()) 1)") "((z))`n"
    Assert-Output 'single empty sublist, n=2' (Show "(insert-if-short 'z '(()) 2)") "(z (z))`n"
    Assert-Output 'nested empty lists at several depths, n=1' (Show "(insert-if-short 'z '(() (()) ((()))) 1)") "((z) ((z)) (((z))))`n"

    # --- n = 0 and n equal to the original length -------------------------
    Assert-Output 'n=0 leaves a nested list unchanged' (Show "(insert-if-short 'z '(a (b) () ((c))) 0)") "(a (b) () ((c)))`n"
    Assert-Output 'n=0 leaves the empty list unchanged' (Show "(insert-if-short 'z '() 0)") "()`n"
    Assert-Output 'n equal to top-level length: no insertion' (Show "(insert-if-short 'z '(a b c) 3)") "(a b c)`n"
    Assert-Output 'n equal to a sublist length: only shorter lists change' (Show "(insert-if-short 'z '((a b) (c)) 2)") "((a b) (z c))`n"

    # --- Top-level insertion and symbols ----------------------------------
    Assert-Output 'top-level insertion' (Show "(insert-if-short 'z '(a b) 3)") "(z a b)`n"
    Assert-Output 'top-level insertion, long sublist untouched' (Show "(insert-if-short 'top '((a b c) d) 3)") "(top (a b c) d)`n"
    Assert-Output 'symbol x into symbol list' (Show "(insert-if-short 'sym '(alpha (beta gamma) delta) 3)") "(alpha (sym beta gamma) delta)`n"
    Assert-Output 'number x into symbol list' (Show "(insert-if-short 9 '(a (b)) 2)") "(a (9 b))`n"
    Assert-Output 'every level gets x once' (Show "(insert-if-short 'z '((a)) 2)") "(z (z a))`n"

    # --- my-length --------------------------------------------------------
    Assert-Output 'my-length ()' (Show "(my-length '())") "0`n"
    Assert-Output 'my-length (a)' (Show "(my-length '(a))") "1`n"
    Assert-Output 'my-length counts sublists once' (Show "(my-length '((1 2) (3 4 5) (6) ()))") "4`n"
    Assert-Output 'my-length counts empty sublists' (Show "(my-length '(() () ()))") "3`n"

    # --- my-map -----------------------------------------------------------
    Assert-Output 'my-map on ()' (Show "(my-map (lambda (e) (+ e 1)) '())") "()`n"
    Assert-Output 'my-map preserves order' (Show "(my-map (lambda (e) (* e 10)) '(1 2 3))") "(10 20 30)`n"
    Assert-Output 'my-map passes sublists whole' (Show "(my-map my-length '((1 2) (3 4 5) (6) ()))") "(2 3 1 0)`n"
    Assert-Output 'my-map treats () as one element' (Show "(my-map (lambda (e) (pair? e)) '(a () (b)))") "(#f #f #t)`n"
    Assert-Output 'my-map calls f once per element, left to right' (Show "(my-map (lambda (e) (begin (display e) e)) '(a b c))") "abc(a b c)`n"

    # --- make-inserter with other predicates ------------------------------
    $t = "'(a (b c) () ((d e) f) (g h i))"
    Assert-Output 'make-inserter: length zero' (Show "((make-inserter 'z (lambda (k) (= k 0))) $t)") "(a (b c) (z) ((d e) f) (g h i))`n"
    Assert-Output 'make-inserter: exactly two' (Show "((make-inserter 'z (lambda (k) (= k 2))) $t)") "(a (z b c) () (z (z d e) f) (g h i))`n"
    Assert-Output 'make-inserter: every length' (Show "((make-inserter 'z (lambda (k) #t)) $t)") "(z a (z b c) (z) (z (z d e) f) (z g h i))`n"
    Assert-Output 'make-inserter: no length' (Show "((make-inserter 'z (lambda (k) #f)) $t)") "(a (b c) () ((d e) f) (g h i))`n"
    Assert-Output 'make-inserter: at least three' (Show "((make-inserter 'z (lambda (k) (>= k 3))) $t)") "(z a (b c) () ((d e) f) (z g h i))`n"
    Assert-Output 'make-inserter: original top length 5 only' (Show "((make-inserter 'z (lambda (k) (= k 5))) $t)") "(z a (b c) () ((d e) f) (g h i))`n"
    Assert-Output 'make-inserter: every length on ()' (Show "((make-inserter 'z (lambda (k) #t)) '())") "(z)`n"
    Assert-Output 'make-inserter: transformer is reusable' "(let ((ins (make-inserter 'z (lambda (k) (= k 0))))) (display (ins '())) (display (ins '(a))) (newline))" "(z)(a)`n"

    # --- 10,000 elements (generated) --------------------------------------
    $seq = New-Seq 1 10000
    $wide = "($seq)"
    $emptySubs = '(' + (New-Repeat '()' 10000) + ')'
    Assert-Output '10,000 elements: my-length' (Show "(my-length '$wide)") "10000`n"
    Assert-Output '10,000 elements: my-map content and order' (Show "(my-map (lambda (e) (+ e 1)) '$wide)") ('(' + (New-Seq 2 10001) + ")`n")
    Assert-Output '10,000 elements, n=10001: x at the front, all elements in order' (Show "(insert-if-short 'x '$wide 10001)") "(x $seq)`n"
    Assert-Output '10,000 elements, n=10000: unchanged' (Show "(insert-if-short 'x '$wide 10000)") "$wide`n"
    Assert-Output '10,000 empty sublists, n=1: each becomes (x)' (Show "(insert-if-short 'x '$emptySubs 1)") ('(' + (New-Repeat '(x)' 10000) + ")`n")

    # --- Nesting depth 100 (generated) -------------------------------------
    Assert-Output 'depth 100, n=2: x at every level' (Show ("(insert-if-short 'x '" + (New-Nest 100 '1') + ' 2)')) ((New-Nest 100 '1' 'x ') + "`n")
    Assert-Output 'depth 100, n=1: only the innermost () changes' (Show ("(insert-if-short 'x '" + (New-Nest 100 '()') + ' 1)')) ((New-Nest 100 '(x)') + "`n")
    Assert-Output 'depth 100, n=2: every level and innermost () get x' (Show ("(insert-if-short 'x '" + (New-Nest 100 '()') + ' 2)')) ((New-Nest 100 '(x)' 'x ') + "`n")

    # --- print-insert-result with real stdin, exact output ----------------
    Assert-Stdin 'stdin PDF 1' "42 ((1 2) (3 4 5) (6) ()) 3`n" '((42 1 2) (3 4 5) (42 6) (42))'
    Assert-Stdin 'stdin PDF 2' "0 (((1) 2) (3) ((4 5 6) ())) 3`n" '((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))'
    Assert-Stdin 'stdin PDF 3' "7 () 3`n" '(7)'
    Assert-Stdin 'stdin PDF 4' "7 () 0`n" '()'
    Assert-Stdin 'stdin values on separate lines' "z`n(a (b) ())`n2`n" '(a (z b) (z))'
    Assert-Stdin 'stdin symbols' "hello (world (foo bar) ()) 3`n" '(world (hello foo bar) (hello))'
    Assert-Stdin 'stdin 10,000 elements' "x $wide 10001`n" "(x $seq)"
    Assert-Stdin 'stdin depth 100' ('x ' + (New-Nest 100 '()') + " 2`n") (New-Nest 100 '(x)' 'x ')

    # --- The solution file was not modified --------------------------------
    $hashAfter = (Get-FileHash -LiteralPath $solution -Algorithm SHA256).Hash
    if ($hashAfter -eq $hashBefore) { $script:Passed++; Write-Output 'PASS: solution file unchanged by the tests' }
    else { $script:Failed++; Write-Output 'FAIL: solution file changed during the tests' }
}
catch {
    $script:Failed++
    Write-Output "FAIL: harness error: $($_.Exception.Message)"
}
finally {
    # Remove any temporary copy left behind by an interrupted case.
    if (Get-Variable -Name codeDir -Scope Script -ErrorAction SilentlyContinue) {
        Get-ChildItem -LiteralPath $codeDir -Filter '28_q4.*.test-tmp.rkt' -ErrorAction SilentlyContinue |
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}

Write-Output ('{0} passed, {1} failed' -f $script:Passed, $script:Failed)
if ($script:Failed -gt 0) { $exitCode = 1 }
exit $exitCode
