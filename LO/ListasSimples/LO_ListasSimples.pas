unit LO_ListasSimples;

interface
uses
  SysUtils;

const
  _POSNULA = -1;
  _CLAVENULA = '';

type
  TipoPos = LongInt;
  TipoID = LongInt;
  TipoClave = string[8];
  TipoDatosSimple = record
          Clave:TipoClave;
          Enlace:TipoPos;
          InfoPos:TipoPos;
        end;
  ArchivoDatosSimple = File of TipoDatosSimple;
  TipoControlSimple = record
          Primero:TipoPos;
          Ultimo:TipoPos;
          Borrados:TipoPos;
        end;
  ArchivoControlSimple = File of TipoControlSimple;
  TipoListaSimple = record
          D:ArchivoDatosSimple;
          C:ArchivoControlSimple;
        end;

  Procedure CrearListaSimple(var ME:TipoListaSimple; Nombre,Ruta:string);
  Procedure DestruirListaSimple(var ME:TipoListaSimple);
  Procedure AbrirListaSimple(var ME:TipoListaSimple);
  Procedure CerrarListaSimple(var ME:TipoListaSimple);

  Function PrimeroListaSimple(var ME:TipoListaSimple):TipoPos;
  Function UltimoListaSimple(var ME:TipoListaSimple):TipoPos;
  Function ProximoListaSimple(var ME:TipoListaSimple; Pos:TipoPos):TipoPos;
  Function AnteriorListaSimple(var ME:TipoListaSimple; Pos:TipoPos):TipoPos;
  Function ListaSimpleVacia(var ME:TipoListaSimple):Boolean;

  Function BuscarListaSimple(var ME:TipoListaSimple; Clave:TipoClave; var Pos:TipoPos):Boolean;
  Procedure CapturarListaSimple(var ME:TipoListaSimple; Pos:TipoPos; var Reg:TipoDatosSimple);
  Procedure AgregarListaSimple(var ME:TipoListaSimple; Reg:TipoDatosSimple; Pos:TipoPos);
  Procedure ModificarListaSimple(var ME:TipoListaSimple; Pos:TipoPos; Reg:TipoDatosSimple);
  Procedure EliminarListaSimple(var ME:TipoListaSimple; Pos:TipoPos);

implementation

  Procedure CrearListaSimple(var ME:TipoListaSimple; Nombre,Ruta:string);
  var
    RC:TipoControlSimple;
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

  Procedure DestruirListaSimple(var ME:TipoListaSimple);

  begin
    erase(ME.D);
    erase(ME.C);
  end;

{------------------------------------------------------------------------------}

  Procedure AbrirListaSimple(var ME:TipoListaSimple);

  begin
    reset(ME.D);
    reset(ME.C);
  end;

{------------------------------------------------------------------------------}

  Procedure CerrarListaSimple(var ME:TipoListaSimple);

  begin
    close(ME.D);
    close(ME.C);
  end;

{------------------------------------------------------------------------------}

  Function PrimeroListaSimple(var ME:TipoListaSimple):TipoPos;
  var
    RC:TipoControlSimple;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    PrimeroListaSimple:=RC.Primero;
  end;

{------------------------------------------------------------------------------}

  Function UltimoListaSimple(var ME:TipoListaSimple):TipoPos;
  var
    RC:TipoControlSimple;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    UltimoListaSimple:=RC.Ultimo;
  end;

{------------------------------------------------------------------------------}

  Function ListaSimpleVacia(var ME:TipoListaSimple):Boolean;

  var
    RC:TipoControlSimple;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    ListaSimpleVacia:=(RC.Primero = _POSNULA);
  end;

{------------------------------------------------------------------------------}

  Function ProximoListaSimple(var ME:TipoListaSimple; Pos:TipoPos):TipoPos;
  //Devuelve el enlace siempre que Pos no sea _POSNULA, en cuyo caso se devuelve el primero
  var
    RC:TipoControlSimple;
    Reg:TipoDatosSimple;

  begin
    if Pos = _POSNULA
    then begin
      seek(ME.C,0);
      read(ME.C,RC);
      ProximoListaSimple:=RC.Primero;
    end
    else begin
      seek(ME.D,Pos);
      read(ME.D,Reg);
      ProximoListaSimple:=Reg.Enlace;
    end;
  end;

{------------------------------------------------------------------------------}

  Function AnteriorListaSimple(var ME:TipoListaSimple; Pos:TipoPos):TipoPos;
  //Anterior devolvera la posicion del registro anterior a la posicion buscada
  var
    RC:TipoControlSimple;
    posaux:TipoPos;
    Reg:TipoDatosSimple;
    encont:boolean;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    if (RC.Primero = pos) or (pos = _POSNULA) //Si Pos es la posicion del primero o _POSNULA
    then AnteriorListaSimple:=_POSNULA  //Devuelve _POSNULA
    else begin //Caso contrario, se devuelve la posicion del registro anterior
      encont:=false;
      posaux:=RC.Primero;
      while (not encont) and (posaux <> _POSNULA)
      do begin
        seek(ME.D,posaux);
        read(ME.D,Reg);
        if Reg.Enlace = pos //Si el enlace es la posicion buscada
        then encont:=true  //Entonces estoy parado en el anterior
        else posaux:=Reg.Enlace; //Caso contrario, posaux tomara como valor el Enlace
      end;
      AnteriorListaSimple:=posaux;
    end;
  end;

{------------------------------------------------------------------------------}

  Function BuscarListaSimple(var ME:TipoListaSimple; Clave:TipoClave; var Pos:TipoPos):boolean;
  //La funcion retornara la posicion anterior a la del registro buscado
  var
    corte,encont:boolean;
    PosAux:TipoPos;
    RC:TipoControlSimple;
    Reg:TipoDatosSimple;

  begin
    encont:=False;
    corte:=False;
    seek(ME.C,0);
    read(ME.C,RC);
    PosAux:=RC.Primero;
    Pos:=_POSNULA;
    while (not(encont)) and (PosAux<>_POSNULA) and (not(corte))
    //Condicion 1: el registro no fue encontrado (encont)
    //Condicion 2: no se llego al final del archivo (PosAux)
    //Condicion 3: se alcanzo un registro que deberia ser el proximo del registro buscado (corte)
    do begin
      seek(ME.D,PosAux);
      read(ME.D,Reg);
      if Reg.Clave = Clave
      then encont:=true //Si se encontro el registro buscado
      else
        if Reg.Clave < Clave //Si se alcanzo un registro con clave mayor al buscado
        then begin
          Pos:=PosAux; //Pos contendra la posicion actual
          PosAux:=Reg.Enlace; //PosAux toma la posicion del siguiente registro
        end
        else corte:=true;
    end;
    BuscarListaSimple:=encont;
  end;

{------------------------------------------------------------------------------}

  Procedure CapturarListaSimple(var ME:TipoListaSimple; Pos:TipoPos; var Reg:TipoDatosSimple);

  var
    RC:TipoControlSimple;
    Raux:TipoDatosSimple;

  begin
    if pos =_POSNULA //Es el primer registro
    then begin
      seek(ME.C,0);
      read(ME.C,RC);
      seek(ME.D,RC.Primero);
      read(ME.D,Reg);
    end
    else begin //Es otro registro
      seek(ME.D,Pos);
      read(ME.D,Raux);
      seek(ME.D,Raux.Enlace);
      read(ME.D,Reg);
    end;
  end;
{------------------------------------------------------------------------------}

  Procedure AgregarListaSimple(var ME:TipoListaSimple; Reg:TipoDatosSimple; Pos:TipoPos);

  var
    RC:TipoControlSimple;
    Raux:TipoDatosSimple;
    PosNueva:TipoPos;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    PosNueva := FileSize(ME.D);
    if RC.Primero = _POSNULA //Si sera el primer registro ingresado en el archivo
    then begin
      RC.Primero:=PosNueva;
      RC.Ultimo:=PosNueva;
      Reg.Enlace:=_POSNULA;
    end
    else if pos = _POSNULA //Si va a ser el primer registro de la lista
      then begin
        Reg.Enlace:=RC.Primero;
        RC.Primero:=PosNueva;
      end
      else begin //Si no va a ser el primero, entonces capturo el anterior registro
        seek(ME.D,pos);
        read(ME.D,Raux);
        if pos=RC.Ultimo //Si va a ser el ultimo registro de la lista
        then begin
          Raux.Enlace:=PosNueva;
          Reg.Enlace:=_POSNULA;
          RC.Ultimo:=PosNueva;
        end
        else begin  //Si va a estar entre dos registros preexistentes
          Reg.Enlace:=Raux.Enlace;
          Raux.Enlace:=PosNueva;
        end;
        //Guardo el registro anterior
        seek(ME.D,pos);
        write(ME.D,Raux);
      end;  
    seek(ME.D,PosNueva);
    write(ME.D,Reg);
    seek(ME.C,0);
    write(ME.C,RC);
  end;

{------------------------------------------------------------------------------}

  Procedure ModificarListaSimple(var ME:TipoListaSimple; Pos:TipoPos; Reg:TipoDatosSimple);
  var
    RC:TipoControlSimple;
    Raux:TipoDatosSimple;

  begin
    if pos=_POSNULA //Es el primer registro
    then begin
      seek(ME.C,0);
      read(ME.C,RC);
      seek(ME.D,RC.Primero);
      write(ME.D,Reg);
    end
    else begin //Es otro registro
      seek(ME.D,Pos);
      read(ME.D,Raux);
      seek(ME.D,Raux.Enlace);
      write(ME.D,Reg);
    end;
  end;

{------------------------------------------------------------------------------}

  Procedure EliminarListaSimple(var ME:TipoListaSimple; Pos:TipoPos);

  var
    Raux,Reg:TipoDatosSimple;
    RC:TipoControlSimple;
    PosB:TipoPos; //Posicion del registro eliminado

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    if RC.Primero = RC.Ultimo //Solo existe un registro, el archivo quedara vacio
    then begin
      PosB:=RC.Primero;
      RC.Primero:=_POSNULA;
      RC.Ultimo:=_POSNULA;
    end
    else
      if Pos = _POSNULA //Se elimina al primer registro
      then begin //El siguiente sera el nuevo primero
        PosB:=RC.Primero;
        seek(ME.D,PosB);
        read(ME.D,Raux);
        RC.Primero:=Raux.Enlace;
      end
      else begin //No es el primero, obtengo el registro anterior
        seek(ME.D,Pos);
        read(ME.D,Raux);
        PosB:=Raux.Enlace;
        if Raux.Enlace = RC.Ultimo //Se elimina el ultimo registro
        then begin //El anterior sera el nuevo ultimo
          Raux.Enlace:=_POSNULA;
          RC.Ultimo:=Pos;
        end
        else begin //No es ninguno de los casos anteriores
          seek(ME.D,Raux.Enlace);
          read(ME.D,Reg);
          Raux.Enlace:=Reg.Enlace;
        end;
        //Guardo el registro anterior
        seek(ME.D,Pos);
        write(ME.D,Raux);
      end;

    //Apilo el registro dentro de la pila de borrados
    seek(ME.D,PosB);
    read(ME.D,Reg);
    Reg.Enlace:=RC.Borrados;
    RC.Borrados:=PosB;
    seek(ME.D,PosB);
    write(ME.D,Reg);

    //Guardo el registro de control
    seek(ME.C,0);
    write(ME.C,RC);
  end;

end.
