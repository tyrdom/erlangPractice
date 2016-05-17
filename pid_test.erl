-module (pid_test).
-export ([start/2]).


start(X,Y)
 ->
 	NN = self(),
 	io:format("start pid is ~p~n",[NN]),
 	fixed(X,Y,fun(Z,P) -> struc(Z,P)end).



 %	lib_chan_cs:start_raw_server(Port,
%								 fun(Socket) ->
	%											start_port_instance(Socket,ConfigData) 
%								 end,
%								 100,
%								 4).

struc(Z,P) ->MM=self(),
			
			B=Z*4*P,

			io:format("now pid is ~p ~p ~n",[MM,B]).

fixed(X,Y,F) ->
	LL=self(),
	spawn(fun() -> fixed2(LL,X,Y,F) end).


fixed2(LL,X,Y,F) ->
	io:format("now pid is ~p ~p ~n",[LL,F]),
	F(X,Y).






