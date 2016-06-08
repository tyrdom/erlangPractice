-module (lib_md5).
-export ([string/1]).

string(X) ->
    binary_to_list(crypto:hash(md5,X)).