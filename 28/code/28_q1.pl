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
