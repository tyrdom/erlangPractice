-module (chains).
-compile (export_all).

start () ->
	spawn(fun() -> loop ([]) end).

rpc(Pid,Req)->
	Pid ! {self() ,Req},
	receive 
		{Pid,Resp} ->Resp
	end.

loop(X) ->
	receive
		{Addr,Any} -> io:format("receive:~p~n from ~p",[Any,Addr]),
		loop(X)
	end.