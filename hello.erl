
-module (hello).

-export ([
	print/0,
	print/1,
	ooo/0
]).

-record (student, {
	id,
	name = "unknown",
	grade = 1
}).

print() ->
	io:format("running~p ~n",[[65,97]]),
	ok.

print(X) ->
	io:format("~p~p~n", [X,X]),
	ok.

ooo() ->
	St = #student{grade = Grade} = #student{id=1, name="cai", grade = 9},
	io:format("~p~n", [St]),

	St2 = St#student{grade = Grade + 1},
	io:format("~p~n", [St2]),

	X=[St,St2],
	io:format("~p~n", [X]),
	ok.
