-module (c_client).
-compile (export_all).

start() ->
	connect("",2333,"1234","group1","ttt").

connect(Host,Port,HostPsw,Group,Nick) ->
	spawn (fun()->handler(Host,Port,HostPsw,Group,Nick) end).

handler(Host,Port,HostPsw,Group,Nick) ->
	process_flag(trap_exit,true),
	W = start_input(self(),Nick),
	io:format("========~p========~n",[W]),
	io:format("U R ~p ~n",[Nick]),
	start_connector(Host,Port,HostPsw),
	is_connected(W,Group,Nick).


is_connected(W,G,N) ->
		receive
			{connected,X} ->
				io:format("~p connected server",[W]),
				X ! {login,G,N},
				wait_login_resp(W,X);
			{W,destroyed} ->
				exit(dead);
			{status,S} ->
				io:format("~p is in ~p ~n",[W,S]),
				is_connected(W,G,N);
			Other->
				io:format("disconnected!: ~p~n",[Other]),
				is_connected(W,G,N)
		end.


start_connector(Host,Port,HostPsw) ->
	S =self(),
	spawn_link(fun() ->try_to_connect(S,Host,Port,HostPsw) end).

try_to_connect(Parent,Host,Port,HostPsw) ->
	case lib_chan:connect(Host,Port,chat,HostPsw,[]) of
		{error,_Why} ->
			Parent ! {status,{cannot,connect,Host,Port}},
			sleep(2000),
			try_to_connect(Parent,Host,Port,HostPsw);
		{ok,MM} ->
			lib_chan_mm:controller(MM,Parent),
			Parent ! {connected,MM},
			exit(isconnected)
	end.

sleep(T) ->
	receive
	after T ->true
	end.


wait_login_resp(W,X) ->
	receive
		{X ,ack} ->
			active(W,X);
		Other ->
			io:format("login failed : ~p ~n",[Other]),
			wait_login_resp(W,X)
	end.


active(W,X) ->
	receive
		{W,Nick,String} ->
		 X ! {relay,Nick,String},
		 active(W,X);
		{X,{msg,Addr,Pid,String}} ->
			io:format("get msg from ~p (~p) :~p ~n",[Addr,Pid,String]),
			active(W,X);
		{'EXIT',W,windowsDestroyed} ->
		 	X ! close;
		{close,X} ->
			exit(serverdown);
		Other ->
		 io:format("chat_client active nogood:~p ~n",[Other]),
		 active(W,X)
	end.


start_input(W,Nick) ->
	spawn(fun() -> input_loop(W,Nick) end).


input_loop(W,Nick) ->
	receive  
		quit -> W ! {W,destroyed};
		Other -> W ! {W,Nick,Other}
	end,
	input_loop(W,Nick).



