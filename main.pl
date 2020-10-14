
:- [lib/prolongo/load].
:- use_module(mongo(mongo), []).

main :- 
    mongo:new_connection('localhost', 27017, Connection),
    mongo:get_database(Connection, 'yelp', Database),
    mongo:get_collection(Database, 'business', Collection),
    mongo:find_one(Collection, [], Result),
    print(Result),
    mongo:free_connection(Connection).

% bson:doc_get(Result, '_id', object_id(Id)).
% bson:doc_get(Result, label, Label).
% bson:doc_get(Result, priority, Priority).
% format('~w~26|~w~45|~w~n', [Id,Label,Priority]).
