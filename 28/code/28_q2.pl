% nonempty_split(+List, -Left, -Right)
% For a finite proper List, Left and Right are nonempty contiguous parts
% whose concatenation is List, preserving the original element order.
nonempty_split([Head, Next|Tail], [Head], [Next|Tail]).
nonempty_split([Head|Tail], [Head|Left], Right) :-
    nonempty_split(Tail, Left, Right).
