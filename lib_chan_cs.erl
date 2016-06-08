-module(lib_chan_cs).
%%cs=针对客户服务

-export([start_raw_server/4,start_raw_client/3]).
-export([stop/1]).
-export([children/1]).

start_raw_client(Host,Port,PacketLen) ->
	gen_tcp:connect(Host,Port,[binary,{active,true},{packet,PacketLen}]).

start_raw_server(Port,Fun,Max,PacketLen) ->
	Name = port_name(Port),
	case whereis(Name) of
		undefined ->
			Self = self(),
			Pid = spawn_link(fun() -> cold_start(Self,Port,Fun,Max,PacketLen) end),
			receive
				{Pid,ok} ->
					register(Name,Pid),
					{ok,self()};
				{Pid,Error} ->Error
			end;
		_Pid ->
			{error,already_started}
	end.

stop(Port) when is_integer(Port) ->
	Name = port_name(Port),
	case whereis(Name) of
			undefined ->
				not_started;
			Pid ->
				exit(Pid,kill),
				(catch unregister(Name)),
				stopped
	end.

children(Port) when is_integer(Port) ->
	port_name(Port) ! {children,self()},
	receive
		{session_server,Reply} -> Reply
	end.

port_name(Port) when is_integer(Port) ->
	list_to_atom("portServer" ++ integer_to_list(Port)).

cold_start(Master,Port,Fun,Max,PacketLen) ->
	process_flag(trap_exit,true),
	io:format("Starting a port server on ~p...~n",[Port]),
	case gen_tcp:listen(Port,
						[binary,
								{nodelay,true},
								{packet,PacketLen},
								{reuseaddr,true},
								{active,true}
						]) of
		{ok,Listen} ->
			io:format("Listening to: ~p~n",[Listen]),
			Master ! {self(),ok},
			New = start_accept(Listen,Fun),
			socket_loop(Listen,New,[],Fun,Max);
		Error -> Master ! {self(),Error}
	end.

socket_loop(Listen,New,Active,Fun,Max) ->
	ok2,
	receive
		{istarted,New} ->
			ActiveNew = [new|Active],
			possibly_start_another(false,Listen,ActiveNew,Fun,Max);
		{'EXIT',New,WHY} ->
			ActiveNew = [new|Active],
			io:format("child exit : ~p~n",[WHY]),
			possibly_start_another(false,Listen,ActiveNew,Fun,Max);
		{'EXIT',Pid,WHY2} ->
			io:format("child exit : ~p~n",[WHY2]),
			Active1 =lists:delete(Pid,Active),
			possibly_start_another(New,Listen,Active1,Fun,Max);
		{children,From} ->
			From ! {session_server,Active},
			socket_loop(Listen,New,Active,Fun,Max);
		_Other ->
			socket_loop(Listen,New,Active,Fun,Max)
	end.

possibly_start_another(New,Listen,Active,Fun,Max)
	when is_pid(New) ->
		socket_loop(Listen,New,Active,Fun,Max);

possibly_start_another(false,Listen,Active,Fun,Max) ->
	case length(Active) of
		N when N < Max ->
			New = start_accept(Listen,Fun),
			socket_loop(Listen,New,Active,Fun,Max);
		_ ->
			socket_loop(Listen,false,Active,Fun,Max)
	end.

start_accept(Listen,Fun) ->
	S = self(),
	spawn_link(fun() -> start_child(S,Listen,Fun) end).

start_child(Parent,Listen,Fun) ->
	case gen_tcp:accept(Listen) of
		{ok,Socket} ->
			Parent ! {istarted,self()},		%tell the controller
			inet:setopts(Socket,[{packet,4},
								binary,
								{nodelay,true},
								{active,true}
								]),
		process_flag(trap_exit,true),
		case (catch Fun(Socket)) of
				{'EXIT',normal} ->
					true;
				{'EXIT',Why} ->
					io:format("Port process die with exit:~p~n",[Why]),
					true;
				_Any -> true
		end
	end.

		


	

