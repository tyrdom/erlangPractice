-module (socket_exmple).
-export ([start_single_server/0,client_start/2,start_seq_server/0,start_group_server/0,start_group_recv_server/1,start_group_once_server/1]).

start_single_server()-> %单发
	{ok,Listen} = gen_tcp:listen(1111,[binary,
										{packet,4},
										{reuseaddr,true},
										{active,true}]),
	{ok,Socket} =gen_tcp:accept(Listen),
	gen_tcp:close(Listen),
	loop(Socket).

loop(Socket) ->
	receive 
		{tcp,Socket,Bin} ->
			io:format("Server received binary = ~p~n",[Bin]),
			Str = binary_to_term(Bin),
			io:format("sever upack ~p~n",[Str]),
			Reply = [reply]++Str,
			io:format("server reply ~p~n",[Reply]),
			gen_tcp:send(Socket,term_to_binary(Reply)),
			loop(Socket);
		{tcp_closed,Socket} ->
			io:format("server socket closed~n")
	end.

client_start(Port,Str) -> %socket_exmple:client_start(Port,str).
	{ok,Socket} =
		gen_tcp:connect("PC-TIANHAO",Port,[binary,{packet,4}]),
	ok = gen_tcp:send(Socket,term_to_binary(Str)),

	receive
		{tcp,Socket,Bin} ->
			io:format("client receive binary ~p~n",[Bin]),
			Val = binary_to_term(Bin),
			io:format("client reply =~p~n",[Val]),
			gen_tcp:close(Socket)
	end.


start_seq_server() -> %多次服务
		{ok,Listen} = gen_tcp:listen(2222,[binary,
										{packet,4},
										{reuseaddr,true},
										{active,true}]),
		io:format("Listen is ~p~n",[Listen]),
		seq_loop(Listen).

seq_loop(Listen) ->
	{ok,Socket} =gen_tcp:accept(Listen),
	io:format("Socket is ~p~n",[Socket]),
	loop(Socket),
	seq_loop(Listen).


start_group_server() -> %多线每个port一个服务
	{ok,Listen} = gen_tcp:listen(3333,[binary,
										{packet,4},
										{reuseaddr,true},
										{active,true}]),
	spawn_link(fun() -> oneservent(Listen) end).

oneservent(Listen) ->
	{ok,Socket} =gen_tcp:accept(Listen),
	io:format("socket is ~p~n",[Socket]),
	spawn_link(fun() -> oneservent(Listen) end),
	loop(Socket). 


start_group_recv_server(Port) -> %多线阻塞 socket_exmple:start_group_recv_server(Port).
	{ok,Listen} = gen_tcp:listen(Port,[binary,
										{packet,4},
										{reuseaddr,true},
										{active,false}]),
	spawn_link(fun() -> oneservent1(Listen) end).

oneservent1(Listen) ->
	{ok,Socket} =gen_tcp:accept(Listen),
	io:format("socket is ~p~n",[Socket]),
	spawn_link(fun() -> oneservent1(Listen) end),
	loop_recv(Socket). 

loop_recv(Socket) ->
	X =gen_tcp:recv(Socket,0),
	io:format("gen_tcp received = ~p~n",[X]),
	case X of
		{ok,Bin} ->
			io:format("Server received binary = ~p~n",[Bin]),
			Str = binary_to_term(Bin),
			io:format("sever upack ~p~n",[Str]),
			Reply = [reply]++Str,
			io:format("server reply ~p~n",[Reply]),
			gen_tcp:send(Socket,term_to_binary(Reply)),
			loop_recv(Socket);
		{error,Reason} ->
			io:format("server socket closed:~p~n",[Reason])
	end.



start_group_once_server(Port) -> %多线半阻塞 socket_exmple:start_group_once_server(Port).
	{ok,Listen} = gen_tcp:listen(Port,[binary,
										{packet,4},
										{reuseaddr,true},
										{active,once}]),
	spawn_link(fun() -> oneservent2(Listen) end).

oneservent2(Listen) ->
	{ok,Socket} =gen_tcp:accept(Listen),
	Sock =list_to_atom(Socket),
	io:format("socket is atom ~p~n",[Sock]),
	spawn_link(fun() -> oneservent2(Listen) end),
	loop_once(Socket).

loop_once(Socket) ->
	receive 
		{tcp,Socket,Bin} ->
			io:format("Server received binary = ~p~n",[Bin]),
			Str = binary_to_term(Bin),
			io:format("sever upack ~p~n",[Str]),
			Reply = [reply]++Str,
			io:format("server reply ~p~n",[Reply]),
			gen_tcp:send(Socket,term_to_binary(Reply)),
			inet:setopts(Socket,[{active,once}]),
			loop_once(Socket);
		{tcp_closed,Socket} ->
			io:format("server socket closed~n")
	end.