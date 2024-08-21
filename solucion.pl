% Primera Parte: Pokemones y entrenadores

% Se conoce de qué tipo es cada pokémon, por ejemplo:
% - Pikachu es Eléctrico.
% - Squirtle es de Agua.
% - Charizard es de Fuego.
% - Blastoise es de Agua.
% - Venusaur es de tipo Planta.

% También se sabe qué entrenador tiene a cada pokémon, por ejemplo:
% - Ash tiene un Pikachu y un Charizard.
% - Brock tiene un Squirtle.

% Definir los hechos que representan esta situación y los predicados que permitan averiguar:
%  1) De qué tipos hay más de un pokemon. (en el ejemplo, agua)
%  2) Qué pokemones son libres, es decir, no los tiene ningún entrenador.
%  3) Los entrenadores que tengan pokemones de todos los tipos de pokemon existentes.

% Hechos: pokemon(Nombre, Tipo).
pokemon(pikachu, electrico).
pokemon(squirtle, agua).
pokemon(blastoise, agua).
pokemon(charizard, fuego).
pokemon(venusaur, planta).

% Hechos: tieneA(Entrenador, Entrenador).
tieneA(ash, pikachu).
tieneA(ash, charizard).
tieneA(brock, squirtle).

% Punto 1:
deQueTipoHayMasDeUnPokemon(Tipo) :-
    pokemon(Pokemon, Tipo),
    pokemon(OtroPokemon, Tipo),
    Pokemon \= OtroPokemon.

% Punto 2:
esLibre(Pokemon) :-
    pokemon(Pokemon, _),
    not(tieneA(_, Pokemon)).

% Punto 3: 
tieneDeTodosLosTipos(Entrenador) :-
    tieneA(Entrenador, _),
    forall(tipoExistente(Tipo), tieneDeEsteTipo(Entrenador, Tipo)).

tipoExistente(Tipo) :-
    pokemon(_, Tipo).

tieneDeEsteTipo(Entrenador, Tipo) :-
    tieneA(Entrenador, Pokemon),
    pokemon(Pokemon, Tipo).

% Segunda Parte: Movimientos

% Los Pokémon pueden utilizar una variedad de movimientos:
% - Físico: Se conoce su potencia.
% - Encadenado: Tiene una lista de valores, su potencia es el promedio de dicha lista.
% - Especial: Se conoce su generación y una potencia inicial. Su potencia se calcula aplicando un porcentaje de 
%   incremento (o decremento) sobre la potencia base que depende de la generación. 
%   (La primera generación es un 10% más, la segunda generación es un 20% menos, la tercera es un 50% más, 
%   las restantes no alteran la potencia inicial)

% Ejemplos de algunos movimientos pueden usar nuestro pokemones:
% - Pikachu puede usar Trueno (movimiento especial de primera generación con una potencia de 75) y 
%   Ataque rápido (movimiento encadenado que en sus 5 golpes obtiene los siguientes valores: 1 - 29 - 39 - 12 - 23)
% - Charizard puede usar Lanzallamas (movimiento especial de tercera generación con una potencia de 120) y 
%   Cuchillada (movimiento físico de potencia 65)
% - Blastoise también puede usar Ataque rápido, y 
%   Carámbano (movimiento encadenado que en sus 3 golpes obtiene los siguientes valores: 80 - 10 - 1)
% - Venusaur puede usar Rayo solar (movimiento especial de segunda generación con una potencia de 120) y 
%   también usar Cuchillada 
% - Squirtle no puede usar movimientos

% hechos: puedeUsar(Pokemon, Movimiento).
puedeUsar(pikachu, trueno).
puedeUsar(pikachu, ataqueRapido).
puedeUsar(charizard, lanzallamas).
puedeUsar(charizard, cuchillada).
puedeUsar(blastoise, ataqueRapido).
puedeUsar(blastoise, carambano).
puedeUsar(venusaur, rayoSolar).
puedeUsar(venusaur, cuchillada).

% hechos: movimientos(nombreDeMov, tipoDeMov).
movimiento(trueno, tipoEspecial(1, 75)).
movimiento(ataqueRapido, tipoEncadenado([1, 29, 39, 12, 23])).
movimiento(lanzallamas, tipoEspecial(3, 120)).
movimiento(cuchillada, tipoFisico(65)).
movimiento(carambano, tipoEncadenado([80, 10 , 1])).
movimiento(rayoSolar, tipoEspecial(2, 120)).

% 1) La peligrosidad de un Pokémon, que se calcula como la cantidad de movimientos con potencia mayor a 100.

% Punto 1: 
peligrosidadDe(Pokemon, Peligrosidad) :-
    findall(Movimiento, movimientoConPotenciaMayorA100De(Pokemon, Movimiento), ListaDeMovimientosSuperiores),
    length(ListaDeMovimientosSuperiores, Peligrosidad).

movimientoConPotenciaMayorA100De(Pokemon, Movimiento) :-
    potenciaDeUnMov(Pokemon, Movimiento, PotenciaFinal),
    PotenciaFinal > 100.

potenciaDeUnMov(Pokemon, Movimiento, PotenciaFinal) :-
    puedeUsar(Pokemon, Movimiento),
    movimiento(Movimiento, TipoDeMov),
    potenciaEnBaseTipoDeMov(TipoDeMov, PotenciaFinal).

potenciaEnBaseTipoDeMov(tipoEspecial(NroDeGeneracion, PotenciaBase), PotenciaFinal) :-
    porcentajeDe(NroDeGeneracion, Porcentaje),
    PotenciaFinal is PotenciaBase + PotenciaBase * Porcentaje.

potenciaEnBaseTipoDeMov(tipoEncadenado(ListaDeValores), PotenciaFinal) :-
    sum_list(ListaDeValores, Sumatoria),
    length(ListaDeValores, CantidadDeValores),
    PotenciaFinal is Sumatoria / CantidadDeValores.

potenciaEnBaseTipoDeMov(tipoFisico(PotenciaFinal), PotenciaFinal).

porcentajeDe(NroDeGeneracion, Porcentaje) :-
    multiplicadorPor(NroDeGeneracion, Porcentaje).

porcentaje(NroDeGeneracion, 0) :-
    not(multiplicadorPor(NroDeGeneracion, _)).

% Hechos: multiplicadorPor(Generacion, Portentaje).
multiplicadorPor(1, 0.10).
multiplicadorPor(2, -0.20).
multiplicadorPor(3, 0.50).

% Tercera Parte: Combates

% El estudio de las debilidades o fortalezas de los Pokémon es fundamental para entender cómo se desempeñarán en combate. 
% Conocerlas permite tomar decisiones estratégicas. Por ejemplo, en la región se conocen las siguientes fortalezas:

% - El tipo Planta es fuerte contra el tipo Agua.
% - El tipo Fuego es fuerte contra el tipo Planta.
% - El tipo Agua es fuerte contra el tipo Fuego.
% - El tipo Fuego es fuerte contra el tipo Eléctrico.
	
% Cuando un pokémon está en combate contra otro tiene chance de ganar si tiene algún movimiento con mayor potencia 
% que algún movimiento de su contrincante. Pero cuidado! Si el tipo de un pokémon es más fuerte que el tipo del otro pokémon, 
% su potencia se duplica. 

% Definir los predicados que permitan modelar las fortalezas
% 1) Averiguar, para un pokemon que no sea libre, a qué otros pokemones que tenga cualquier otro entrenador tiene chances de ganarle. 

% hechos: esFuerte(Tipo, OtroTipo).
esFuerte(planta, agua).
esFuerte(fuego, planta).
esFuerte(agua, fuego).
esFuerte(fuego, electrico).

% Punto 1: 
tieneChancesDeGanar(PokemonAtacante, PokemonDefensor) :-
    noSonLibres(PokemonAtacante, PokemonDefensor),
    pokemon(PokemonAtacante, TipoAtacante),
    pokemon(PokemonDefensor, TipoDefensor),
    tieneAlgunMovConPotenciaMayorA(PokemonAtacante, PokemonDefensor, PotenciaAtacante, PotenciaDefensor),
    ventajaDeTipo(TipoAtacante, TipoDefensor, PotenciaAtacante, PotenciaDefensor).

noSonLibres(PokemonAtacante, PokemonDefensor) :-
    tieneA(_, PokemonAtacante),
    tieneA(_,  PokemonDefensor).

tieneAlgunMovConPotenciaMayorA(PokemonAtacante, PokemonDefensor, PotenciaAtacante, PotenciaDefensor) :-
    potenciaDeUnMov(PokemonAtacante, _, PotenciaAtacante),
    potenciaDeUnMov(PokemonDefensor, _, PotenciaDefensor),
    PotenciaAtacante > PotenciaDefensor.

ventajaDeTipo(TipoAtacante, TipoDefensor, PotenciaAtacante, PotenciaDefensor) :-
    ventajaDeTipoParaAtacante(TipoAtacante, TipoDefensor, PotenciaAtacante, PotenciaDefensor).

ventajaDeTipo(TipoAtacante, TipoDefensor, PotenciaAtacante, PotenciaDefensor) :-
    ventajaDeTipoParaAtacante(TipoDefensor, TipoAtacante, PotenciaDefensor, PotenciaAtacante).

ventajaDeTipoParaAtacante(TipoAtacante, TipoDefensor, PotenciaAtacante, PotenciaDefensor) :-
    esFuerte(TipoAtacante, TipoDefensor),
    PotenciaAtacante * 2 > PotenciaDefensor.

ventajaDeTipoParaAtacante(TipoAtacante, TipoDefensor, PotenciaAtacante, PotenciaDefensor) :-
    not(esFuerte(TipoAtacante, TipoDefensor)),
    not(esFuerte(TipoDefensor,TipoAtacante)), 
    PotenciaAtacante > PotenciaDefensor.
