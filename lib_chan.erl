-module(lib_chan).
-export([cast/2,start_server/0,
	%start_server/1,
		connect/5,disconnect/1,rpc/2]).
-import(lists,[map/2,member/2,foreach/2]).
-import(lib_chan_mm,[send/2,close/1]).

%配置文件地址
start_server() ->
%	case os:getenv("HOME") of
%		false -> exit({ebadEnv,"HOME"});
%		Some ->
%		 start_server(Some ++ "/lib_chan.conf")
%	end.
%开始服务

%{port,2233},
%{service,math,password,"qwerty",mfa,mod_math,run,[]}.

%start_server(ConfigFile) ->
%	io:format("lib_chan start:~p~n",[ConfigFile]),
%	case file:consult(ConfigFile) of %读取配置文件
%		{ok,ConfigData}->
			io:format("ConfigData=~p~p~n",[{port,2233},
											{service,math,password,"qwerty",mfa,mod_math,run,[]}]),
		%		case  check_terms([{port,2233},
							%		{service,math,password,"qwerty",mfa,mod_math,run,[]}]) of %检查配置，是否格式正常
			%		[]->
						start_server_step1([{port,2233},
									{service,math,password,"qwerty",mfa,mod_math,run,[]}]). %没有报错执行下一步
		%			Error->
		%			 exit(nogoodConfig,Error) %报错
%				end
		%{error,Why} -> %转换出错
	%		exit(nogoodConfig,Why)
%	end.

check_terms(ConfigData) -> %格式检查
	L = map(fun(X) -> check_term(X) end, ConfigData), %遍历读取的文件检查
	[X||{error,X} <- L].


check_term({port,P}) %检查端口号是不是数字
	when is_integer(P) ->ok;
check_term({service,_,password,_,mfa,_,_,_}) ->ok; %检查其他配置是不是符合格式

check_term(Other) ->
	{error,{nogoodConfigTerm,Other}}.


start_server_step1(ConfigData) ->
	ok,
	register(lib_chan,spawn(fun() -> start_server_step2(ConfigData) end)). %注册进程，进入第二步

start_server_step2(ConfigData) ->
	[Port] = [P|| {port,P} <- ConfigData], %解析配置，获得端口号
	start_port_server(Port,ConfigData).

start_port_server(Port,ConfigData) -> %开启服务：去看chan_cs
	lib_chan_cs:start_raw_server(Port,
								 fun(Socket) ->
												start_port_instance(Socket,ConfigData) 
								 end,
								 100,
								 4).

start_port_instance(Socket,ConfigData) -> % 开启连接进程：erl的端口配置解析服务

	MM=self(),
	Controller = spawn_link(fun() -> start_erl_port_server(MM,ConfigData) end),
	lib_chan_mm:loop(Socket,Controller).  %去看chan_mm


start_erl_port_server(MM,ConfigData) ->   %连接的进程：erl端口
	receive
		{chan,MM,{startService,Mod,ArgC}} ->  %收到此格式消息,确认是自己的消息
			case get_service_definition(Mod,ConfigData) of  %验证和转换消息格式
					{yes,Pwd,Mfa} ->  %从ConfigData提出Pwd密码和MFA
						case Pwd of
							none -> send(MM,ack), %密码配置为none
									really_start(MM,ArgC,Mfa); %尼玛现在才真开始
							_Other ->
								do_authentication (Pwd,MM,ArgC,Mfa) %验证密码等一系列东西先
						end;
					no ->
						io:format("sending bad service ~n"),
						send(MM,badService),
						close(MM)
			end;
		Any ->
			io:format("*** Erl port server got some ??? ~p ~p~n",[MM,Any]),
			exit({form_error,Any})
	end.


do_authentication(Pwd,MM,ArgC,Mfa) ->   %验证密码等一系列东西
	C= lib_chan_auth:make_challenge(),  %看lib_chan_auth
	send(MM,{challenge,C}), %发送给(MM类进程认证消息)
	receive
		{chan,MM,{resp,R}} -> %收到回复
			case lib_chan_auth:is_resp_correct(C,R,Pwd) of %验证回复正确
				true ->
					send (MM,ack), %发送给管理进程ack
					really_start(MM,ArgC,Mfa); %尼玛现在才真开始
				false ->
					send (MM,passwordNotRight),%验证没过，密码错误，关闭主进程
					close(MM)
			end
	end.


really_start(MM,ArgC,{M,F,A}) ->
	case ( catch apply(M,F,[MM,ArgC,A])) of %在纠错模式下执行业务逻辑的某模块的某一个函数，这个根据参数来，错了就退出发错误消息
			{'EXIT',normal} ->
				true;
			{'EXIT',Why} ->
				io:format("server error:~p~n" ,[Why]);
			Why ->
				io:format("server error should die was:~p~n",Why)
	end.

get_service_definition(Mod,[{service,Mod,password,Pwd,mfa,M,F,A}|_X]) ->
								{yes,Pwd,{M,F,A}};

get_service_definition(Name,[_X|T]) ->
		get_service_definition(Name,T);

get_service_definition(_X,[]) -> no.


connect(Host,Port,Service,Secret,ArgC) ->			%可供使用的连接函数，开启一个连接进程
	S = self(),
	MM = spawn(fun() -> a_connect(S,Host,Port) end),
	receive
		{MM,ok} ->
			case auth(MM,Service,Secret,ArgC) of
				ok -> {ok,MM};
				Errors ->Errors
			end;

		{MM,Error} ->Error		
	end.

a_connect(Parent,Host,Port) ->						%开启的链接进程
	case lib_chan_cs:start_raw_client(Host,Port,4) of %看lib_chan_cs
		{ok,Socket} ->
			Parent ! {self(),ok},
			lib_chan_mm:loop(Socket,Parent);%看lib_chan_mm循环
		Error-> %不ok都报错
			Parent !{self(),Error}
	end.

auth(MM,Service,Secret,ArgC) -> %调用连接的认证	
	send(MM,{startService,Service,ArgC}),
	receive
		{chan,MM,ack} ->%收到来的ack就ok
			ok;
		{chan,MM,{challenge,C}} ->
			R= lib_chan_auth:make_resp(C,Secret), %lib_chan_auth
			send(MM,{response,R}),
			receive
				{chan,MM,ack} ->
					ok;					%验证返回通过
				{chan,MM,authfail} ->
					wait_close(MM),
					{error,authfail};
				Other ->
					{error,Other}
			end;
		{chan,MM,badService} ->
			wait_close(MM),
			{error,badService};
		Other ->
			{error,Other}
	end.

disconnect(MM) -> close(MM).

rpc(MM,Q) ->
	send(MM,Q),
	receive
		{chan,MM,Reply}->Reply
	end.

cast(MM,Q) -> send(MM,Q).





wait_close(MM) ->
	receive
		{chan_closed,MM} -> true
	after 5000 ->
		io:format("error lib_chan~n"),true
	end.




