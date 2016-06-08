-module (gen_points).
-export ([start/2]).

start(X,N) ->
	Steps = split_steps([X],N-1),
	centerX(centerY(roll(lists:reverse(gen_plist(Steps))))).

split_steps(X,1) -> X;


split_steps([P|Q],Part) ->

	Y = 1 + crypto:rand_uniform(0,(P-Part)),

	[Y] ++ split_steps([(P - Y)|Q],Part-1) .

gen_plist([P|[]]) ->
	X =	crypto:rand_uniform(1,P+1),
    [{X,P-X},{0,0}];

gen_plist([P|Q]) ->
	[Pnow|[Plast|_Other]] = gen_plist(Q),
	[gen_a_point(P,Pnow,Plast)] ++ [Pnow|[Plast|_Other]].


rand_between(X,Y) ->
	crypto:rand_uniform(lists:min([X,Y]),(lists:max([X,Y]) + 1)).

between(X,M,N) ->
	case X =< M of
		true ->	X >= N;
			
		false -> X =< N
	end.

gen_a_point(P,Pnow,Plast) ->
	{Pmx,Pmy} = Pnow,
	{_Plx,Ply} = Plast,

	case Pmy >= Ply of
		true -> Pry = Pmy + P;
		false -> Pry = Pmy - P
	end,
	Pny = rand_between(Ply,Pry),

	case between(Pny,Ply,Pmy) of
		true ->
		Pnx = Pmx + P;
		false ->

		Pnx = Pmx + P - erlang:abs(Pny-Pmy)
	end,
	{Pnx,Pny}.


roll(L) -> 
	xroll(yroll(sroll(L))).

xroll(L) ->	
	case crypto:rand_uniform(0,2) of
		0->lists:map(fun({X,Y}) -> {-X,Y} end,L);
		1->L
	end.

yroll(L) ->
	case crypto:rand_uniform(0,2) of
		0->lists:map(fun({X,Y}) -> {X,-Y} end,L);
		1->L
	end.

sroll(L) ->
	case crypto:rand_uniform(0,2) of
		0->lists:map(fun({X,Y}) -> {Y,X} end,L);
		1->L
	end.

centerX(L) -> 
	XM = lists:min(lists:map(fun({X,_Y}) -> X end,L)),
	case XM < 0 of
		true ->lists:map(fun({X,Y}) -> {X-XM,Y} end,L);
		false -> L
	end.

centerY(L) ->
	YM = lists:min(lists:map(fun({_X,Y}) -> Y end,L)),
		case YM < 0 of
		true ->lists:map(fun({X,Y}) -> {X,Y-YM} end,L);
		false -> L
	end.
