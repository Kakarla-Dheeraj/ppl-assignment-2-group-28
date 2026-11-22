% nonempty_split(+List, -Left, -Right)
% For a finite proper List, Left and Right are nonempty contiguous parts
% whose concatenation is List, preserving the original element order.
nonempty_split([Head, Next|Tail], [Head], [Next|Tail]).
nonempty_split([Head|Tail], [Head|Left], Right) :-
    nonempty_split(Tail, Left, Right).

% apply_op(?Op, +A, +B, -Value)
% For ground integers A and B, Value is the integer result of Op.
% With Op unbound, enumerate each valid operator once; division is exact.
apply_op('+', A, B, Value) :-
    Value is A + B.
apply_op('-', A, B, Value) :-
    Value is A - B.
apply_op('*', A, B, Value) :-
    Value is A * B.
apply_op('/', A, B, Value) :-
    B =\= 0,
    0 =:= A rem B,
    Value is A // B.
