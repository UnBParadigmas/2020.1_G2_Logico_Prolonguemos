
:- [lib/prolongo/load].
:- use_module(mongo(mongo), []).

main :- 
    interface(),
    State = 'SC',
    search([state-State], Docs),
    CitiesList = [],
    ord_empty(CitiesList),
    get_cities(Docs, CitiesList, Cities),
    write_ln(Cities),
    CityDict = city{},
    get_city_cat(Cities, State, CityDict, Out),
    sort_best(State, Out, Cities, 'Bakeries', 3, Result_List).

search(Query, Docs):-
    mongo:new_connection('localhost', 27017, Connection),
    mongo:get_database(Connection, 'yelp', Database),
    mongo:get_collection(Database, 'business', Collection),
    mongo:find_all(Collection, Query, [], Docs),
    mongo:free_connection(Connection).

sort_best(State, _, _, Category, 0, Final_List) :- result(State, Category, Final_List).
sort_best(State, Dict, Keys, Category, Count, Result_List) :-
    write('Category: '),
    writeln(Category),    
    Best_city = "",
    Best_star = 0.0,
    search_loop(Keys, Dict, Category, Best_star, Best_city, Result),
    append(Result_List, [Result], New_List),
    select(Result, Keys, Remaining_keys),
    New_count is Count - 1,
    sort_best(State, Dict, Remaining_keys, Category, New_count, New_List).


search_loop([], _, _, Best_star, Best_city, Result) :- Result = Best_city.
search_loop([City|Cities], Dict, Category, Best_star, Best_city, Result) :-
    get_dict(City, Dict, City_Dict),
    get_city_star(City_Dict, Category, Star),
    (
        Star > Best_star -> 
            New_Best_star = Star, New_Best_city = City;
            New_Best_star = Best_star, New_Best_city = Best_city
    ),
    search_loop(Cities, Dict, Category, New_Best_star, New_Best_city, Result).
    

result(State, Category, Result_List) :-
    format("As cidades ~w possuem o melhor estabelecimento de ~w do Estado ~w", [Result_List, Category, State]).
    


get_city_star(City, Category, Star) :-
    (get_dict(Category, City, X) -> Star = X; Star = 0).

get_city(+null, Ret) :- Ret = category{}.
get_city(Value, Ret) :-
    Ret = Value.
  

get_city_cat([], _, CityDict, Out) :- Out = CityDict.
get_city_cat([City|Cities], State, CityDict, Out):-
    search([state-State, city-City], Docs),
    CatDict = cat{},
    print_cat(Docs, CatDict, CatOut),
    put_dict(City, CityDict, CatOut, DictOut),
    get_city_cat(Cities, State, DictOut, Out).

increment(DictIn, DictOut, Key, Star) :-
    (get_dict(Key,DictIn,X) -> is(XX, X +Star) ; XX=Star),
    put_dict(Key,DictIn,XX,DictOut).

get_cities([], Cities, A) :- A = Cities.
get_cities([Doc|Docs], Cities, A):-
    bson:doc_get(Doc, city, City),
    ord_add_element(Cities, City, NewSet),    
    get_cities(Docs, NewSet, A).

print_cat([], CatDict, CatOut):- CatOut = CatDict.
print_cat([Doc|Docs], CatDict, CatOut) :-
    bson:doc_get(Doc, categories, Categories),
    bson:doc_get(Doc, stars, Stars),
    get_categories(Categories, Value),
    atomic_list_concat(SplitedCategories,', ', Value),
    add_cat_to_dict(SplitedCategories, CatDict, B, Stars),
    print_cat(Docs, B, CatOut).


add_cat_to_dict([], CatDict, B, _) :- B = CatDict.
add_cat_to_dict([Cat|Cats], CatDict, B, StarDocument):-
    increment(CatDict, NewDict, Cat, StarDocument),
    add_cat_to_dict(Cats, NewDict, B, StarDocument).


get_categories(+null, Ret) :- Ret = ''.
get_categories(Value, Ret) :-
    Ret = Value.


interface() :-
    write_ln("______Sugestoes Prolongadas________"), nl,
    write_ln("  Selecione a opcao desejada: "), nl,
    write_ln("[1] - Ver lista de cidades"),
    write_ln("[2] - Buscar por melhor restaurante").
    % read(X).

interface_entrada() :- 
    write_ln("Digite a sigla da cidade que deseja buscar").

% {
%     city1: {
%         cat1: 5,
%         cat2: 3,
%     },
%     city2: {
%         cat1: 3,
%         cat2: 4
%     }
% }
% bson:doc_get(Result, '_id', object_id(Id)).
% bson:doc_get(Result, label, Label).
% bson:doc_get(Result, priority, Priority).
% format('~w~26|~w~45|~w~n', [Id,Label,Priority]).
