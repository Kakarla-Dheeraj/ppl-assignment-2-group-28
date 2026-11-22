---
name: prolog-dev
description: Develop and review the assignment's Prolog predicates with SWI-Prolog 9.x while following its library, purity, and grading constraints.
---

# Prolog development for PPL Assignment 2

Use SWI-Prolog 9.x. Treat the assignment PDF as the source of requirements for the specific predicate. Work only on the unit in the current prompt: one predicate, one test file, or one review. Do not expand one prompt into a complete problem solution.

## Assignment constraints

- The only libraries permitted by the Prolog problems are `lists`, `apply`, `yall`, and `aggregate`. Import only a permitted library when it is needed; prefer built-ins otherwise.
- Solution files contain predicate definitions only. Do not add directives that run code when loading the file, including `initialization/1`. Do not call `halt/0` in a solution file.
- Do not use `assert/1`, `retract/1`, `b_setval/2`, `nb_setval/2`, or any other mutable global state.
- For arithmetic-equation work, represent expressions as terms and evaluate those terms directly. Never build a string and parse it back into a term to evaluate it.
- Preserve the requested output type and format exactly. In particular, where an equation is required, return an SWI-Prolog string, not an atom or code list.

## Names, arguments, and modes

- Use lowercase `snake_case` for predicate and helper names. Use descriptive `UpperCamelCase` or `Upper_Snake_Case` variables beginning with a capital letter; use `_` for a value that is intentionally unused.
- Keep public predicate names and arities exactly as specified by the assignment. Use helper predicates with names that describe their relation or role.
- State intended modes in a short comment above each public predicate, such as `% solve(+Clues, -Solution)` or `% eval_expr(+Expr, -IntegerValue)`. `+` means expected input, `-` output, and `?` either; these are documentation, not runtime checks.
- Make modes reflect how the code is actually called. When a predicate requires ground inputs for negation or arithmetic, document that precondition and arrange callers to establish it first.

## Declarative comments and relations

- Describe what a predicate relates and its important preconditions or result shape, not a line-by-line account of control flow.
- Add a short invariant comment where it clarifies recursive state, such as what a remaining list contains or what an expression/value pair represents.
- Keep each clue or independently specified relation separate when the assignment asks for separate clauses or predicates. Do not hide required relations in a monolithic procedural check.
- Comments must describe the implemented relation accurately; do not claim generality beyond the modes and finite input assumptions the code supports.

## Negation, arithmetic, and search

- Use negation as failure (`\+ Goal`) only when every variable relevant to `Goal` is already ground. If the intended condition is inequality between possibly unbound terms, use a relational constraint only if permitted and appropriate; do not rely on `\+ X = Y` as a general inequality relation.
- Before `is/2`, ground every arithmetic operand. Use `=:=`, `=\=`, `<`, `=<`, `>`, or `>=` only when both arithmetic expressions are evaluable. Remember that unification (`=`) does not evaluate arithmetic.
- Model arithmetic expressions as data and evaluate recursively. Guard division against zero and check exact divisibility before integer division; SWI-Prolog `/` produces a rational/float-style arithmetic result rather than the required integer result.
- Make generation finite by drawing every choice from a finite input list, finite domain, or bounded recursive decomposition. Ensure recursive calls consume input or reduce a finite measure. Do not use an unbounded generator and hope a later test will constrain it.
- Check termination on empty, singleton, and otherwise undersized inputs where the assignment requires failure or an empty result. Avoid arithmetic or list operations that raise errors on these cases.
- Avoid duplicate answers by making each choice/decomposition unique where possible. If the contract requests unique collected answers, deduplicate explicitly (for example with `sort/2`) and return them in the required order. Check for multiple proof paths that produce the same observable result.

## Windows checks with SWI-Prolog

Run these from the repository root in PowerShell. Replace `id_q1.pl`, predicate names, and example goals with the requested file and predicate. Keep query text inside double quotes and Prolog atoms in single quotes where required.

```powershell
# Load a solution file without calling a solution predicate.
swipl -q -t halt -s .\28\code\id_q1.pl

# Inspect a predicate's clauses and arity.
swipl -q -f .\28\code\id_q1.pl -g "listing(clue/2)" -t halt

# Check a specific ground or mode-appropriate query.
swipl -q -f .\28\code\id_q1.pl -g "clue(1, Solution), writeln(Solution)" -t halt

# Run the assignment's entry point when the task specifies it.
swipl -q -f .\28\code\id_q1.pl -g main -t halt

# Run a PlUnit test file when it defines tests and its test runner.
swipl -q -s .\28\tests\prolog_tests.pl -g run_tests -t halt
```

The `-t halt` above is a command-line top-level action, not code to put in a solution file. Do not add `halt/0` or an initialization directive to submitted Prolog source. Use the exact file names and launch commands required by the assignment when checking a deliverable.

## Self-review before responding

- [ ] I worked only on the one predicate, one test file, or one review requested in this prompt.
- [ ] Public predicate names, arities, argument meanings, modes, output types, and formatting match the assignment.
- [ ] Imported libraries are limited to `lists`, `apply`, `yall`, and `aggregate`.
- [ ] The solution file contains definitions only and no `initialization`, `halt/0`, mutation, or global state.
- [ ] Every use of negation is ground-safe; every arithmetic operation has evaluable operands.
- [ ] Search and recursion are finite for all inputs covered by the contract, including empty or short inputs.
- [ ] Each intended answer has one proof path, or collected results are deduplicated and sorted as required.
- [ ] Arithmetic equations are evaluated from expression terms, never by parsing generated strings.
- [ ] Comments describe declarative relations and real mode/precondition assumptions.
- [ ] I checked the requested predicates with the assignment-appropriate SWI-Prolog command and reported any unverified behavior honestly.

## Common AI mistakes to catch

- Importing a convenient but unapproved library or using a predicate that the problem's whitelist excludes.
- Putting `initialization/1`, `halt/0`, demonstration calls, or extra output in a solution file.
- Using `assert`/`retract` or a global variable as a shortcut for collecting or remembering solutions.
- Applying `\+` before a variable is instantiated, or treating `\=` as a general arithmetic inequality.
- Calling `is/2` with an unbound expression, or using `=` where arithmetic comparison/evaluation is required.
- Using `/` without checking nonzero divisor and exact divisibility, or accidentally allowing non-integer results.
- Generating an infinite domain before checking constraints, or recursing without consuming input.
- Returning duplicate answers because of symmetric choices or multiple derivations, or forgetting required sorting.
- Evaluating an expression by turning it into source text and parsing that text back into Prolog.
- Solving multiple predicates or an entire assignment problem in one later prompt; keep each prompt to one predicate, one test file, or one review.
