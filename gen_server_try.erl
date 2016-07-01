-module (gen_server_try).

-behaviour (gen_server).
-define(SERVER,?MODULE).
-export ([start/0,stop/0,new_ac/1,savemoney/2,takemoney/2,lookmoney/1,init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2,code_change/3]).

start() -> gen_server:start_link({local,?SERVER},?MODULE,[],[{debug,[trace]}]).  %gen_server_try:start().
stop() -> gen_server:call(?MODULE,stop).          %gen_server_try:start().

new_ac(Who) ->gen_server:call(?MODULE,{new,Who}). %gen_server_try:new_ac(Who).
savemoney(Who,Num) -> gen_server:call (?MODULE,{save,Who,Num}).  %gen_server_try:savemoney(Who,Num).
takemoney(Who,Num) -> gen_server:call (?MODULE,{take,Who,Num}).   %gen_server_try:takemoney(Who,Num).
lookmoney(Who) -> gen_server:call (?MODULE,{lookup,Who}).           %gen_server_try:lookmoney(Who).


init([]) ->{ok,ets:new(?MODULE,[])}.

handle_call({new,Who},_From,Table) ->
	Reply = 
	case ets:lookup(Table,Who) of
		[] -> ets:insert(Table,{Who,0}),
			  {welcome,Who};
		[_] -> {Who,u_already_r_a_customer}
	end,
	{reply,Reply,Table};

handle_call({save,Who,Num},_From,Table) ->
	Reply = case ets:lookup(Table,Who) of
		[] -> {u_r_not_a_customer};
		[{Who,Money}] ->
			NewMoney = Money + Num,
			ets:insert(Table,{Who,NewMoney}),
			{Who,your_money_is,NewMoney}
		end,
	{reply,Reply,Table};

handle_call({take,Who,Num},_From,Table) ->
	Reply = case ets:lookup(Table,Who) of
		[] -> {u_r_not_a_customer};
		[{Who,Money}] when Num =< Money ->
			NewMoney = Money - Num,
			ets:insert(Table,{Who,NewMoney}),
			{Who,your_money_is,NewMoney};
		[{Who,Money}] ->
			{your_only_have,Money}
		end,
	{reply,Reply,Table};

handle_call({lookup,Who},_From,Table) ->
	Reply = case ets:lookup(Table,Who) of
			[] -> {u_r_not_a_customer};
			[{Who,Money}] ->
				{Who,your_money_is,Money}
	end,
	{reply,Reply,Table};

handle_call(stop,_From,Table) -> {stop,normal,stoped,Table}.
handle_cast(_Msg,State) -> {noreply,State}.
handle_info(_Info,State) -> {noreply,State}.
terminate(_Reason,_State) -> ok.
code_change(_OldVsn,State,_Extra) -> {ok,State}.