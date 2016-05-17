-module (c_area_server).
-export ([start/0,rpc/1,stop/0,server/0]).

start() ->register(c_area, spawn(fun() -> server() end)).

stop() -> unregister(c_area).

server()->
	receive
		{Addr,{rect,Wd,Ht}} ->
				Addr !{self(),c_area:area({rect,Wd,Ht})},
				io:format("area of rect is ~p~n from server ~p send to ~p ~n",[c_area:area({rect,Wd,Ht}),self(),Addr]);
		{Addr,{rd,R}}->
				Addr ! {self(),c_area:area({rd,R})},
				io:format("area of rd is ~p~n from server ~p send to ~p ~n",[c_area:area({rd,R}),self(),Addr]);

		{Addr,Other}->
				Addr ! {self(),error},
				io:format("error!~p~n from server ~p send to ~p ~n",[Other,self(),Addr]);

		_ -> nogood
				
%	after 3000 ->
	%	nogood 
	end,
	server().

rpc(Req) ->
	c_area ! {self(),Req},
	io:format("here ~p send ~p~n",[self(),Req]),
	receive
		{Pid,Resp}->Resp, io:format("from ~p get ~p~n",[Pid,Resp])
							
	end.