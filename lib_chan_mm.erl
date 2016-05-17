-module (lib_chan_mm).
-export ([loop/2,send/2,close/1,controller/2,set_trace/2,trace_with_tag/2]).

send(Pid,Term) 			-> Pid ! {send,Term}.
close(Pid)				-> Pid ! close.
controller(Pid,Pid1) 	-> Pid ! {setController,Pid1}.
set_trace(Pid,X)		-> Pid ! {trace,X}.

trace_with_tag(Pid,Tag) ->
	set_trace(Pid,{true,fun(Msg) -> io:format("MM:~p ~p~n",[Tag,Msg]) end}).

loop(Socket,Controller) ->
	process_flag(trap_exit,true),
	loop1(Socket,Controller,false).


loop1(Socket,Controller,Trace) ->
		io:format("ctrl_receiving..."),
		receive
			{tcp,Socket,Bin}->
			 	Term = binary_to_term(Bin),
			 	trace_it(Trace,{socketReceived,Term}),
			 	Controller ! {chan,self(),Term},
			 	loop1(Socket,Controller,Trace);
			
			{tcp_closed,Socket} ->
			  	trace_it(Trace,soketClosed),
			  	Controller ! {chan_closed,self()};
			
			{'EXIT',Controller,Why} ->
				trace_it(Trace,{controllingProcessExit,Why}),
				gen_tcp:close(Socket);
			
			{setController,Pid1} ->
				trace_it(Trace,{changedController,Controller}),
				loop1(Socket,Pid1,Trace);
			
			{trace,Trace1} ->
				trace_it(Trace,{setTrace,Trace1}),
				loop1(Socket,Controller,Trace1);

			close ->
				trace_it(Trace,closedByClient),
				gen_tcp:close(Socket);

			{send,Term}	->
				trace_it(Trace,{sendingMessage,Term}),
				gen_tcp:send(Socket,term_to_binary(Term)),
				loop1(Socket,Controller,Trace);
			
			Unknown ->
				io:format("lib_chan_mm:protocol error:~p~n",[Unknown]),
				loop1(Socket,Controller,Trace)
		end.


trace_it(false,_) ->void;
trace_it({true,F},M) ->F(M).


