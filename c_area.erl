-module (c_area).

-export ([area/1]
	).

area ({})-> "what?";
area({rect,Wd,Ht}) -> Wd * Ht;
area({rd,R}) -> 3.14*R*R.