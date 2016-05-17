-module (atimer).

-export([start/1,cancel/1,reboot/2,check/1,timer/1]).

start(T) -> spawn(fun()-> timer(T) end).


timer(T) ->
	receive
		{Addr,cancel} ->
			io:format("XXXXXXXXXXXX"),
			Addr ! {self(), stop}, 
			io:format("send to ~p stop ~n",[Addr]);
		{Addr,check} ->
			Addr ! {self(),erlang:timestamp()},timer(T);
		{Addr,X} ->
			io:format("send to ~p timer go again at ~p ~n",[Addr,X]),

			Addr ! {self(), again},

			timer(X);

		_-> nogood
	after T ->
			
			timer(T)
	end.

cancel(Pid) ->
    case is_process_alive(Pid) of
    	false -> io:format("~p is dead", [Pid]);
    	true ->
				Pid ! {self(), cancel},
			receive
				{Pid,Resp}->Resp ,io:format("from ~p get ~p ~n",[Pid,Resp])		
			end
	end.


reboot(Pid,T)->
	case is_process_alive(Pid) of 
		false ->io:format("~p is dead",[Pid]);
		true  ->Pid!{self(),T},
				io:format("send to ~p ~n" ,[Pid]),
				receive
					{Pid,Resp}->Resp,
								io:format("from ~p get ~p ~n",[Pid,Resp])
				end
	end.


check(Pid) ->
	case is_process_alive(Pid) of 
		false ->io:format("~p is dead",[Pid]);
		true  ->
				io:format("send to ~p ~n" ,[Pid]),
				Pid!{self(),check},
				receive
					{Pid,stop}->stopcheck,
								io:format("stop check");
					{Pid,Resp}->Resp,
								io:format("from ~p get ~p ~n",[Pid,Resp]),check(Pid)
				end
				
	end.



