[23bcs101@mepcolinux ex6]$cat arithmetic.pl
% ============================================================
% Prolog Program: Combination of Simple Arithmetic & Set Theory
% ============================================================

% -----------------------------------------------------------
% ARITHMETIC OPERATIONS (1–4)
% -----------------------------------------------------------

% 1. Addition
add(X, Y, Result) :-
    number(X),
    number(Y),
    Result is X + Y.

% 2. Subtraction
subract(X, Y, Result) :-
    number(X),
    number(Y),
    Result is X - Y.

% 3. Multiplication
multiply(X, Y, Result) :-
    number(X),
    number(Y),
    Result is X * Y.

% 4. Integer Division (with zero-check)
divide(_, 0, _) :-
    write('Error: Division by zero'), nl, fail.
divide(X, Y, Result) :-
    number(X),
    number(Y),
    Y =\= 0,
    Result is X / Y.

% -----------------------------------------------------------
% SET THEORY OPERATIONS (5–8)
% -----------------------------------------------------------

% 5. Union of two sets (A ∪ B)
%    Combines both sets, removing duplicates.
set_union([], B, B).
set_union([H|T], B, Union) :-
    member(H, B), !,
    set_union(T, B, Union).
set_union([H|T], B, [H|Union]) :-
    set_union(T, B, Union).

% 6. Intersection of two sets (A ∩ B)
%    Elements common to both sets.
set_intersection([], _, []).
set_intersection([H|T], B, [H|Intersection]) :-
    member(H, B), !,
    set_intersection(T, B, Intersection).
set_intersection([_|T], B, Intersection) :-
    set_intersection(T, B, Intersection).

% 7. Difference of two sets (A \ B)
%    Elements in A but not in B.
set_difference([], _, []).
set_difference([H|T], B, Difference) :-
    member(H, B), !,
    set_difference(T, B, Difference).
set_difference([H|T], B, [H|Difference]) :-
    set_difference(T, B, Difference).

% 8. Subset check (A ⊆ B)
%    True if every element of A is in B.
set_subset([], _).
set_subset([H|T], B) :-
    member(H, B),
    set_subset(T, B).

% -----------------------------------------------------------
% COMBINED OPERATIONS (Arithmetic on Set Results)
% -----------------------------------------------------------

% Sum all elements of a set
set_sum([], 0).
set_sum([H|T], Sum) :-
    number(H),
    set_sum(T, RestSum),
    Sum is H + RestSum.

% Compute the size (cardinality) of a set
set_size([], 0).
set_size([_|T], Size) :-
    set_size(T, RestSize),
    Size is RestSize + 1.


==============================================================
OUTPUT
==============================================================
?- consult('arithmetic.pl').
true.

?- add(7,3,R).
R = 10.

?- subract(7,3,R).
R = 4.

?- multiply(4,3,R).
R = 12.

?- divide(8,2,R).
R = 4.

?- divide(8,0,R).
Error: Division by zero
false.

[23bcs101@mepcolinux ex6]$cat pizza_hut.pl
:- dynamic menu_item/2.

% ----------- Initial menu -----------
menu_item('Margherita', 300).
menu_item('Pepperoni', 400).
menu_item('Veggie', 350).
menu_item('BBQ Chicken', 450).
menu_item('Farmhouse', 420).
menu_item('Paneer Tikka', 430).
menu_item('Cheese Burst', 480).
menu_item('Garlic Bread', 160).
menu_item('Cheesy Dip', 40).
menu_item('Coke', 60).
menu_item('Brownie', 120).

% ----------- Entry point -----------
order :-
    nl, writeln('Welcome to Pizza Hut!'),
    show_menu,
    nl, writeln('Start ordering. (Type "done" to finish).'),
    order_items([], RawOrder),
    merge_order(RawOrder, Order), % Combine duplicate items
    display_bill(Order).

% ----------- Show menu -----------
show_menu :-
    nl, writeln('-------- MENU --------'),
    format('~w~t~25|~w~n', ['Item', 'Price']),
    writeln('--------------------------------'),
    forall(menu_item(Item, Price),
           format('~w~t~25|~d~n', [Item, Price])),
    writeln('--------------------------------').

% ----------- Find item case-insensitively -----------
find_item(InputStr, RealName, Price) :-
    string_lower(InputStr, LowerInput),
    menu_item(RealName, Price),
    atom_string(RealName, MenuNameStr),
    string_lower(MenuNameStr, LowerInput),
    !. % Stop searching once found

% ----------- Take orders cleanly -----------
order_items(Current, Final) :-
    write('Enter item name: '), flush_output,
    read_line_to_string(user_input, InputStr),
    normalize_space(string(CleanStr), InputStr),

    ( string_lower(CleanStr, "done") ->
        Final = Current
    ; CleanStr == "" -> % User just pressed Enter by mistake
        order_items(Current, Final)
    ; find_item(CleanStr, RealName, Price) ->
        write('Enter quantity: '), flush_output,
        read_line_to_string(user_input, QtyStr),
        ( number_string(Qty, QtyStr) ->
            append(Current, [order(RealName, Qty, Price)], New),
            order_items(New, Final)
        ; writeln('Invalid quantity, try again.'),
          order_items(Current, Final)
        )
    ; % Item not in KB -> Add it
        format('Item not found. Enter price for "~w": ', [CleanStr]), flush_output,
        read_line_to_string(user_input, PriceStr),
        ( number_string(UserPrice, PriceStr) ->
            atom_string(NewItemAtom, CleanStr),
            assertz(menu_item(NewItemAtom, UserPrice)),
            format('Added "~w" to menu.~n', [NewItemAtom]),
            write('Enter quantity: '), flush_output,
            read_line_to_string(user_input, QtyStr2),
            ( number_string(Qty2, QtyStr2) ->
                append(Current, [order(NewItemAtom, Qty2, UserPrice)], New2),
                order_items(New2, Final)
            ; writeln('Invalid quantity, skipping...'),
              order_items(Current, Final)
            )
        ; writeln('Invalid price, try again.'),
          order_items(Current, Final)
        )
    ).

% ----------- Merge duplicate items -----------
merge_order(Raw, Merged) :- merge_order_(Raw, [], Merged).

merge_order_([], Acc, Acc).
merge_order_([order(Item, Qty, Price)|T], Acc, Out) :-
    ( select(order(Item, OldQty, Price), Acc, AccRest) ->
        NewQty is OldQty + Qty,
        Acc2 = [order(Item, NewQty, Price)|AccRest]
    ; Acc2 = [order(Item, Qty, Price)|Acc]
    ),
    merge_order_(T, Acc2, Out).

% ----------- Display bill -----------
display_bill(OrderList) :-
    nl, writeln('-------- BILL --------'),
    format('~w~t~25|~w~t~35|~w~n', ['Item', 'Qty', 'Subtotal']),
    writeln('-------------------------------------------'),
    bill_total(OrderList, 0, GrandTotal),
    writeln('-------------------------------------------'),
    format('Grand Total: ~d~n', [GrandTotal]),
    writeln('Thank you for ordering!').

bill_total([], Total, Total).
bill_total([order(Item, Qty, Price)|T], Acc, Total) :-
    SubTotal is Qty * Price,
    format('~w~t~25|~d~t~35|~d~n', [Item, Qty, SubTotal]),
    Acc2 is Acc + SubTotal,
    bill_total(T, Acc2, Total).

========================================================================
OUTPUT
========================================================================
?- consult('pizza_hut.pl').
true.

?- order.

Welcome to Pizza Hut!

-------- MENU --------
Item                     Price
--------------------------------
Margherita               300
Pepperoni                400
Veggie                   350
BBQ Chicken              450
Farmhouse                420
Paneer Tikka             430
Cheese Burst             480
Garlic Bread             160
Cheesy Dip               40
Coke                     60
Brownie                  120
--------------------------------

Start ordering. (Type "done" to finish).
Enter item name: Veggie
Enter quantity: 2
Enter item name: Coke
Enter quantity: 2
Enter item name: done

-------- BILL --------
Item                     Qty       Subtotal
-------------------------------------------
Coke                     2         120
Veggie                   2         700
-------------------------------------------
Grand Total: 820
Thank you for ordering!
true.
% ---------- Generation 1 ----------
parent(attingal_elaya_thampuran, sethu_lakshmi_bayi).
parent(attingal_elaya_thampuran, sethu_parvathi_bayi).
parent(attingal_elaya_thampuran, other_sister_1).
% ---------- Generation 2 ----------
parent(sethu_parvathi_bayi, chithira_thirunal).
parent(sethu_parvathi_bayi, uthradom_thirunal).
parent(sethu_parvathi_bayi, karthika_thirunal).
% ---------- Generation 3 ----------
parent(karthika_thirunal, pooyam_thirunal).
parent(karthika_thirunal, aswathi_thirunal).
parent(pooyam_thirunal, moolam_thirunal).
parent(pooyam_thirunal, revathi_thirunal).
% ---------- Generation 4 ----------
parent(moolam_thirunal, prince_kerala_varma).
parent(moolam_thirunal, princess_lakshmi_bayi).
parent(moolam_thirunal, prince_aditya_varma).
parent(moolam_thirunal, princess_gowri_parvathi).
parent(aswathi_thirunal, shreekumar_varma).
parent(aswathi_thirunal, princess_rukmini).
% ---------- Generation 5 ----------
parent(princess_lakshmi_bayi, princess_saraswati_lakshmi).
parent(princess_lakshmi_bayi, prince_jayanta_thirunal_iii).
parent(princess_lakshmi_bayi, prince_narayana_varma_iii).
parent(princess_rukmini, princess_maya_lakshmi).
parent(shreekumar_varma, princess_gowri_parvathi).
% ========================
% FACTS: gender
% ========================
gender(attingal_elaya_thampuran, female).
gender(sethu_lakshmi_bayi, female).
gender(sethu_parvathi_bayi, female).
gender(other_sister_1, female).
gender(chithira_thirunal, male).
gender(uthradom_thirunal, male).
gender(karthika_thirunal, female).
gender(pooyam_thirunal, female).
gender(aswathi_thirunal, female).
gender(moolam_thirunal, male).
gender(revathi_thirunal, male).
gender(prince_kerala_varma, male).
gender(princess_lakshmi_bayi, female).
gender(princess_gowri_parvathi, female).
gender(prince_aditya_varma, male).
gender(shreekumar_varma, male).
gender(princess_rukmini, female).
gender(princess_saraswati_lakshmi, female).
gender(prince_jayanta_thirunal_iii, male).
gender(prince_narayana_varma_iii, male).
gender(princess_maya_lakshmi, female).
gender(princess_gowri_parvathi, female).
mother(Mother, Child) :-
 parent(Mother, Child),
 gender(Mother, female).
father(Father, Child) :-
 parent(Father, Child),
 gender(Father, male).
sibling(X, Y) :-
 parent(P, X),
 parent(P, Y),
 X \= Y.
brother(Brother, Person) :-
 sibling(Brother, Person),
 gender(Brother, male).
sister(Sister, Person) :-
 sibling(Sister, Person),
 gender(Sister, female).
grandparent(GP, GC) :-
 parent(GP, P),
 parent(P, GC).
grandmother(GM, GC) :-
 grandparent(GM, GC)
gender(GM, female).
grandfather(GF, GC) :-
 grandparent(GF, GC),
 gender(GF, male).
aunt(Aunt, Person) :-
 parent(P, Person),
 sister(Aunt, P).
uncle(Uncle, Person) :-
 parent(P, Person),
 brother(Uncle, P).
nephew(Nephew, Person) :-
 sibling(Parent, Person),
 parent(Parent, Nephew),
 gender(Nephew, male).
niece(Niece, Person) :-
 sibling(Parent, Person),
parent(Parent, Niece),
 gender(Niece, female).
cousin(X, Y) :-
 parent(P1, X),
 parent(P2, Y),
 sibling(P1, P2),
 X \= Y.
ancestor(A, D) :- parent(A, D).
ancestor(A, D) :-
 parent(A, X),
 ancestor(X, D).
descendant(D, A) :- ancestor(A, D).
generation(attingal_elaya_thampuran, 0).
generation(Person, N) :-
 parent(P, Person),
 generation(P, N1),
 N is N1 + 1.
