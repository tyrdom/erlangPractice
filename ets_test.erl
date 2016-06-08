-module (ets_test).
-export ([start/0]).

start() -> %ets_test:start().
	lists:foreach (fun test/1,[set,ordered_set,bag,duplicate_bag]).

test(Mode) ->
	TableId = ets:new(test,[Mode]),
	ets:insert(TableId,{a,1}),ets:insert(TableId,{b,2}),ets:insert(TableId,{a,1}),ets:insert(TableId,{a,3}),
	L = ets:tab2list(TableId),
	io:format("~p => ~p~n",[Mode,L]),
	ets:delete(TableId).
