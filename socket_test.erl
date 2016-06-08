-module (socket_test).
-compile(export_all).


client_start(Port,Str) -> %socket_test:client_start(4444,str).
	{ok,Socket} =
		gen_tcp:connect("PC-TIANHAO",Port,[binary,
						{packet,raw},
											 {active, true}]),
	ok = gen_tcp:send(Socket,term_to_binary(Str)),

	receive
		{tcp,Socket,Bin} ->
			Val = binary_to_term(Bin),
			io:format("client reply =~p~n",[Val]),
			gen_tcp:close(Socket);
		Other ->
			io:format("recv: ~p~n", [Other])
	end.


start_group_recv_server(Port) -> %多线阻塞 socket_test:start_group_recv_server().
	{ok,Listen} = gen_tcp:listen(Port,[binary,
										{packet,raw},
										{reuseaddr,true},
										{active,false}]),
	spawn_link(?MODULE, loop, [Listen]).

loop(Listen) ->
	{ok,Socket} =gen_tcp:accept(Listen),
	spawn_link(?MODULE, loop_recv, [Socket]),
	loop(Listen).

loop_recv(Socket) ->
	case gen_tcp:recv(Socket,4) of
		{ok,Bin} ->

			%Str = binary_to_term(Bin),
			Str=Bin,
			io:format("sever upack ~p~n",[Str]),
			gen_tcp:send(Socket,term_to_binary(Str)),
			loop_recv(Socket);
		{error,closed} ->
			io:format("server socket closed~n");
		Other ->
			io:format("recv: ~p~n", [Other])
	end.
