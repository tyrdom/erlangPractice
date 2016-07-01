-module(createalot).
-export([createmods/0]).


createmods()-> %createalot:createmods().
Mods = [createalot,fib,whenTest,c_area,hello,c_area_server,atimer,chains,exit_test,kvserver,c_client,pid_test,receive_test,lib_chan,lib_chan_cs,lib_chan_mm,lib_chan_auth
,lib_md5,gen_points,socket_exmple,ets_test,socket_test,udp_test,gen_server_try,mnesia_try,gen_server_try_with_mnesia],
 create(Mods).
 
create([])->done;

create([P|Q])
->
	c:c(P),
	create(Q).
