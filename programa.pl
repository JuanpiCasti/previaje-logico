comercioAdherido(iguazu, grandHotelIguazu).
comercioAdherido(iguazu, gargantaDelDiabloTour).
comercioAdherido(bariloche, aerolineas).
comercioAdherido(iguazu, aerolineas).

%factura(Persona, DetalleFactura).
%Detalles de facturas posibles:
% hotel(ComercioAdherido, ImportePagado)
% excursion(ComercioAdherido, ImportePagadoTotal, CantidadPersonas)
% vuelo(NroVuelo,NombreCompleto)

factura(estanislao, hotel(grandHotelIguazu, 2000)).
factura(antonieta, excursion(gargantaDelDiabloTour, 5000, 4)).
factura(antonieta, vuelo(1515, antonietaPerez)).


valorMaximoHotel(5000).

%registroVuelo(NroVuelo,Destino,ComercioAdherido,Pasajeros,Precio)
registroVuelo(1515, iguazu, aerolineas, [estanislaoGarcia, antonietaPerez, danielIto], 10000).



/*Punto 1*/
montoComercio(hotel(_, Monto), MontoDevolucion) :-
    MontoDevolucion is Monto * 0.5.

montoComercio(vuelo(N, _), 0) :-
    registroVuelo(N, buenosAires, _, _, _).
montoComercio(vuelo(N, _), MontoDevolucion) :-
    registroVuelo(N, _, _, _, Monto),
    MontoDevolucion is Monto * 0.3.
montoComercio(excursion(Nombre, Monto, CantidadPersonas), MontoDevolucion) :-
    comercioAdherido(_, Nombre),
    MontoDevolucion is (Monto / CantidadPersonas) * 0.8.

comercioValido(hotel(Nombre, _)) :-
    factura(_, hotel(Nombre, _)),
    comercioAdherido(_, Nombre).
comercioValido(vuelo(N, _)) :-
    factura(_, vuelo(N, _)),
    comercioAdherido(Lugar, Aerolinea),
    registroVuelo(N, Lugar, Aerolinea, _, _).
comercioValido(excursion(Nombre, _, _)) :-
    factura(_, excursion(Nombre, _, _)),
    comercioAdherido(_, Nombre).

montoDevueltoBruto(Persona, MontoDevuelto) :-
    findall(Comercio, (factura(Persona, Comercio), comercioValido(Comercio)), Comercios),
    maplist(montoComercio, Comercios, Montos),
    sumlist(Montos, MontoDevuelto).

montoDevueltoConBonoCiudades(Persona, MontoDevuelto) :-
    montoDevueltoBruto(Persona, MontoBruto),
    cantCiudadesVisitadas(Persona, Cant),
    DescuentoPorCiudadesVisitadas is Cant * 1000,
    MontoDevuelto is MontoBruto + DescuentoPorCiudadesVisitadas.

montoDevueltoConTope(Persona, MontoDevuelto) :-
    montoDevueltoConBonoCiudades(Persona, MontoPostBono),
    cumpleTope(MontoPostBono, MontoDevuelto).

montoDevueltoFinal(Persona, MontoDevuelto) :-
    montoDevueltoConTope(Persona, MontoConTope),
    penalizacionPorFacturaTrucha(Persona),
    MontoDevuelto is MontoConTope - 15000.

montoDevueltoFinal(Persona, MontoDevuelto) :- 
    montoDevueltoConTope(Persona, MontoDevuelto),
    not(penalizacionPorFacturaTrucha(Persona)).


cumpleTope(Monto, 100000) :-
    Monto > 100000.
cumpleTope(Monto, Monto).

cantCiudadesVisitadas(Persona, Cant) :-
    findall(Lugar, (factura(Persona, Comercio), lugarComercio(Comercio, Lugar)), Lugares),
    list_to_set(Lugares, LugaresUnicos),
    length(LugaresUnicos, Cant).

lugarComercio(hotel(Nombre, _), Lugar) :-
    comercioAdherido(Lugar, Nombre).
lugarComercio(excursion(Nombre, _, _), Lugar) :-
    comercioAdherido(Lugar, Nombre).
lugarComercio(vuelo(Num, _), Lugar) :-
    comercioAdherido(_, Aerolinea),
    registroVuelo(Num, Lugar, Aerolinea, _, _).

penalizacionPorFacturaTrucha(Persona) :-
    factura(Persona, hotel(Nombre,_)),
    not(comercioAdherido(_, Nombre)).
penalizacionPorFacturaTrucha(Persona) :-
    factura(Persona, excursion(Nombre,_, _)),
    not(comercioAdherido(_, Nombre)).
penalizacionPorFacturaTrucha(Persona) :-
    factura(Persona, vuelo(Numero,_)),
    registroVuelo(Numero, _, Nombre, _, _),
    not(comercioAdherido(_, Nombre)).