unit LO_HashAbierto;

interface

  uses
  LO_ListasDobles, Formatos, SysUtils;


  {HASH ABIERTO:
    Esta libreria posee como base a ListaDoble. Podria considerarse una ampliacion de la misma.

    Al momento de crear la ListaDoble se insertaran una cantidad de registros equivalente a
   MaxHash.

    Las operaciones de escritura (Agregar, Modificar y Eliminar) invocaran solo una funcion de
   escritura de ListaDoble: ModificarListaDoble.

    Las coliciones se resuelven insertando los nuevos registros a en posiciones disponibles,
   obtenidas por la funcion BuscarHashCerrado.

    Una posicion disponible esta definida por tener en el campo Clave el valor "ClaveNula".
   Esto puede suceder porque:
      *Nunca se ha ingresado un registro en esa posicion.
      *Un registro fue eliminado previamente en esa posicion.
    }
  Const

    {
    Hash: se usara el campo Clave para obtener un valor que oscilara entre un minimo y un maximo:

      *MinHash: el caracter minimo imprimible de la tabla ASCII es el 32: el espacio en blanco.
      Originalmente, el valor minimo de la FuncionHash seria 128 (32*4) pero, para facilitar
      la operacion al valor final original de FuncionHash se le restara 128.
      Esto significaria que el valor minimo que puede devolver FuncionHash seria 0.

      *MaxHash: el caracter maximo imprimible de la tabla ASCII es el 255: el espacio sin separacion.
      Originalmente, el valor maximo de la FuncionHash seria 1020 (255*4) pero, para facilitar
      la operacion al valor final original de FuncionHash se le restara 128.
      Esto significaria que el valor maximo que puede devolver FuncionHash seria 892.

    }

    MinHash = 0;
    MaxHash = 892;

    _POSNULA = LO_ListasDobles._POSNULA;
    _CLAVENULA = LO_ListasDobles._CLAVENULA;
    
  Type
    TipoHash = string[3];

    TipoPos = LO_ListasDobles.TipoPos;

    TipoClave = LO_ListasDobles.TipoClave;

    TipoDatosAbierto = TipoDatosDoble;

    TipoControlAbierto = TipoControlDoble;

    TipoHashAbierto = TipoListaDoble;

    Procedure CrearHashAbierto(var ME:TipoHashAbierto; Nombre,Ruta:string);
    Procedure DestruirHashAbierto(var ME:TipoHashAbierto);
    Procedure AbrirHashAbierto(var ME:TipoHashAbierto);
    Procedure CerrarHashAbierto(var ME:TipoHashAbierto);

    Function BuscarHashAbierto(var ME:TipoHashAbierto; Clave:TipoClave; var Pos:TipoPos):Boolean;
    Procedure CapturarHashAbierto(var ME:TipoHashAbierto; Pos:TipoPos; var Reg:TipoDatosAbierto);
    Procedure AgregarHashAbierto(var ME:TipoHashAbierto; Pos:TipoPos; Reg:TipoDatosAbierto);
    Procedure ModificarHashAbierto(var ME:TipoHashAbierto; Pos:TipoPos; Reg:TipoDatosAbierto);
    Procedure EliminarHashAbierto(var ME:TipoHashAbierto; Pos:TipoPos);

    Function PrimeroHashAbierto(var ME:TipoHashAbierto):TipoPos;
    Function AnteriorHashAbierto(var ME:TipoHashAbierto; Pos:TipoPos):TipoPos;
    Function ProximoHashAbierto(var ME:TipoHashAbierto; Pos:TipoPos):TipoPos;
    Function UltimoHashAbierto(var ME:TipoHashAbierto):TipoPos;
    Function HashAbiertoVacio(var ME:TipoHashAbierto):boolean;


    //Procedimientos para pruebas

    //Procedure TodoVacante(var ME:TipoHashAbierto);
    //Procedure SinVacantes(var ME:TipoHashAbierto);


implementation

  Function FuncionHash(Clave:TipoClave):TipoHash;
  {*FuncionHash:
        -El string de 8 caracteres se dividira en 4 pares de 2 caracteres.
        -Cada par vera sus caracteres convertidos a su valor ASCII y.
        -Estos dos valores (por par) se sumaran y luego dividiran por dos, dando como
        resultados un numero que puede ser conciderado el promedio de esta operacion.
        -Estos promedios seran almacenados en 4 variables de tipo integer, cada uno.
        -Luego se sumaran los valores de las 4 variables.
        -Finalmente, el resultado sera restado por 128 (consultar MinHash y MaxHash, en el
        apartado de Interface, Const, para mas informacion).
        -El resultado sera enviado como valor/resultado de la FuncionHash.}
  var
    num1,num2,num3,num4:integer;

  begin
    Clave:=PreEspaciosString(8,Clave);
    num1:=( ord(Clave[1]) + ord(Clave[2]) ) div 2;
    num2:=( ord(Clave[3]) + ord(Clave[4]) ) div 2;
    num3:=( ord(Clave[5]) + ord(Clave[6]) ) div 2;
    num4:=( ord(Clave[7]) + ord(Clave[8]) ) div 2;
    FuncionHash:=PreCerosInteger(3,(num1 + num2 + num3 + num4) - 128);
  end;

{------------------------------------------------------------------------------}

  Function BusquedaLineal(var ME:TipoHashAbierto; var Pos:TipoPos; Clave:TipoClave):Boolean;
  {Si la busqueda cuadratica no puede encontrar el registro buscado, entonces se utilzara
  un criterio de busqueda lineal para recorrer el archivo desde el primer registro hasta
  el ultimo.}
  var
    Reg:TipoDatosAbierto;
    Encont:boolean;
    posDisp:TipoPos;

  begin
    Encont:=False;
    posDisp:=PosNula;
    //El primer registro de la lista indice posee la posicion del primero de la lista de datos
    Pos:=PrimeroListaDoble(ME);

    While (Pos <> PosNula) and not(Encont)
    do begin

      //Capturo el registro de datos
      CapturarListaDoble(ME,Pos,Reg);
      CapturarListaDoble(ME,Reg.InfoPos,Reg);

      //Si la posicion esta disponible para ser utilizada
      if (posDisp = PosNula) and (Reg.Clave = ClaveNula)
      then posDisp := Pos;

      //Si es el registro buscado
      if Reg.Clave = Clave
      then Encont:=True
      else Pos:=ProximoListaDoble(ME,Pos);

    end;

    //Si no se encontro el registro pero si una posicion donde insertarlo.
    if not Encont
    then Pos:=posDisp;

    {Si Pos = PosNula, significa que el archivo esta lleno. Solo se puede ingresar
    nuevos registros eliminado otros primero}
    BusquedaLineal:=Encont;
  end;

{------------------------------------------------------------------------------}

  Function BusquedaCuadratica(var ME:TipoHashAbierto; var Pos:TipoPos; Clave:TipoClave):Boolean;
  {Para la funcion BusquedaCuadratica se tomara en cuenta que la posicion debida del registro
  en el archivo esta ocupado por otro registro o esta disponible para escribir, por lo que se
  procedera a buscar el registro con este nuevo criterio de busqueda.

   El objetivo de esta funcion es dar con la posicion del registro con un criterio con altas
  probabilidades de reducir el tiempo de busqueda que conllevaria la busqueda lineal del metodo
  BuscarListaDoble. Si embargo, en caso de no poder encontrar el registro con este metodo, se invocara a la
  funcion BuscarListaDoble;

   A su vez, si se encuentran posiciones disponibles para su escritura pero no el registro
  buscado, entonces se devolvera la primera posicion disponible para dar alta a un registro
  usando el parametro por referencia Pos (solo si Clave tiene como valor _CLAVENULA).}

  var
    limiteInicio,limiteFin:boolean;
    i,cont:integer;
    posAnt,posSig,PosDisp:TipoPos;
    Reg:TipoDatosAbierto;
    Hash:integer;

  begin

    //¿Estoy en el primer registro?
    if Pos = PrimeroListaDoble(ME)
    then limiteInicio:=true //No buscare posiciones menores a Hash
    else limiteInicio:=false;

    //¿Estoy en el ultimo registro?
    if Pos = UltimoListaDoble(ME)
    then limiteFin:=true //No buscare posiciones mayores a Hash
    else limiteFin:=false;

    Hash:=strtoint(FuncionHash(Clave));
    cont:=0;

    posAnt:=Pos;
    posSig:=Pos;
    Pos:=_POSNULA; {Ya no necesito conservar su valor, pero se usara la variable Pos
    tanto como condicion para el ciclo While como para guardar la posicion del registro
    buscado, si este es encontrado}
    PosDisp:=_POSNULA;

    while ((not(limiteInicio)) or (not(limiteFin))) and (Pos = _POSNULA)
    do begin

      cont:=cont + 1;

      if not(limiteInicio)
      //Si la ID futura es menor a MinHash
      then if (Hash - sqr(cont)) < (MinHash)

        then limiteInicio:=true  //Ya no busco claves menores

        else begin

          //Se hace uso repetitivo de la funcion AnteriorListaDoble.
          if cont = 1
          then posAnt:=AnteriorListaDoble(ME,posAnt)
          else for i := sqr(cont - 1) to (sqr(cont) - 1)
            do posAnt:=AnteriorListaDoble(ME,posAnt);
          {Ejemplos de la sentencia For, en base al valor de la variable "cont":

            cont=1; for i = 1 to 0 (para este caso existe la condicion previa al For, ya que
            resultaria en un error. 1 movimiento, 1 + 0 = 1, 1 posicion desde Pos)

            cont=2; for i = 1 to 3  (3 movimientos, 3 + 1 = 4, 4 posiciones desde Pos)

            cont=3; for i = 4 to 8  (5 movimientos, 5 + 4 = 9, 9  posiciones desde Pos)

            cont=4; for i = 9 to 15 (7 movimientos, 7 + 9 = 16, 16 posiciones desde Pos)

            Las condiciones de inicio y final del For sirven para optimizar la eficiencia
           del codigo: en lugar de trasladarse cont^2 posiciones desde Pos en cada ciclo,
           se continua desde la ultima posicion asignada a posAnt.}

          //Capturo el registro de datos
          CapturarListaDoble(ME,posAnt,Reg);
          CapturarListaDoble(ME,Reg.InfoPos,Reg);

          //¿Es el registro buscado?
          if (Reg.Clave = Clave)
          then Pos:=posAnt //Guardo su posicion en Pos
          else if (Reg.Clave = ClaveNula) and (posDisp = PosNula)
            {Se almacenara la primera posicion disponible encontrada para que, en caso de
            no encontrar la Clave buscada, le pueda entregar una posicion donde escribir}
            then posDisp:=posAnt;


        end;

      if not(limiteFin) and (Pos = _POSNULA)
      //Si la clave futura es mayor a la clave mas grande posible del Hash
      then if (Hash + sqr(cont)) > (MaxHash)

        then limiteFin:=true  //Ya no busco claves mayores

        else begin

          //Se hace uso repetitivo de la funcion PosteriorListaDoble.
          if cont = 1
          then posSig:=ProximoListaDoble(ME,posSig)
          else for i := sqr(cont - 1) to (sqr(cont) - 1)
            do posSig:=ProximoListaDoble(ME,posSig);
          {Ejemplos de la sentencia For, en base al valor de la variable "cont":

            cont=1; for i = 1 to 0 (para este caso existe la condicion previa al For, ya que
            resultaria en un error. 1 movimiento, 1 + 0 = 1, 1 posicion desde Pos)

            cont=2; for i = 1 to 3  (3 movimientos, 3 + 1 = 4, 4 posiciones desde Pos)

            cont=3; for i = 4 to 8  (5 movimientos, 5 + 4 = 9, 9  posiciones desde Pos)

            cont=4; for i = 9 to 15 (7 movimientos, 7 + 9 = 16, 16 posiciones desde Pos)

            Las condiciones de inicio y final del For sirven para optimizar la eficiencia
           del codigo: en lugar de trasladarse cont^2 posiciones desde Pos en cada ciclo,
           se continua desde la ultima posicion asignada a posSig.}

          //Capturo el registro de datos
          CapturarListaDoble(ME,posSig,Reg);
          CapturarListaDoble(ME,Reg.InfoPos,Reg);

          //¿Es el registro buscado?
          if (Reg.Clave = Clave)
          then Pos:=posSig //Guardo su posicion en Pos
          else if (Reg.Clave = ClaveNula) and (posDisp = PosNula)
            {Se almacenara la primera posicion disponible encontrada para que, en caso de
            no encontrar la Clave buscada, le pueda entregar una posicion donde escribir}
            then posDisp:=posSig;

        end;

    end;

    if Pos <> PosNula //Si la busqueda cuadratica lo encontro
    then BusquedaCuadratica:= True //Se devuelve True
    else if BusquedaLineal(ME,Pos,Clave) //Si fallo, se invoca a BuscarListaDoble

      then BusquedaCuadratica:= True //Si BuscarListaDoble encontro el registro
      else begin

        {Si no se encontro el registro, pero la busqueda cuadratica si una
        posicion disponible para insertalo}
        if posDisp <> PosNula
        then Pos:=posDisp;

         {Si el valor de Pos = _POSNULA, esto significaria que el archivo esta lleno: solo se
         podran obtener nuevas posiciones disponibles si se eliminan registros ya existentes}
        BusquedaCuadratica:= False;

      end;

  end;

{------------------------------------------------------------------------------}


  Procedure CrearHashAbierto(var ME:TipoHashAbierto; Nombre,Ruta:string);
  var
    i:Integer;
    RegD,RegI:TipoDatosAbierto;
    RCD,RCI:TipoControlAbierto;
    Pos:TipoPos;

  begin
    //Se crea y abre la ListaDoble
    CrearListaDoble(ME,Nombre,Ruta);
    AbrirListaDoble(ME);

    {Genero dos listas: una para el indice (RCI, cuya Clave sera el resultado de
    FuncionHash) y otra para los datos (RCD, que contendra la Clave normal).}
    RCI:=ObtenerControlListaDoble(ME);
    if RCI.Primero = _POSNULA //Si no creo la libreria HashAbierto
    then begin
      GenerarNuevaListaDoble(ME,RCD);

      //Valores por defecto para todos los registros de datos
      RegD.Clave:=ClaveNula;
      RegD.InfoPos:=PosNula;

      for i := MinHash to MaxHash  //Se crearan una cantidad de registros equivalente a MaxHash
      do begin
        //Asigno las claves a los registros del indice
        RegI.Clave:=PreCerosInteger(3,i);

        //Inicio la lista de datos, agrego el registro de datos y obtengo el registro de control
        IniciarListaDobleExistente(ME,RCD);
        if not(BuscarListaDoble(ME,RegI.Clave,Pos))
        then AgregarListaDoble(ME,RegD,Pos);
        RCD:=ObtenerControlListaDoble(ME);

        //Asigno la posicion del registro de datos al campo InfoPos de homonimo en el indice
        RegI.InfoPos:=UltimoListaDoble(ME);

        //Inicio la lista indice, agrego el registro de datos y obtengo el registro de control
        IniciarListaDobleExistente(ME,RCI);
        if not(BuscarListaDoble(ME,RegI.Clave,Pos))
        then AgregarListaDoble(ME,RegI,Pos);
        RCI:=ObtenerControlListaDoble(ME);

        {No es necesario conservar el registro de control de la lista de datos,
        ya que las posiciones de cada registro en ella estaran guardados en el campo
        InfoPos de su registro homonimo en la lista indice.}
      end;
      
    end;
    CerrarListaDoble(ME);
  end;

{------------------------------------------------------------------------------}

  Procedure DestruirHashAbierto(var ME:TipoHashAbierto);

  begin
    DestruirListaDoble(ME);
  end;

{------------------------------------------------------------------------------}

  Procedure AbrirHashAbierto(var ME:TipoHashAbierto);

  begin
    AbrirListaDoble(ME);
  end;

{------------------------------------------------------------------------------}

  Procedure CerrarHashAbierto(var ME:TipoHashAbierto);

  begin
    CerrarListaDoble(ME);
  end;

{------------------------------------------------------------------------------}

  Function BuscarHashAbierto(var ME:TipoHashAbierto; Clave:TipoClave; var Pos:TipoPos):Boolean;
  {Se pueden dar tres resultados distintos:
        1: Si el registro existe, se devolvera su posicion via parametro Pos,
       y la funcion devolvera como valor True.
        2: Si el registro no existe, pero otros campos estan abiertos para su escritura, el
       parametro Pos devolvera la primer posicion para escribir, y la funcion devolvera False.
        3: Si el registro no existe y tampoco se encuentra una posicion disponible, significaria
       que el archivo se encuentra lleno, en cuyo caso la variable Pos devolvera
       el valor _POSNULA y la funcion el valor False.
    }
  var
    resultado:boolean;
    Reg:TipoDatosAbierto;
    posDisp:TipoPos;
    Hash:TipoHash;

  begin
    resultado:=false;
    Hash:=FuncionHash(Clave);
    if BuscarListaDoble(ME,Hash,Pos)
    then begin

      //Obtengo el registro de datos
      CapturarListaDoble(ME,Pos,Reg);
      CapturarListaDoble(ME,Reg.InfoPos,Reg);

      //Compruebo si Reg es el registro correcto
      if Reg.Clave = Clave
      then resultado:=True
      else begin

        posDisp:=Pos; //Se almacena la posicion predilecta de Reg

        {Si Reg no fue encontrado en su posicion predilecta,
        entonces se invoca al metodo BusquedaCuadratica}
        if BusquedaCuadratica(ME,Pos,Clave)
        then resultado:=True
        else if Reg.Clave = ClaveNula //Si no esta en la posicion predilecta pero esta vacia
          then Pos:=posDisp; //Se almacena y devuelve via parametro Pos
      end

    end;

    BuscarHashAbierto:=resultado;

  end;

{------------------------------------------------------------------------------}

  Procedure CapturarHashAbierto(var ME:TipoHashAbierto; Pos:TipoPos; var Reg:TipoDatosAbierto);
  begin
    CapturarListaDoble(ME,Pos,Reg);
    CapturarListaDoble(ME,Reg.InfoPos,Reg);
  end;

{------------------------------------------------------------------------------}

  Procedure AgregarHashAbierto(var ME:TipoHashAbierto; Pos:TipoPos; Reg:TipoDatosAbierto);
  var
    Raux:TipoDatosAbierto;

  begin
    CapturarListaDoble(ME,Pos,Raux);
    ModificarListaDoble(ME,Raux.InfoPos,Reg);
  end;

{------------------------------------------------------------------------------}

  Procedure ModificarHashAbierto(var ME:TipoHashAbierto; Pos:TipoPos; Reg:TipoDatosAbierto);

  begin
    //El alta y la modificacion son identicos, por lo que solo se invoca al primero
    AgregarHashAbierto(ME,Pos,Reg);
  end;

{------------------------------------------------------------------------------}

  Procedure EliminarHashAbierto(var ME:TipoHashAbierto; Pos:TipoPos);
  var
    Reg:TipoDatosAbierto;
    posBorrado:TipoPos;

  begin
    {Para "eliminar" un registro, el registro de datos debe ser "vaciado":
    Clave = ClaveNula; InfoPos = PosNula.}

    //Obtengo el registro indice y la posicion de su registro de datos
    CapturarListaDoble(ME,Pos,Reg);
    Pos:=Reg.InfoPos;

    //Obtengo el registro de datos
    CapturarListaDoble(ME,Pos,Reg);

    {Agrego el registro de datos al final (MaxHash + 1) de la lista indice,
    solo para eliminarlo y agregarlo a la pila de borrados del indice}
    if not BuscarListaDoble(ME,inttostr(MaxHash + 1),posBorrado)
    then AgregarListaDoble(ME,Reg,posBorrado);
    posBorrado:=UltimoListaDoble(ME);
    EliminarListaDoble(ME,posBorrado);


    //Vacio el registro de datos y y lo guardo
    Reg.Clave:=ClaveNula;
    Reg.InfoPos:=PosNula;
    ModificarListaDoble(ME,Pos,Reg);
  end;

{------------------------------------------------------------------------------}

  Function PrimeroHashAbierto(var ME:TipoHashAbierto):TipoPos;
  var
    Pos:TipoPos;
    Reg:TipoDatosAbierto;

  begin
    Pos:=PrimeroListaDoble(ME);
    repeat
      CapturarListaDoble(ME,Pos,Reg);
      CapturarListaDoble(ME,Reg.InfoPos,Reg);
      if Reg.Clave = _CLAVENULA
      then Pos:=ProximoListaDoble(ME,Pos)
    until (Reg.Clave <> _CLAVENULA) or (Pos = _POSNULA);
    PrimeroHashAbierto:=Pos;
  end;

{------------------------------------------------------------------------------}

  Function AnteriorHashAbierto(var ME:TipoHashAbierto; Pos:TipoPos):TipoPos;
  var
    Reg:TipoDatosAbierto;

  begin
    Pos:=AnteriorListaDoble(ME,Pos);
    repeat
      CapturarListaDoble(ME,Pos,Reg);
      CapturarListaDoble(ME,Reg.InfoPos,Reg);
      if Reg.Clave = _CLAVENULA
      then Pos:=AnteriorListaDoble(ME,Pos)
    until (Reg.Clave <> _CLAVENULA) or (Pos = _POSNULA);
    AnteriorHashAbierto:=Pos;
  end;

{------------------------------------------------------------------------------}

  Function ProximoHashAbierto(var ME:TipoHashAbierto; Pos:TipoPos):TipoPos;
  var
    Reg:TipoDatosAbierto;

  begin
    Pos:=ProximoListaDoble(ME,Pos);
    repeat
      CapturarListaDoble(ME,Pos,Reg);
      CapturarListaDoble(ME,Reg.InfoPos,Reg);
      if Reg.Clave = _CLAVENULA
      then Pos:=ProximoListaDoble(ME,Pos)
    until (Reg.Clave <> _CLAVENULA) or (Pos = _POSNULA);
    ProximoHashAbierto:=Pos;
  end;

{------------------------------------------------------------------------------}

  Function UltimoHashAbierto(var ME:TipoHashAbierto):TipoPos;
  var
    Pos:TipoPos;
    Reg:TipoDatosAbierto;

  begin
    Pos:=UltimoListaDoble(ME);
    repeat
      CapturarListaDoble(ME,Pos,Reg);
      CapturarListaDoble(ME,Reg.InfoPos,Reg);
      if Reg.Clave = _CLAVENULA
      then Pos:=AnteriorListaDoble(ME,Pos)
    until (Reg.Clave <> _CLAVENULA) or (Pos = _POSNULA);
    UltimoHashAbierto:=Pos;
  end;

{------------------------------------------------------------------------------}

  Function HashAbiertoVacio(var ME:TipoHashAbierto):boolean;
  var
    Pos:TipoPos;
    Reg:TipoDatosAbierto;
    Vacio:boolean;

  begin
    Vacio:=True;
    Pos:=PrimeroListaDoble(ME);
    repeat
      CapturarListaDoble(ME,Pos,Reg);
      CapturarListaDoble(ME,Reg.InfoPos,Reg);
      if Reg.Clave = _CLAVENULA
      then Pos:=ProximoListaDoble(ME,Pos)
      else Vacio:=False;
    until (Reg.Clave <> _CLAVENULA) or (Pos = _POSNULA) or not Vacio;
    HashAbiertoVacio:=Vacio;
  end;

{------------------------------------------------------------------------------}

{
  Procedure TodoVacante(var ME:TipoHashAbierto);
  var
    Pos:TipoPos;
    Reg:TipoLDDatos;
    RegA:TipoRegAbierto;

  begin
    Pos:=PrimeroListaDoble(ME.I);

    repeat

      //Capturo el registro del INDICE y obtengo el registro de DATOS
      CapturarListaDoble(ME.I,Pos,Reg);
      seek(ME.A,Reg.InfoPos);
      read(ME.A,RegA);

      RegA.Vacante:=True;

      seek(ME.A,Reg.InfoPos);
      write(ME.A,RegA);

      Pos:=ProximoListaDoble(ME.I,Pos);//Busco la siguiente posicion

    until (Pos = _POSNULA);
  end;

  Procedure SinVacantes(var ME:TipoHashAbierto);
  var
    Pos:TipoPos;
    Reg:TipoLDDatos;
    RegA:TipoRegAbierto;

  begin
    Pos:=PrimeroListaDoble(ME.I);

    repeat

      //Capturo el registro del INDICE y obtengo el registro de DATOS
      CapturarListaDoble(ME.I,Pos,Reg);
      seek(ME.A,Reg.InfoPos);
      read(ME.A,RegA);

      RegA.Vacante:=False;

      seek(ME.A,Reg.InfoPos);
      write(ME.A,RegA);

      Pos:=ProximoListaDoble(ME.I,Pos);//Busco la siguiente posicion

    until (Pos = _POSNULA);
  end;
}
end.
