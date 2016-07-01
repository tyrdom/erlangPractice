-module (hwserver).
-export ([start_group_once_socket_server/]).



start_group_once_socket_server(Port) -> %多线半阻塞 socket_exmple:start_group_once_server(Port).
	{ok,Listen} = gen_tcp:listen(Port,[binary,
										{packet,4},
										{reuseaddr,true},
										{active,once}]),
	spawn(fun() -> oneservent2(Listen) end).

oneservent2(Listen) ->
	{ok,Socket} = gen_tcp:accept(Listen),
	spawn(fun() -> oneservent2(Listen) end),
	loop_once(Socket).

loop_once(Socket) ->
	receive 
		{tcp,Socket,Bin} ->
			io:format("Server received binary = ~p~n",[Bin]),
			MFA = binary_to_term(Bin),
			io:format("sever upack ~p~n",[MFA]),
			case whereis(Socket) of
				undefined ->
								startBusiness(Socket,getMod(MFA)),
								Socket ! {self(),MFA},
								loop_once(Socket);
				_Other ->		
								Socket ! {self(),MFA},
								loop_once(Socket)
			end;
		{Socket,Resp} -> 
			gen_tcp:send(Socket,term_to_binary(Resp)),
			inet:setopts(Socket,[{active,once}]),
			loop_once(Socket);
		{tcp_closed,Socket} ->
			unregister(Socket),
			io:format("server socket closed~n")
	end.


startBusiness(Name,Mod) ->
	spawn(fun()-> loop(Name,Mod,Mod:init())end).


loop(Name,Mod,State) ->
	receive
		{From,Req} ->
			{Resp,State1} = Mod:handle(Req,State),
			From ! {Name,Resp},
			loop(Name,Mod,State)
	end.
 

getMod(MFA)->
	[P|_Q] = MFA,
	P.










timereq()

handle(time)

