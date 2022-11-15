unit TDA_Jugadores;

  {El arbol binario AVL servira como un indice de claves (nicks) de los registros
  de datos guardados. Debido a su alta eficiencia en busquedas, servira para
  conocer (o no) la existencia de los datos.

  Sin embargo, las posiciones de regsitros, en el archivo de datos, se guardaran
  en los registros de la libreria HashAbierto.}
interface

uses
  LO_ArbolAVL, LO_HashAbierto, Formatos, Rutas, SysUtils;

const
  _POSNULA = LO_ArbolAVL._POSNULA;
  _CLAVENULA = LO_ArbolAVL._CLAVENULA;

type
  TipoNick = TipoClave;
  TipoRegJugador = record
                  Nick:TipoNick; //ID del jugador en el sistema
                  Clave:string[12]; //Contraseña
                  Nombre:string[100];
                  Apellidos:string[100];
                  FechaHora:TDateTime; //Fecha y Hora de su registro
                  Foto:string[255]; //URL del archivo
                  Tipo:boolean; //Si es real o ficticio
                  Estado:boolean; //Si esta o no conectado en este momento
                  FyH_U_Conexion:TDateTime; //Fecha y Hora de su ultima conexion
                end;

  TipoArchivoJugador = file of TipoRegJugador;

  TipoJugadorControl = file of integer;

  TipoJugador = record
                  D:TipoArchivoJugador;
                  C:TipoJugadorControl;
                  A:TipoAVL;
                  H:TipoHashAbierto;
                end;

  Procedure CrearJugadores(var ME:TipoJugador; Nombre,Ruta:string);
  Procedure AbrirJugadores(var ME:TipoJugador);
  Procedure CerrarJugadores(var ME:TipoJugador);
  Procedure DestruirJugadores(var ME:TipoJugador);

  Function BuscarJugador(var ME:TipoJugador; Nick:TipoNick):boolean;
  Procedure ObtenerJugador(var ME:TipoJugador; Nick:TipoNick; var J:TipoRegJugador);

  Procedure AltaJugador(var ME:TipoJugador; J:TipoRegJugador);
  Procedure AltaJugadorFicticio(var ME:TipoJugador; var J:TipoRegJugador);
  
  Procedure ModificarJugador(var ME:TipoJugador; J:TipoRegJugador);
  Procedure BajaJugador(var ME:TipoJugador; Nick:TipoNick);

  Procedure LogInJugador(var ME:TipoJugador; Nick:TipoNick);
  Procedure LogOutJugador(var ME:TipoJugador; Nick:TipoNick);

implementation

  Procedure CrearJugadores(var ME:TipoJugador; Nombre,Ruta:string);
  var
    Num:integer;
    bControlOK,bControlDatos:boolean;

  begin
    Num:=0;
    Assign(ME.D,Ruta + Nombre + '.info');
    Assign(ME.C,Ruta + Nombre + '.ult');
    {$I-} {Directiva de Compilacion: debilita el control de errores de delphi
    En caso de error, no cierra la aplicacion}
    Reset(ME.C);
    bControlOK := (IOResult = 0);
    Reset(ME.D);
    bControlDatos := (IOResult = 0);
    if (not(bControlOK)) and (not(bControlDatos))
    then begin
      Rewrite(ME.D);
      Rewrite(ME.C);
      seek(ME.C,0);
      write(ME.C,Num);
    end;
    Close(ME.D);
    Close(ME.C);
    CrearAVL(ME.A,Nombre + '-Indice',Ruta);
    CrearHashAbierto(ME.H,Nombre + '-Hash',Ruta);
    {$i+}
  end;

{------------------------------------------------------------------------------}

  Procedure AbrirJugadores(var ME:TipoJugador);
  begin
    Reset(ME.D);
    Reset(ME.C);
    AbrirAVL(ME.A);
    AbrirHashAbierto(ME.H);
  end;

{------------------------------------------------------------------------------}

  Procedure CerrarJugadores(var ME:TipoJugador);
  begin
    Close(ME.D);
    Close(ME.C);
    CerrarAVL(ME.A);
    CerrarHashAbierto(ME.H);
  end;

{------------------------------------------------------------------------------}

  Procedure DestruirJugadores(var ME:TipoJugador);
  begin
    Erase(ME.D);
    Erase(ME.C);
    DestruirAVL(ME.A);
    DestruirHashAbierto(ME.H);
  end;

{------------------------------------------------------------------------------}


  Function BuscarJugador(var ME:TipoJugador; Nick:TipoNick):boolean;
  var
    Pos:TipoPos;

  begin
    BuscarJugador:=BuscarAVL(ME.A,Nick,Pos);
  end;

{------------------------------------------------------------------------------}

  Procedure ObtenerJugador(var ME:TipoJugador; Nick:TipoNick; var J:TipoRegJugador);
  var
    Pos:TipoPos;
    Reg:TipoDatosAbierto;

  begin
    if BuscarHashAbierto(ME.H,Nick,Pos)
    then begin
      CapturarHashAbierto(ME.H,Pos,Reg);
      seek(ME.D,Reg.InfoPos);
      read(ME.D,J);
    end;
  end;

{------------------------------------------------------------------------------}

  Procedure InsertarJugador(var ME:TipoJugador; J:TipoRegJugador);
  var
    PosA,PosH:TipoPos;
    RegA:TipoAVLDatos;
    RegH:TipoDatosAbierto;

  begin
    if not BuscarHashAbierto(ME.H,J.Nick,PosH)
    then begin
      //Inserto el registro indice en el arbol AVL
      RegA.Clave:=J.Nick;
      RegA.InfoPos:=_POSNULA;
      if not BuscarAVL(ME.A,J.Nick,PosA)
      then InsertarAVL(ME.A,RegA,PosA);

      //Inserto su registro homonimo en el archivo HASH
      RegH.Clave:=J.Nick;
      RegH.InfoPos:=FileSize(ME.D);
      AgregarHashAbierto(ME.H,PosH,RegH);

      J.FechaHora:= Now;
      J.FyH_U_Conexion:= J.FechaHora;
      J.Estado:=False;
      //Guardo los datos
      seek(ME.D,RegH.InfoPos);
      read(ME.D,J);

    end;
  end;

{------------------------------------------------------------------------------}

  Procedure AltaJugador(var ME:TipoJugador; J:TipoRegJugador);
  var
    U_Ficticio:integer;

  begin
    seek(ME.C,0);
    read(ME.C,U_Ficticio);
    J.Tipo:=True;
    InsertarJugador(ME,J);
  end;

{------------------------------------------------------------------------------}

  Procedure AltaJugadorFicticio(var ME:TipoJugador; var J:TipoRegJugador);
  var
    U_Ficticio:integer;

  begin
    seek(ME.C,0);
    read(ME.C,U_Ficticio);
    J.Nick:='X_' + PreCerosInteger(4,U_Ficticio);
    J.Clave:='';
    J.Nombre:='Jugador';
    J.Apellidos:='Ficticio';
    J.Foto:=Rutas.RutaSinFoto;
    J.Tipo:=False;
    InsertarJugador(ME,J);
  end;

{------------------------------------------------------------------------------}

  Procedure ModificarJugador(var ME:TipoJugador; J:TipoRegJugador);
  var
    Pos:TipoPos;
    Reg:TipoDatosAbierto;

  begin
    if BuscarHashAbierto(ME.H,J.Nick,Pos)
    then begin
      CapturarHashAbierto(ME.H,Pos,Reg);
      seek(ME.D,Reg.InfoPos);
      write(ME.D,J);
    end;
  end;

{------------------------------------------------------------------------------}

  Procedure BajaJugador(var ME:TipoJugador; Nick:TipoNick);
  var
    PosA,PosH:TipoPos;

  begin
    if BuscarHashAbierto(ME.H,Nick,PosH)
    then begin

      //Elimino el registro indice del arbol AVL
      if BuscarAVL(ME.A,Nick,PosA)
      then EliminarAVL(ME.A,PosA);

      //Elimino el registro HASH
      EliminarHashAbierto(ME.H,PosH);

    end;
  end;

{------------------------------------------------------------------------------}

  Procedure LogInJugador(var ME:TipoJugador; Nick:TipoNick);
  var
    Pos:TipoPos;
    Reg:TipoDatosAbierto;
    J:TipoRegJugador;

  begin
    if BuscarHashAbierto(ME.H,Nick,Pos)
    then begin
      CapturarHashAbierto(ME.H,Pos,Reg);
      J.Estado:=True;
      seek(ME.D,Reg.InfoPos);
      write(ME.D,J);
    end;
  end;

{------------------------------------------------------------------------------}

  Procedure LogOutJugador(var ME:TipoJugador; Nick:TipoNick);
  var
    Pos:TipoPos;
    Reg:TipoDatosAbierto;
    J:TipoRegJugador;

  begin
    if BuscarHashAbierto(ME.H,Nick,Pos)
    then begin
      CapturarHashAbierto(ME.H,Pos,Reg);
      J.Estado:=False;
      seek(ME.D,Reg.InfoPos);
      write(ME.D,J);
    end;
  end;

{------------------------------------------------------------------------------}

end.

