-module(whenTest).


-export([maxic/2,leftone/1]).




maxic(X,Y)
  when X>Y  ->X;
maxic(_X,Y) ->Y.




%去重复项函数
leftone([])->[];

leftone([P|Q])->
	[P] ++ leftone( Q -- [X|| X <- Q,X == P]).







