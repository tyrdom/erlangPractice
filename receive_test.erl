-module (receive_test).
-export ([rcvtest/0]).

rcvtest()->
	
	register(test,spawn(fun() -> atest() end)).

atest () ->
	receive
		l -> io:format("~p~n",[loop]),atest ();
		_X -> io:format("~p~n",[noloop])
	end.