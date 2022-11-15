unit LO_HashCerrado;

interface

  uses
  LO_ListasDobles, Formatos, SysUtils;


  {HASH CERRADO:
     Esta libreria hara uso extenso de la libreria ListaDoble, por lo que puede ser
    considerada una forma extendidada de esta. La diferencia radica en que habra una
    cantidad de archivos de datos (cada uno con su respectivo archivo de control)
    equivalente al resultado de la operacion: MaxHash - MinHash;


     Las colisiones se manejan guardando los registros con igual resultado Hash
    en un archivo de datos especifico para los registros que devuelvan el mismo resultado.
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

    TipoDatosCerrado = TipoDatosDoble;

    TipoControlCerrado = TipoControlDoble;

    TipoControlArchC = File of TipoControlCerrado;

    TipoHashCerrado = record
                        D:TipoListaDoble; //Datos
                        C:TipoControlArchC; //Registros de Control
                      end;

    Procedure CrearHashCerrado(var ME:TipoHashCerrado; Nombre,Ruta:string);
    Procedure DestruirHashCerrado(var ME:TipoHashCerrado);
    Procedure AbrirHashCerrado(var ME:TipoHashCerrado);
    Procedure CerrarHashCerrado(var ME:TipoHashCerrado);

    Function BuscarHashCerrado(var ME:TipoHashCerrado; Clave:TipoClave; var Pos:TipoPos):Boolean;
    Procedure CapturarHashCerrado(var ME:TipoHashCerrado; Pos:TipoPos; var Reg:TipoDatosCerrado);
    Procedure AgregarHashCerrado(var ME:TipoHashCerrado; Pos:TipoPos; Reg:TipoDatosCerrado);
    Procedure ModificarHashCerrado(var ME:TipoHashCerrado; Pos:TipoPos; Reg:TipoDatosCerrado);
    Procedure EliminarHashCerrado(var ME:TipoHashCerrado; Pos:TipoPos);

    Function PrimeroHashCerrado(var ME:TipoHashCerrado):TipoPos;
    Function AnteriorHashCerrado(var ME:TipoHashCerrado; Pos:TipoPos):TipoPos;
    Function ProximoHashCerrado(var ME:TipoHashCerrado; Pos:TipoPos):TipoPos;
    Function UltimoHashCerrado(var ME:TipoHashCerrado):TipoPos;
    Function ListaVaciaHashCerrado(var ME:TipoHashCerrado):boolean;

    Function FuncionHash(Clave:TipoClave):TipoHash;

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

  Procedure CrearHashCerrado(var ME:TipoHashCerrado; Nombre,Ruta:string);
  var
    i:Integer;
    bControlOK:boolean;
    Pos,PosNueva:TipoPos;
    Reg:TipoDatosCerrado;
    RC:TipoControlCerrado;

  begin
    //Se crea la ListaDoble, que almacenara todas las listas de HashCerrado
    CrearListaDoble(ME.D,Nombre,Ruta);

    {Se crea el archivo de control que almacenara los registros de control de todas
    y cada una lista de las listas. La primera lista sera la que contendra las claves
    Hash, mientras que las demas seran asignadas a cada uno de los resultados univocos
    de la FuncionHash}
    Assign(ME.C,Ruta + Nombre + '.ctx');

    {$I-} {Directiva de Compilacion: debilita el control de errores de delphi
    En caso de error, no cierra la aplicacion}
    Reset(ME.C);
    bControlOK := (IOResult = 0);
    if not(bControlOK)
    then begin
      Rewrite(ME.C);
      AbrirListaDoble(ME.D);

      //Obtengo un registro de control vacio para asignar a todas las listas
      GenerarNuevaListaDoble(ME.D,RC);

      //El registro de control de la lista Hash se ubica al principio del archivo
      seek(ME.C,0);
      write(ME.C,RC);

      //Se crean los registros de control de todas las listas de datos
      for i:= MinHash to MaxHash
      do begin

        //Inserto el registro de control de cada lista de datos en el archivo de control
        PosNueva:=FileSize(ME.C);
        seek(ME.C,PosNueva);
        write(ME.C,RC);

        //Inserto el registro con clave Hash que contendra la posicion del registro de control
        Reg.InfoPos:=PosNueva;
        Reg.Clave:=PreCerosInteger(3,i);
        if not(BuscarListaDoble(ME.D,Reg.Clave,Pos))
        then AgregarListaDoble(ME.D,Reg,Pos);
      end;

      //Obtengo el registro de control de la lista Hash actualizada y lo guardo
      RC:=ObtenerControlListaDoble(ME.D);
      seek(ME.C,0);
      write(ME.C,RC);
    
      CerrarListaDoble(ME.D);
    end;
    Close(ME.C);
    {$i+}
  end;

{------------------------------------------------------------------------------}

  Procedure DestruirHashCerrado(var ME:TipoHashCerrado);

  begin
    Erase(ME.C);
    DestruirListaDoble(ME.D);
  end;

{------------------------------------------------------------------------------}

  Procedure AbrirHashCerrado(var ME:TipoHashCerrado);

  begin
    Reset(ME.C);
    AbrirListaDoble(ME.D);
  end;

{------------------------------------------------------------------------------}

  Procedure CerrarHashCerrado(var ME:TipoHashCerrado);

  begin
    Close(ME.C);
    CerrarListaDoble(ME.D);
  end;

{------------------------------------------------------------------------------}

  Function BuscarHashCerrado(var ME:TipoHashCerrado; Clave:TipoClave; var Pos:TipoPos):Boolean;
  var
    encont:boolean;
    Reg:TipoDatosCerrado;
    RCHash,RCDatos:TipoControlCerrado;
    Hash:TipoHash;
    posAux:TipoPos;

  begin
    Hash:=FuncionHash(Clave);
    Encont:=False;

    //Obtengo el registro de control de la lista de claves Hash y lo inicio en la ListaDoble
    seek(ME.C,0);
    read(ME.C,RCHash);
    IniciarListaDobleExistente(ME.D,RCHash);

    //Busco el registro con la clave Hash
    if BuscarListaDoble(ME.D,Hash,posAux)
    then begin
      //Obtengo el registro de control de la lista de datos y lo inicio
      CapturarListaDoble(ME.D,posAux,Reg);
      seek(ME.C,Reg.InfoPos);
      read(ME.C,RCDatos);
      IniciarListaDobleExistente(ME.D,RCDatos);

      //Busco el registro en su lista de datos
      if BuscarListaDoble(ME.D,Clave,Pos)
      then Encont:=True;
    end;

    {Se deja iniciada la lista donde el archivo deberia estar ubicado el registro.
    El parametro Pos devuelve la posicion dentro de esta lista}
    BuscarHashCerrado:=encont;
  end;

{------------------------------------------------------------------------------}

  Procedure CapturarHashCerrado(var ME:TipoHashCerrado; Pos:TipoPos; var Reg:TipoDatosCerrado);

  begin
    CapturarListaDoble(ME.D,Pos,Reg);
  end;

{------------------------------------------------------------------------------}

  Procedure ActualizarRegistroControl(var ME:TipoHashCerrado; Clave:TipoClave);
  var
    Reg:TipoDatosCerrado;
    RCDatos,RCHash:TipoControlCerrado;
    Hash:TipoHash;
    Pos:TipoPos;

  begin
    //Obtengo el registro, su clave y el Hash de esta
    if BuscarListaDoble(ME.D,Clave,Pos)
    then CapturarListaDoble(ME.D,Pos,Reg);
    Hash:=FuncionHash(Clave);

    //Obtengo el registro de control actualizado de la lista de datos
    RCDatos:=ObtenerControlListaDoble(ME.D);

    //Obtengo el registro de control de la lista Hash y lo inicio en ListaDoble
    seek(ME.C,0);
    read(ME.C,RCHash);
    IniciarListaDobleExistente(ME.D,RCHash);

    //Actualizo el registro de control de la lista de datos, en el archivo de control
    if BuscarListaDoble(ME.D,Hash,Pos)
    then CapturarListaDoble(ME.D,Pos,Reg);
    seek(ME.C,Reg.InfoPos);
    write(ME.C,RCDatos);
  end;

{------------------------------------------------------------------------------}

  Procedure AgregarHashCerrado(var ME:TipoHashCerrado; Pos:TipoPos; Reg:TipoDatosCerrado);

  begin
    //Agrego el registro y actualizo el registro de control de la lista de datos
    AgregarListaDoble(ME.D,Reg,Pos);
    ActualizarRegistroControl(ME,Reg.Clave);
  end;

{------------------------------------------------------------------------------}

  Procedure ModificarHashCerrado(var ME:TipoHashCerrado; Pos:TipoPos; Reg:TipoDatosCerrado);

  begin
    ModificarListaDoble(ME.D,Pos,Reg);
  end;

{------------------------------------------------------------------------------}

  Procedure EliminarHashCerrado(var ME:TipoHashCerrado; Pos:TipoPos);
  var
    Reg:TipoDatosCerrado;

  begin
    //Elimino el registro y actualizo el registro de control de la lista de datos
    CapturarListaDoble(ME.D,Pos,Reg);
    EliminarListaDoble(ME.D,Pos);
    ActualizarRegistroControl(ME,Reg.Clave);
  end;

{------------------------------------------------------------------------------}

   Function PrimeroHashCerrado(var ME:TipoHashCerrado):TipoPos;
   begin
    PrimeroHashCerrado:=PrimeroListaDoble(ME.D);
   end;

{------------------------------------------------------------------------------}

   Function AnteriorHashCerrado(var ME:TipoHashCerrado; Pos:TipoPos):TipoPos;
   begin
    AnteriorHashCerrado:=AnteriorListaDoble(ME.D,Pos);
   end;

{------------------------------------------------------------------------------}

   Function ProximoHashCerrado(var ME:TipoHashCerrado; Pos:TipoPos):TipoPos;
   begin
    ProximoHashCerrado:=ProximoListaDoble(ME.D,Pos);
   end;

{------------------------------------------------------------------------------}

   Function UltimoHashCerrado(var ME:TipoHashCerrado):TipoPos;
   begin
    UltimoHashCerrado:=UltimoListaDoble(ME.D);
   end;

{------------------------------------------------------------------------------}

   Function ListaVaciaHashCerrado(var ME:TipoHashCerrado):boolean;
   begin
    ListaVaciaHashCerrado:=ListaDobleVacia(ME.D);
   end;

{------------------------------------------------------------------------------}

end.
