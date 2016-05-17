-module (clock).
-export ([]).

start(T,F)->
	register(clock, spawn(fun()-> tick (Time,Fun) end)).

stop() -> clock !stop.

tick(T,F) ->
	receive