# PPL Assignment 2 - Group 28

Logic and Functional Programming (CS F301) — SWI-Prolog 9.x and Racket 8.x

---

## 1. Problem Ownership & Allocation

| Problem | Paradigm & Topic | Solution File | Test Suite | Prompt Log | Owner |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **P1** | Prolog: Department Assignment Puzzle | `28/code/28_q1.pl` | `28/tests/test_p1.ps1` | `28/prompts/P1.md` | Pranith Mahanti |
| **P2** | Prolog: Valid Arithmetic Equations | `28/code/28_q2.pl` | `28/tests/test_p2.ps1` | `28/prompts/P2.md` | Kakarla Dheeraj |
| **S1** | Scheme: Binary Tree Traversals | `28/code/28_q3.rkt` | `28/tests/test_s1.ps1` | `28/prompts/S1.md` | Yashavanth |
| **S2** | Scheme: Conditional Nested List Insertion | `28/code/28_q4.rkt` | `28/tests/test_s2.ps1` | `28/prompts/S2.md` | Samantula Devendra Supreeth |

---

## 2. Repository Layout

The repository strictly follows the deliverable layout defined in Section 4 of the assignment specification:

```text
ppl-assignment-2-group-28/
├── 28/
|   ├── P1_REPORT.md            # Report on P1.b solution count
│   ├── code/
│   │   ├── 28_q1.pl            # P1 Prolog solution (definitions only)
│   │   ├── 28_q2.pl            # P2 Prolog solution (definitions only)
│   │   ├── 28_q3.rkt           # S1 Scheme solution (#lang racket/base, definitions only)
│   │   └── 28_q4.rkt           # S2 Scheme solution (#lang racket/base, definitions only)
│   ├── tests/
│   │   ├── test_p1.ps1         # P1 automated test suite
│   │   ├── test_p2.ps1         # P2 automated test suite
│   │   ├── test_s1.ps1         # S1 automated test suite
│   │   └── test_s2.ps1         # S2 automated test suite
│   ├── skills/
│   │   ├── prolog-dev/
│   │   │   └── SKILL.md        # Prolog development conventions & constraints
│   │   └── scheme-dev/
│   │       └── SKILL.md        # Scheme development conventions & constraints
│   └── prompts/
│       ├── SETUP.md            # Setup prompts for skill files
│       ├── P1.md               # Prompt log for Problem P1
│       ├── P2.md               # Prompt log for Problem P2
│       ├── S1.md               # Prompt log for Problem S1
│       └── S2.md               # Prompt log for Problem S2
└── README.md                   # Repository documentation and test handoff
```

---

## 3. Required Tool Versions

- **SWI-Prolog:** Version 9.x (e.g., SWI-Prolog 9.0+)
- **Racket:** Version 8.x (e.g., Racket 8.18 with `#lang racket/base`)
- **Shell:** PowerShell 5.1 or PowerShell 7.x on Windows

---

## 4. Testing Handoff & Root-Level Commands

All test suites are automated PowerShell scripts designed to be executed directly from the repository root:

```powershell
& ./28/tests/test_p1.ps1
& ./28/tests/test_p2.ps1
& ./28/tests/test_s1.ps1
& ./28/tests/test_s2.ps1
```

### Execution & Failure Semantics
- **Strict Error Handling:** Every test script runs with `$ErrorActionPreference = 'Stop'`.
- **Nonzero Exit on Failure:** If any individual assertion fails or an unexpected exception/timeout occurs, the script must throw an error and exit with a nonzero status code (typically `exit 1`).
- **Zero Exit Required:** A clean exit with code `0` (`exit 0`) is strictly required to indicate that all assertions have passed.
- **Silent Loading Contract:** Solution files must never include top-level calls or load-time printing; each test suite enforces that loading the solution file without calls produces 0 bytes of stdout.

### Agreed Expected PASS Behavior
Across all test files in the repository:
1. Each successful check emits: `PASS: <check name>`.
2. Upon passing all checks in the suite, the script emits: `All <N> <Problem> checks passed.` and terminates with exit code `0`.
3. If an assertion fails, the script outputs the failure reason and terminates with exit code `1`.

---

## 5. Test Status (Completed Merged Repository)

All four problems are implemented and merged. The recorded test results are:

| Problem | Test command | Result | Problem owner |
| :--- | :--- | :--- | :--- |
| P1 | `& ./28/tests/test_p1.ps1` | Passed | Pranith |
| P2 | `& ./28/tests/test_p2.ps1` | All 95 checks passed | Dheeraj |
| S1 | `& ./28/tests/test_s1.ps1` | Passed | Yashavanth |
| S2 | `& ./28/tests/test_s2.ps1` | Passed | Supreeth |

P1 and P2 passed during repository review. Both local runs of S1 and S2 were successful as well.
