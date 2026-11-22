# P1 Report

The clues 1 through 8 admit **3 solutions**. The puzzle is therefore ambiguous: it has solutions, but the clues do not determine a unique one.

The ninth clue is: **The friend who works in design prefers the embedded project.** It refers only to department and project attributes and holds for exactly one of the three original solutions. With clue 9 active, the count is **1**, so the repaired puzzle has a unique solution.

## Count query and observed result

I ran this from the repository root with SWI-Prolog:

```powershell
swipl -q -f .\28\code\28_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N),count_solutions([1,2,3,4,5,6,7,8,9],M),format('N8=~d N9=~d~n',[N,M])" -t halt
```

Observed output:

```text
N8=3 N9=1
```
