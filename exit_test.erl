-module(exit_test).
%%-compile (export_all).
-export([on_exit/1,try_exit/0,start/2]).
on_exit(Pid) ->
	spawn (fun() ->
				process_flag(trap_exit,true),
				link(Pid),
				receive
					{'EXIT',Pid,Why } ->
						io:format("~p died with ~p ~n",[Pid,Why])
				end
			end).

try_exit() ->
	spawn (	fun() ->
				receive
					X -> list_to_atom(X)
				end
			end
		).

start(Bool , M)->
	A = spawn (fun() -> process_flag(trap_exit,true),
	  					 wait(a)
	  			end),
	B = spawn (fun() ->	process_flag(trap_exit,Bool),
						link(A),
						wait(b) 
				end),
	C = spawn (fun() -> 	link(B),
							case M of
								{die , Reason} ->
										exit(Reason);
								{divide,_N} ->
										wait (c);
								normal ->
										true
							end 
				end),
	sleep(1000),
	status (a,A),
	status (b,B),
	status (c,C).



wait(Pr) ->
	receive X-> io:format("process ~p receive ~p ~n" ,[Pr,X]),wait(Pr) end.


sleep(T) ->
	receive
	after T ->true end.

status (N , P) ->
 case is_process_alive(P) of
 	true ->
 		io:format("process ~p (~p) is alive ~n",[N,P]);
 	false ->
 		io:format("process ~p (~p) is dead ~n",[N,P])
 end.