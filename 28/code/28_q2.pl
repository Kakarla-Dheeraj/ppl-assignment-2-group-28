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

% expression(+Numbers, -Tree, -Value)
% For a finite proper list of non-negative integers, Tree uses every
% occurrence once in order, and Value is its integer value.
expression([N], num(N), N).
expression(Numbers, bin(Op, LeftTree, RightTree), Value) :-
    nonempty_split(Numbers, LeftNumbers, RightNumbers),
    expression(LeftNumbers, LeftTree, LeftValue),
    expression(RightNumbers, RightTree, RightValue),
    apply_op(Op, LeftValue, RightValue, Value).

% op_precedence(?Op, ?Prec)
% Prec is the precedence of a supported expression-tree operator.
op_precedence('+', 1).
op_precedence('-', 1).
op_precedence('*', 2).
op_precedence('/', 2).

% render_operand(+Tree, +ParentPrec, +Side, -Text)
% For a ground expression tree and Side left or right, Text is its string
% with the parentheses required in that operand position.
render_operand(num(N), _ParentPrec, _Side, Text) :-
    render_expression(num(N), Text).
render_operand(bin(Op, Left, Right), ParentPrec, Side, Text) :-
    op_precedence(Op, Prec),
    render_expression(bin(Op, Left, Right), InnerText),
    (   (   Side == left, Prec < ParentPrec
        ;   Side == right, Prec =< ParentPrec
        )
    ->  format(string(Text), '(~s)', [InnerText])
    ;   Text = InnerText
    ).

% render_expression(+Tree, -Text)
% Text is the canonical no-space string for a ground expression tree,
% without outer parentheses around the complete expression.
render_expression(num(N), Text) :-
    format(string(Text), '~d', [N]).
render_expression(bin(Op, Left, Right), Text) :-
    op_precedence(Op, Prec),
    render_operand(Left, Prec, left, LeftText),
    render_operand(Right, Prec, right, RightText),
    format(string(Text), '~s~a~s', [LeftText, Op, RightText]).

% generate_equation(+List, -Equation)
% For a finite proper list of non-negative integers, Equation is a canonical
% equation string using every occurrence once in order, with equal values.
generate_equation(List, Equation) :-
    nonempty_split(List, LeftNumbers, RightNumbers),
    expression(LeftNumbers, LeftTree, LeftValue),
    expression(RightNumbers, RightTree, RightValue),
    LeftValue =:= RightValue,
    render_expression(LeftTree, LeftText),
    render_expression(RightTree, RightText),
    format(string(Equation), '~s=~s', [LeftText, RightText]).

% all_equations(+List, -Equations)
% Equations contains every canonical equation string for List, once each,
% in standard term order; it is empty when no valid equation exists.
all_equations(List, Equations) :-
    findall(Equation, generate_equation(List, Equation), Generated),
    sort(Generated, Equations).
