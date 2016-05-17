
-module(fib).

%%
%% @doc 演示函数式语言与数学函数之间的关系
%% 
%% fib:fib(2) = 1
%% fib:fib(6) = 8
%%
%% fib:fibs(7) = [1, 1, 2, 3, 5, 8, 11]
%%
-export([
	fib/1,	
	fibs/1
]).

%%
%% @doc 参数为Num， 则返回斐波那契数列的前Num个数
%%
fibs(Num) ->
	[fib(X) || X <- lists:seq(Num, 1, -1)].

	
%%
%% @doc 求出斐波那契数列中的第N个值
%% 类似数学归纳法
%%
fib(1) -> 1;
fib(2) -> 1;
fib(N) -> fib(N-1) + fib(N-2).

