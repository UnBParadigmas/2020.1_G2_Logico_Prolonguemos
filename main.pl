
:- [lib/prolongo/load].
:- use_module(mongo(mongo), []).

main :- 
    mongo:new_connection('localhost', 27017, Connection),
    mongo:get_database(Connection, 'yelp', Database),
    mongo:get_collection(Database, 'business', Collection),
    mongo:find_all(
        Collection,
        [city-'Huntersville'],
        [],
        Docs
    ),
    print_cat(Docs),
    mongo:free_connection(Connection).



print_cat([]).
print_cat([Doc|Docs]) :-
    bson:doc_get(Doc, categories, Categories),
    get_categories(Categories, Value),
    atomic_list_concat(SplitedCategories,',', Value),
    writeln(SplitedCategories),
    print_cat(Docs).

get_categories(+null, Ret) :- Ret = ''.
get_categories(Value, Ret) :- 
    Ret = Value.



% bson:doc_get(Result, '_id', object_id(Id)).
% bson:doc_get(Result, label, Label).
% bson:doc_get(Result, priority, Priority).
% format('~w~26|~w~45|~w~n', [Id,Label,Priority]).
