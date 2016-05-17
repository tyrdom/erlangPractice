-module (getFromList).
-export ([car/1,
	cdr/1,
	getOne/2,
	qsort/1
	]).

getOne(1,[])-> not_found;
getOne(1,[P|_Q])-> P;
getOne(X,[_P|Q])-> getOne(X-1,Q).




car([P|_Q])->
P.
cdr([_P|Q])->
Q.


qsort([]) ->[];
qsort([P|Q]) ->
	qsort([X || X <- Q , X<P] ) ++ [P] ++qsort( [X || X <- Q , X<P]).

pythag(N)
->
	[{A,B,C}||
	A<-lists:seq(1,N),
	B<-lists:seq(1,N),
	C<-lists:seq(1,N),
	A+B+C=<N,
	A*A+B*B-C*C=:=0

	].

leftone([P|Q])
when [P||P<-Q]=:=[] -> [P|Q];
leftone([P|Q])->
leftone(Q-- [P||P<-Q]++[P]).



x(L) ->
  NL = y(L)

 y([], NL) -> NL;
 y([X | Rest], NL) ->
    case lists:member(X, NL) of
    	true -> y(Rest, NL);
    	false -> y(Rest, [X | NL]);
    end.