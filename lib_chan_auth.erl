-module (lib_chan_auth).
-export ([make_challenge/0,make_resp/2,is_resp_correct/3]).

make_challenge() ->
	random_string(25).

is_resp_correct(Challenge,Resp,Secret) ->
%需要md5验证算法模块
	case make_resp(Challenge,Secret) of
		Resp -> true;
		_Other -> false
	end.

random_string(N)->
	random_seed(),
	random_string(N,[]).

random_string(0,D)->D;

random_string(X,D)->
	random_string(X-1,[random:uniform(26)-1+$a | D]).

random_seed() ->
	{_,_,X} = erlang:timestamp(),
	{H,M,S} =time(),
	H1= H*X rem 32767,
	M1= M*X rem 32767,
	S1= S*X rem 32767,
	put(random_seed,{H1,M1,S1}).


make_resp(Challenge,Secret) ->
	lib_md5:string(Challenge++Secret).

