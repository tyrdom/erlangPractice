-module(createalot).
-export([createmods/0]).


createmods()->
Mods = [createalot,fib,whenTest,c_area,hello,c_area_server,atimer,chains,exit_test,kvserver,c_client,pid_test,receive_test,lib_chan,lib_chan_cs,lib_chan_mm,lib_chan_auth],
 create(Mods).

create([])->done;

create([P|Q])
->
	c:c(P),
	create(Q).
