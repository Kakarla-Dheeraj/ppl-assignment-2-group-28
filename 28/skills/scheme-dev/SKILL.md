---
name: scheme-dev
description: Develop and review the assignment's Scheme solutions using Racket 8.x with #lang racket/base, strict built-in whitelists, pure functional style, and grading constraints.
---

# Scheme development for PPL Assignment 2

Use Racket 8.x with `#lang racket/base`. Treat the assignment PDF as the single source of truth for problem requirements. Work strictly on the single unit requested in the prompt: one function, one test file, or one review. Do not solve an entire problem or expand one prompt into multiple deliverables.

## Assignment constraints and built-in whitelist

Scheme code must be written in `#lang racket/base` and must use **only** the allowed built-ins:

> Only the following built-ins may be used: `define`, `lambda`, `let`, `let*`, `letrec`, `named let`, `if`, `cond` (with `else`), `and`, `or`, `not`, `begin`, `quote` (written `'`), `cons`, `car`, `cdr`, `list`, every composition of `car` and `cdr` up to four levels (`cadr`, `cddr`, `caddr`, `cdddr`, `cadddr`, `cddddr`, and so on), `null?`, `pair?`, `eq?`, `assq`, `assoc`, the arithmetic and comparison operators `+`, `-`, `*`, `<`, `>`, `<=`, `>=`, `=`, `max`, `display` and `newline`. `S2` additionally allows `read`.

Nothing else from `racket/base` may be used:

- **No extra libraries or imports:** Do not use `require` in solution files.
- **No mutable state:** `set!` and its relatives (`set-car!`, `set-cdr!`, etc.) are strictly forbidden. Pass all state through function arguments.
- **No loops:** `do`, `for`, `for/list`, and similar loop constructs are forbidden.
- **No forbidden data structures:** No vectors, hash tables, strings, or string-manipulation functions.
- **No forbidden list utilities:** `length`, `append`, `reverse`, `map`, `filter`, `member`, `memq`, `list-ref`, and `list-tail` are strictly forbidden. If any such helper is needed, implement a custom version (e.g. `my-length`, `my-append`, `my-reverse`, `my-map`) using only the whitelisted primitives.
- **Problem-specific I/O:** `read` is allowed **only** for S2 (`id_q4.rkt`). For S1 (`id_q3.rkt`), `read` is forbidden. Both problems use `display` and `newline`.
- **Solution files contain definitions only:** Never include top-level execution calls, expressions, or test queries in submitted solution files. The file must load completely silently with zero output; the automated grader appends its own test calls to the end of the file.

## Conventions: naming, arguments, and recursive comments

- Use lowercase `kebab-case` for all function names, predicate helpers, and parameters (e.g., `print-inorder`, `tree-height`, `my-append`).
- Include a descriptive contract and recursive invariant comment directly above each function:
  - Document the expected input structure (e.g., `tree` as `()` or `(value left right)`).
  - Describe the base case and the recursive decomposition.
  - State the returned value or observed output (e.g., printed output via `display` ending with `newline`).
- All state must be passed explicitly through function arguments. Do not rely on closures holding mutable state or global variables.
- Prefer tail recursion where natural, using accumulators (`named let` or tail-recursive inner helpers) to maintain efficiency and stack safety.

## Empty lists and nested structures

- **Base cases:** Always check `null?` first. The empty tree `()` has height `0` and `0` leaves. In nested lists, `()` has length `0`.
- **Empty lists are not special:** For S2, `()` is a valid list of length 0, so it becomes `(x)` when `0 < n`.
- **Original-length semantics:** In nested list transformations, the length of each list or sublist must be evaluated on the original list before any element insertion occurs.
- **Avoid redundant traversals:** Do not traverse a tree or list multiple times if values can be combined or computed in a single pass (for example, computing height and leaves simultaneously, or traversing while printing).

## Scalability: deep nesting and large lists

- Grader test suites include hidden tests with nesting depths of 100 and lists containing 10,000 elements.
- Ensure all list-processing helpers (such as length calculations, mapping, reversal, and accumulators) are tail-recursive to prevent call-stack overflow on large inputs.

## Windows checks with Racket

Run these commands from the repository root in PowerShell. The grader appends its own calls to the end of the file. To test locally without altering the solution file, create a temporary copy (ignored by `.gitignore` as `*.test-tmp.rkt`), append test queries, run with Racket, and remove the temporary file.

```powershell
# 1. Verify that the solution file loads silently without errors or load-time output:
& "C:\Program Files\Racket\racket.exe" .\28\code\28_q3.rkt

# 2. Run a specific test call by appending to a temporary copy:
$tempFile = ".\28\code\28_q3.test-tmp.rkt"
Copy-Item .\28\code\28_q3.rkt $tempFile
Add-Content $tempFile "`n(print-inorder '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))"
& "C:\Program Files\Racket\racket.exe" $tempFile
Remove-Item $tempFile

# 3. Run the complete automated test script once created:
powershell -ExecutionPolicy Bypass -File .\28\tests\test_s1.ps1
```

Note: If `racket` is on PATH, you can invoke `racket` directly; otherwise use the absolute executable path `& "C:\Program Files\Racket\racket.exe"`.

## Self-review checklist before responding

- [ ] Worked strictly on the single unit (function, test file, or review) requested in this prompt.
- [ ] Solution file begins with `#lang racket/base` and contains **only definitions** (no top-level calls, no load-time output).
- [ ] Every built-in used is strictly on the whitelist; no unlisted functions (`require`, `set!`, `length`, `append`, `reverse`, `map`, `filter`, `member`, `strings`, `loops`).
- [ ] `read` is used only in S2 (`id_q4.rkt`), never in S1 (`id_q3.rkt`).
- [ ] Empty lists/trees `()` are handled correctly according to assignment specifications.
- [ ] In nested operations, lengths reflect original lists prior to any insertions.
- [ ] All state is passed via arguments; helpers use tail recursion where natural for deep nesting and 10,000-element inputs.
- [ ] Functions end their output with `newline` as required.
- [ ] Tested the code using temporary copies with Racket on Windows, reporting exact observed results without unverified claims.

## Common AI mistakes to catch

- Importing libraries or modules using `require`.
- Using convenient forbidden built-ins: `length`, `append`, `reverse`, `map`, `filter`, `member`, `list-ref`, `format`, or `string?`.
- Using `set!`, `set-car!`, `set-cdr!`, or any mutable state.
- Leaving test calls (e.g. `(print-inorder t1)`) at the bottom of the solution file.
- Printing extra spaces, parentheses, or forgetting the final `(newline)`.
- Using `read` in S1 (only permitted in S2).
- Non-tail recursive list algorithms causing stack overflows on 10,000 elements.
- Implementing multiple functions or the whole assignment problem at once instead of one unit per prompt.
