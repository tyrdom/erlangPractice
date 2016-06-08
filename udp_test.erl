-module (udp_test).
-export ([start_server/1,client/2]).

start_server(Port) -> %udp_test:start_server(Port).
	spawn_link (fun() -> server(Port) end).

server(Port) ->
	{ok,Socket} = gen_udp:open(Port,[binary]),
	io:format("server opend socket:~p~n",[Socket]),
	loop(Socket).

loop(Socket) ->
	receive
		{udp,Socket,Host,Port,Bin} =Msg ->
			io:format ("server received:~p~n",[Msg]),
			N = binary_to_term(Bin),
			Fac = afac(N),
			gen_udp:send(Socket,Host,Port,term_to_binary(Fac)),
			loop(Socket)
	end.

afac(0) -> 1;
afac(N) -> N * afac(N-1).

client(N,Port) -> %udp_test:client(N,Port).
	{ok,Socket} = gen_udp:open(0,[binary]),
	io:format("client opened socket =~p ~n",[Socket]),
	ok = gen_udp:send(Socket,"PC-TIANHAO",Port,term_to_binary(N)),

	Value =
		receive
			{udp,Socket,_,_,Bin} = Msg ->
			 	io:format("client received:~p~n",[Msg]),
			 	binary_to_term(Bin)
		after 2000 ->
			0
		end,
	ok = gen_udp:close(Socket),
	Value.
