:- use_module(library(lists), [member/2, permutation/2]).

% candidate_solution(-Solution) generates each fully populated assignment once.
candidate_solution(Solution) :-
    permutation([research, development, design, testing],
                [AlexDept, BenDept, CarlaDept, DanaDept]),
    permutation([python, java, 'c++', javascript],
                [AlexLang, BenLang, CarlaLang, DanaLang]),
    permutation(['AI', web, embedded, data],
                [AlexProject, BenProject, CarlaProject, DanaProject]),
    Solution = [
        p('Alex', AlexDept, AlexLang, AlexProject),
        p('Ben', BenDept, BenLang, BenProject),
        p('Carla', CarlaDept, CarlaLang, CarlaProject),
        p('Dana', DanaDept, DanaLang, DanaProject)
    ].

% clue(+Number, +GroundSolution) checks the numbered clue against a filled solution.
clue(1, Solution) :-
    member(p(Name, Dept, _, 'AI'), Solution),
    Dept \= research,
    Name \= 'Dana'.

% Alex's department is not development and his language is not C++.
clue(2, Solution) :-
    member(p('Alex', Dept, Lang, _), Solution),
    Dept \= development,
    Lang \= 'c++'.

% The friend in testing is assigned Python.
clue(3, Solution) :-
    member(p(_, testing, python, _), Solution).

% Ben prefers web projects and does not work in testing.
clue(4, Solution) :-
    member(p('Ben', Dept, _, web), Solution),
    Dept \= testing.

% The friend who prefers Java works in design.
clue(5, Solution) :-
    member(p(_, design, java, _), Solution).

% Carla's project is not embedded and her department is not development.
clue(6, Solution) :-
    member(p('Carla', Dept, _, Project), Solution),
    Dept \= development,
    Project \= embedded.

% Dana's language is not Java, and her department is research or testing.
clue(7, Solution) :-
    member(p('Dana', Dept, Lang, _), Solution),
    Lang \= java,
    (Dept = research ; Dept = testing).

% The friend with data works in research and does not use JavaScript.
clue(8, Solution) :-
    member(p(_, research, Lang, data), Solution),
    Lang \= javascript.

% satisfies_clues(+Active, +GroundSolution) checks every listed clue.
satisfies_clues(Active, Solution) :-
    forall(member(Number, Active), clue(Number, Solution)).
