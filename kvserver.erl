-module (kvserver).
-export([start/0 ,store/2 ,lookup/1]).

start()-> register (kvserver,spawn(fun()->loop() end) ).

store(K,V) -> rq({save,K,V}).

lookup(K) -> rq({lookup,K}).

rq(X) ->
	kvserver ! {self(),X},
	receive 
		{kvserver ,Rsp} -> Rsp
	end.

loop()->
	receive
		{Addr,{save ,K,V}} ->
			put(K,{ok,V}),
			Addr ! {kvserver,saved};
		{Addr,{lookup,K}} -> 
			Addr ! {kvserver,get(K)}
	end,
	loop().

