-module (gen_server_try_with_mnesia).
-record (bank, {user,money}).
-include_lib("stdlib/include/qlc.hrl").
-behaviour (gen_server).
-define(SERVER,?MODULE).
-export ([start/0,stop/0,new_ac/1,savemoney/2,takemoney/2,lookmoney/1,init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2,code_change/3]).

start() -> gen_server:start_link({local,?SERVER},?MODULE,[],[{debug,[trace]}]).  %gen_server_try_with_mnesia:start().
stop() -> gen_server:call(?MODULE,stop).          %gen_server_try_with_mnesia:stop().

new_ac(Who) ->gen_server:call(?MODULE,{new,Who}). %gen_server_try_with_mnesia:new_ac(Who).
savemoney(Who,Num) -> gen_server:call (?MODULE,{save,Who,Num}).  %gen_server_try_with_mnesia:savemoney(Who,Num).
takemoney(Who,Num) -> gen_server:call (?MODULE,{take,Who,Num}).   %gen_server_try_with_mnesia:takemoney(Who,Num).
lookmoney(Who) -> gen_server:call (?MODULE,{lookup,Who}).           %gen_server_try_with_mnesia:lookmoney(Who).


init([]) ->{mnesia:start(),bank}.

handle_call({new,Who},_From,Table) ->
	Sel = mnesia_try:do(qlc:q([X || X<- mnesia:table(Table),X # bank.user =:= Who])),
	io:format("bank______~p",[Sel]),
	Reply = 
	case Sel of
		[] -> Row = #bank {user=Who,money=0},
				F = fun() ->mnesia:write(Row) end,
					mnesia:transaction(F),
				 
			  {welcome,Who};
		[_] -> {Who,u_already_r_a_customer}
	end,
	{reply,Reply,Table};

handle_call({save,Who,Num},_From,Table) ->
	Reply = case mnesia_try:do(qlc:q([X || X<- mnesia:table(Table),X # bank.user =:= Who])) of
		[] -> {u_r_not_a_customer};
		[{bank,Who,Money}] ->
			NewMoney = Money + Num,
			Row = #bank {user = Who,money = NewMoney },
			F = fun() ->mnesia:write(Row) end,
					mnesia:transaction(F),
			{Who,your_money_is,NewMoney}
		end,
	{reply,Reply,Table};

handle_call({take,Who,Num},_From,Table) ->
	Reply = case mnesia_try:do(qlc:q([X || X<- mnesia:table(Table),X # bank.user =:= Who])) of
		[] -> {u_r_not_a_customer};
		[{bank,Who,Money}] when Num =< Money ->
			NewMoney = Money - Num,
			Row = #bank {user=Who,money=NewMoney},
			F = fun() ->mnesia:write(Row) end,
					mnesia:transaction(F),
			{Who,your_money_is,NewMoney};
		[{bank,Who,Money}] ->
			{your_only_have,Money}
		end,
	{reply,Reply,Table};

handle_call({lookup,Who},_From,Table) ->
	Sel= mnesia_try:do(qlc:q([X || X<- mnesia:table(Table),X # bank.user =:= Who])),
	io:format("bank______~p",[Sel]),
	Reply = case Sel of
			[] -> {u_r_not_a_customer};
			[{bank,Who,Money}] ->
				{Who,your_money_is,Money}
	end,
	{reply,Reply,Table};

handle_call(stop,_From,Table) -> {stop,normal,mnesia:stop(),Table}.
handle_cast(_Msg,State) -> {noreply,State}.
handle_info(_Info,State) -> {noreply,State}.
terminate(_Reason,_State) -> ok.
code_change(_OldVsn,State,_Extra) -> {ok,State}.






