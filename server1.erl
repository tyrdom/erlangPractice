-module (server1).
-export ([start/2,rpc/2]).

start(Name,Mod) ->
 register(Name,
 			spawn(fun()-> loop(Name,Mod,Mod:init()) end)
 			).

 rpc(Name,Req) ->
 	Name ! {self(),Req},
 	receive
 		 {Name,Resp} ->Resp
 	end.

 loop(Name,Mod,State) ->
 	receive
 			{From,Req} ->
 				{Resp,State1} = Mod:handle(Req,State),
 				From ! {Name,Resp},
 				loop(Name,Mod,State1)
 	end.
 	
