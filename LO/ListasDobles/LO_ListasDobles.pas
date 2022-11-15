unit LO_ListasDobles;

interface


    {Listas Dobles:
      Para la lectura y escritura de datos, los registros almacenados contendran,
    ademas de los datos recibidos por parametros, los campos Ant y Sig que definiran
    la ubicacion del anterior y posterior registro en el archivo. Los valores de
    estos campos estan definidos por la libreria y, por lo tanto, no se recomienda
    su manipulacion.

      A su vez, esta libreria tambien integra la funcion de crear listas multiples
    en base a tres metodos que estaran definidos mas adelante.
    }

  Const
    _POSNULA = -1;
    _CLAVENULA = '';
  Type
    TipoPos = LongInt;
    TipoID = LongInt;
    TipoClave = String[8];
    TipoDatosDoble = record
                    Clave:TipoClave;
                    Ant,Sig:TipoPos;
                    InfoPos:TipoPos;
                  end;

    TipoDobleArchD = File of TipoDatosDoble;

    TipoControlDoble = record
                      Primero,Ultimo,Borrados:TipoPos;
                    end;

    TipoDobleArchC = File of TipoControlDoble;

    TipoListaDoble = record
                      C:TipoDobleArchC;
                      D:TipoDobleArchD;
                     end;

    Procedure CrearListaDoble(var ME:TipoListaDoble; Nombre,Ruta:string);
    Procedure DestruirListaDoble(var ME:TipoListaDoble);
    Procedure AbrirListaDoble(var ME:TipoListaDoble);
    Procedure CerrarListaDoble(var ME:TipoListaDoble);

    //Metodos para la creacion y modificacion de multiples listas en la libreria
    Procedure GenerarNuevaListaDoble(var ME:TipoListaDoble; var RC:TipoControlDoble);
    Procedure IniciarListaDobleExistente(var ME:TipoListaDoble; RC:TipoControlDoble);
    Function ObtenerControlListaDoble(var ME:TipoListaDoble):TipoControlDoble;

    Function BuscarListaDoble(var ME:TipoListaDoble; Clave:TipoClave; var Pos:TipoPos):Boolean;
    Procedure CapturarListaDoble(var ME:TipoListaDoble; Pos:TipoPos; var Reg:TipoDatosDoble);
    Procedure AgregarListaDoble(var ME:TipoListaDoble; Reg:TipoDatosDoble; Pos:TipoPos);
    Procedure ModificarListaDoble(var ME:TipoListaDoble; Pos:TipoPos; Reg:TipoDatosDoble);
    Procedure EliminarListaDoble(var ME:TipoListaDoble; Pos:TipoPos);

    Function ListaDobleVacia(var ME:TipoListaDoble):Boolean;
    Function PrimeroListaDoble(var ME:TipoListaDoble):TipoPos;
    Function UltimoListaDoble(var ME:TipoListaDoble):TipoPos;
    Function ProximoListaDoble(var ME:TipoListaDoble; Pos:TipoPos):TipoPos;
    Function AnteriorListaDoble(var ME:TipoListaDoble; Pos:TipoPos):TipoPos;

    Function ClaveNula:TipoClave;
    Function PosNula:TipoPos;

implementation

  Procedure CrearListaDoble(var ME:TipoListaDoble; Nombre,Ruta:string);
  var
    RC:TipoControlDoble;
    bControlOK,bControlDatos:boolean;

  begin
    Assign(Me.C,Ruta + Nombre + '.con');
    Assign(ME.D,Ruta + Nombre + '.dat');
    {$I-} {Directiva de Compilacion: debilita el control de errores de delphi
    En caso de error, no cierra la aplicacion}
    Reset(ME.C);
    bControlOK := (IOResult = 0);
    Reset(ME.D);
    bControlDatos := (IOResult = 0);
    if (not(bControlOK)) and (not(bControlDatos))
    then begin
      Rewrite(ME.C);
      RC.Primero:=_POSNULA;
      RC.Ultimo:=_POSNULA;
      RC.Borrados:=_POSNULA;
      Write(ME.C,RC);
      Rewrite(ME.D);
    end;
    Close(ME.C);
    Close(ME.D);
    {$i+}
  end;

{------------------------------------------------------------------------------}

  Procedure DestruirListaDoble(var ME:TipoListaDoble);

  begin
    Erase(ME.C);
    Erase(ME.D);
  end;

{------------------------------------------------------------------------------}

  Procedure AbrirListaDoble(var ME:TipoListaDoble);

  begin
    Reset(ME.C);
    Reset(ME.D);
  end;

{------------------------------------------------------------------------------}

  Procedure GenerarNuevaListaDoble(var ME:TipoListaDoble; var RC:TipoControlDoble);
  {Para controlar multiples listas se recomienda conservar el registro de control de
  cada una, devuelto via parametro RC. Sin este registros las listas ya existentes
  seran inaccesibles.

  Se vuelven los datos del registro de control actualmente guardado en el archivo
  de control al estado previo a que se hayan guardado registros. La nueva lista
  queda iniciada para su inmediato uso.}

  begin
    RC.Primero:=_POSNULA;
    RC.Ultimo:=_POSNULA;
    RC.Borrados:=_POSNULA;
    seek(ME.C,0);
    write(ME.C,RC);
  end;

{------------------------------------------------------------------------------}

  Procedure IniciarListaDobleExistente(var ME:TipoListaDoble; RC:TipoControlDoble);
  {Para poder trabajar con una lista ya existente se debe reemplazar el registro del
  archivo de control por los del registro de control RC, obtenido via parametro RC.}

  begin
    seek(ME.C,0);
    write(ME.C,RC);
  end;

{------------------------------------------------------------------------------}

  Function ObtenerControlListaDoble(var ME:TipoListaDoble):TipoControlDoble;
  {La funcion devolvera los datos del archivo de control de la lista actualmente
  iniciada. Se recomienda invocar esta funcion antes de iniciar o generar otra lista,
  para salvaguardar la informacion}
  var
    RC:TipoControlDoble;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    ObtenerControlListaDoble:=RC;
  end;

{------------------------------------------------------------------------------}

  Procedure CerrarListaDoble(var ME:TipoListaDoble);

  begin
    Close(ME.C);
    Close(ME.D);
  end;

{------------------------------------------------------------------------------}

  Function BuscarListaDoble(var ME:TipoListaDoble; Clave:TipoClave; var Pos:TipoPos):Boolean;
  //Esta busqueda se realiza para encontrar una Clave definida por el programador

  var
    RC:TipoControlDoble;
    Encont,Corte:boolean;
    Reg:TipoDatosDoble;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    Pos:=RC.Primero;
    Encont:=False;
    Corte:=False;
    {"Corte" es una variable que sirve para identificar la posicion del primer registro
     con clave mayor a la buscada. Con este dato, se puede agregar un nuevo registro
     como padre del registro en la posicion devuelta, teniendo como clave la buscada}
    if not ListaDobleVacia(ME)
    then
      While not(Encont) and (Pos <> _POSNULA) and not(Corte)
      do begin
        seek(ME.D,Pos);
        read(ME.D,Reg);
        if Reg.Clave = Clave
        then Encont:=True
        else if Reg.Clave > Clave
          then Corte:=true
          else Pos:=Reg.Sig;
      end;
    BuscarListaDoble:=Encont;
  end;

{------------------------------------------------------------------------------}

  Procedure CapturarListaDoble(var ME:TipoListaDoble; Pos:TipoPos; var Reg:TipoDatosDoble);

  begin
    seek(ME.D,Pos);
    read(ME.D,Reg);
  end;

{------------------------------------------------------------------------------}

  Procedure AgregarListaDoble(var ME:TipoListaDoble; Reg:TipoDatosDoble; Pos:TipoPos);
  var
    PosNueva:TipoPos;
    Raux,RauxS,RauxA:TipoDatosDoble;
    RC:TipoControlDoble;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    PosNueva:=FileSize(ME.D);
    if RC.Primero = _POSNULA //Si sera el primer registro ingresado en el archivo
    then begin
      RC.Primero:=PosNueva;
      RC.Ultimo:=PosNueva;
      Reg.Sig:=_POSNULA;
      Reg.Ant:=_POSNULA;
    end
    else
     if RC.Primero = Pos //Si va a ser el primer registro del archivo
      then begin
        //Obtengo el primer registro
        seek(ME.D,RC.Primero);
        read(ME.D,Raux);

        //Asigno las posiciones a Reg y al primero
        Raux.Ant:=PosNueva;
        Reg.Ant:=_POSNULA;
        Reg.Sig:=RC.Primero;

        //Modifico al ex-primer registro
        seek(ME.D,RC.Primero);
        write(ME.D,Raux);

        //Modico al registro de control
        RC.Primero:=PosNueva;
      end
      else
        if Pos = _POSNULA //Si va a ser el ultimo registro del archivo
        then begin
          //Obtengo el ultimo registro
          seek(ME.D,RC.Ultimo);
          read(ME.D,Raux);

          //Asigno las posiciones a Reg y al ultimo
          Raux.Sig:=PosNueva;
          Reg.Ant:=RC.Ultimo;
          Reg.Sig:=_POSNULA;

          //Modifico al ex-ultimo registro
          seek(ME.D,RC.Ultimo);
          write(ME.D,Raux);

          //Modico al registro de control
          RC.Ultimo:=PosNueva;
        end
        else begin //Si va a estar entre dos registros preexistentes

          //Obtengo los futuros registros que seran el anterior y el posterior de Reg
          seek(ME.D,Pos);
          read(ME.D,RauxS);
          seek(ME.D,RAuxS.Ant);
          read(ME.D,RauxA);

          //Asigno las posiciones a Reg
          Reg.Ant:=RAuxS.Ant;
          Reg.Sig:=RAuxA.Sig;

          //Modifico al registro anterior a Reg
          RauxA.Sig:=PosNueva;
          seek(ME.D,RAuxS.Ant);
          write(ME.D,RauxA);

          //Modifico al registro posterior a Reg
          RauxS.Ant:=PosNueva;
          seek(ME.D,Pos);
          write(ME.D,RAuxS);
        end;

    //Guardo Reg
    seek(ME.D,PosNueva);
    write(ME.D,Reg);

    //Guardo el registro de control
    seek(ME.C,0);
    write(ME.C,RC);
  end;

{------------------------------------------------------------------------------}

  Procedure ModificarListaDoble(var ME:TipoListaDoble; Pos:TipoPos; Reg:TipoDatosDoble);

  begin
    seek(ME.D,Pos);
    write(ME.D,Reg);
  end;

{------------------------------------------------------------------------------}

  Procedure EliminarListaDoble(var ME:TipoListaDoble; Pos:TipoPos);
  var
    Reg,Raux,RAuXAnt,RAuxSig:TipoDatosDoble;
    RC:TipoControlDoble;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    seek(ME.D,Pos);
    read(ME.D,Reg);
    if (RC.Primero = Pos) and (RC.Ultimo = Pos)
    then begin //Elimino el unico registro
      RC.Primero:=_POSNULA;
      RC.Ultimo:=_POSNULA;
    end
    else
      if RC.Primero = Pos //Elimino a Reg, el primer registro
      then begin

        //Obtengo, modifico y guardo al posterior de Reg, ahora el nuevo primer registro
        RC.Primero:=Reg.Sig;
        seek(ME.D,Reg.Sig);
        read(ME.D,Raux);
        Raux.Ant:=_POSNULA;
        seek(ME.D, Reg.Sig);
        write(ME.D,Raux);
      end
      else
        if RC.Ultimo = Pos //Elimino a Reg, el ultimo registro
        then begin

          //Obtengo, modifico y guardo al anterior de Reg, ahora el nuevo ultimo registro
          RC.Ultimo:=Reg.Ant;
          seek(ME.D,Reg.Ant);
          read(ME.D,Raux);
          Raux.Sig:=_POSNULA;
          seek(ME.D,Reg.Ant);
          write(ME.D,Raux);
        end
        else begin //Elimino a Reg, que no es ni el primer ni el ultimo registro

          //Obtengo los registros anterior y posterior de Reg
          seek(ME.D,Reg.Sig);
          read(ME.D,RAuxSig);
          seek(ME.D,Reg.Ant);
          read(ME.D,RAuxAnt);

          //Modifico los registros
          RAuxAnt.Sig:=Reg.Sig;
          RAuxSig.Ant:=Reg.Ant;

          //Guardo los registros
          seek(ME.D,Reg.Ant);
          write(ME.D,RAuXAnt);
          seek(ME.D,Reg.Sig);
          write(ME.D,RAuXSig);
        end;

    //Asigno a Reg al principio de la pila de borrados
    Reg.Sig:=RC.Borrados;
    Reg.Ant:=_POSNULA;
    RC.Borrados:=Pos;

    //Guardo Reg
    seek(ME.D,Pos);
    write(ME.D,Reg);

    //Guardo el registro de control
    seek(ME.C,0);
    write(ME.C,RC);
  end;

{------------------------------------------------------------------------------}

  Function ListaDobleVacia(var ME:TipoListaDoble):Boolean;

  var
    RC:TipoControlDoble;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    ListaDobleVacia:=(RC.Primero = _POSNULA);
  end;

{------------------------------------------------------------------------------}

  Function PrimeroListaDoble(var ME:TipoListaDoble):TipoPos;

  var
    RC:TipoControlDoble;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    PrimeroListaDoble:=RC.Primero;
  end;

{------------------------------------------------------------------------------}

  Function UltimoListaDoble(var ME:TipoListaDoble):TipoPos;

  var
    RC:TipoControlDoble;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    UltimoListaDoble:=RC.Ultimo;
  end;

{------------------------------------------------------------------------------}

  Function ProximoListaDoble(var ME:TipoListaDoble; Pos:TipoPos):TipoPos;

  var
    Reg:TipoDatosDoble;

  begin
    seek(ME.D,Pos);
    read(ME.D,Reg);
    ProximoListaDoble:=Reg.Sig;
  end;

{------------------------------------------------------------------------------}

  Function AnteriorListaDoble(var ME:TipoListaDoble; Pos:TipoPos):TipoPos;

  var
    Reg:TipoDatosDoble;

  begin
    seek(ME.D,Pos);
    read(ME.D,Reg);
    AnteriorListaDoble:=Reg.Ant;
  end;

{------------------------------------------------------------------------------}

  Function ClaveNula:TipoClave;
  begin
    ClaveNula:=_CLAVENULA;
  end;

{------------------------------------------------------------------------------}

  Function PosNula:TipoPos;
  begin
    PosNula:=_POSNULA;
  end;

{------------------------------------------------------------------------------}

end.
