unit ME_Jugadores;

  {El arbol binario AVL servira como un indice para todos los jugadores que hayan
  sido ingresados al sistema.

  Por su parte, el HashAbierto servira para localizar a los jugadores que
  esten logeados al sistema en ese momento.}
interface

uses
  LO_ArbolAVL, LO_HashAbierto, Formatos, Rutas, SysUtils;

const
  _POSNULA = LO_ArbolAVL._POSNULA;
  _CLAVENULA = LO_ArbolAVL._CLAVENULA;
  _MAX_LOGGED = LO_HashAbierto.MaxHash; {Cantidad maxima de jugadores que pueden
  estar logeados = cantidad maxima de registros que puede almacenar HashAbierto}

type
  TipoNick = TipoClave;
  TipoPass = string[12];

  TipoRegLogged = TipoDatosAbierto;

  TipoRegIndice = TipoAVLDatos;

  TipoRegJugador = record
                  Nick:TipoNick; //ID del jugador en el sistema
                  Clave:TipoPass; //Contraseña
                  Nombre:string[100];
                  Apellidos:string[100];
                  FechaHora:TDateTime; //Fecha y Hora de su registro
                  Foto:string[255]; //URL del archivo
                  Tipo:boolean; //Si es real o ficticio
                  Bloqueado:boolean; //Si el jugador puede o no apostar
                  Cerrado:boolean; //Si la cuenta fue o no cerrada por el jugador
                  FyH_U_Conexion:TDateTime; //Fecha y Hora de su ultima conexion
                end;

  TipoArchivoJugador = file of TipoRegJugador;

  TipoJugadorControl = record
                         UltFicticio:integer; //Ultimo jugador ficticio creado
                         CantLogged:integer; //Cantidad de jugadores logeados
                       end;

  TipoArchCJugador = file of TipoJugadorControl;

  TipoJugador = record
                  D:TipoArchivoJugador;
                  C:TipoArchCJugador;
                  I:TipoAVL;
                  L:TipoHashAbierto;
                end;

  Procedure CrearJugadores(var ME:TipoJugador; Nombre,Ruta:string);
  Procedure AbrirJugadores(var ME:TipoJugador);
  Procedure CerrarJugadores(var ME:TipoJugador);
  Procedure DestruirJugadores(var ME:TipoJugador);

  Function BuscarJugador(var ME:TipoJugador; Nick:TipoNick):boolean;
  Procedure CapturarJugador(var ME:TipoJugador; Nick:TipoNick; var J:TipoRegJugador);

  Procedure AltaJugador(var ME:TipoJugador; J:TipoRegJugador);
  Procedure AltaJugadorFicticio(var ME:TipoJugador; var J:TipoRegJugador);

  Procedure ModificarJugador(var ME:TipoJugador; J:TipoRegJugador);
  Procedure BajaJugador(var ME:TipoJugador; Nick:TipoNick);

  Function JugadorCerrado(var ME:TipoJugador; Nick:TipoNick):boolean;
  Procedure CerrarJugador(var ME:TipoJugador; Nick:TipoNick);
  Procedure RestaurarJugador(var ME:TipoJugador; Nick:TipoNick);

  Function JugadorBloqueado(var ME:TipoJugador; Nick:TipoNick):boolean;
  Procedure BloquearJugador(var ME:TipoJugador; Nick:TipoNick);
  Procedure DesbloquearJugador(var ME:TipoJugador; Nick:TipoNick);

  Function LoggedJugador(var ME:TipoJugador; Nick:TipoNick):boolean;
  Procedure LogInJugador(var ME:TipoJugador; Nick:TipoNick);
  Procedure LogOutJugador(var ME:TipoJugador; Nick:TipoNick);

  Function LogPosible(var ME:TipoJugador):boolean;
  Function ClaveEnUso(var ME:TipoJugador; Pass:TipoPass):boolean;

implementation

  Procedure CrearJugadores(var ME:TipoJugador; Nombre,Ruta:string);
  var
    RC:TipoJugadorControl;
    bControlOK,bControlDatos:boolean;

  begin
    Assign(ME.D,Ruta + Nombre + '.dat');
    Assign(ME.C,Ruta + Nombre + '.con');
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
      RC.UltFicticio:=0;
      RC.CantLogged:=0;
      seek(ME.C,0);
      write(ME.C,RC);
    end;
    Close(ME.D);
    Close(ME.C);
    CrearAVL(ME.I,Nombre + '-Index',Ruta);
    CrearHashAbierto(ME.L,Nombre + '-Logged',Ruta);
    {$i+}
  end;

{------------------------------------------------------------------------------}

  Procedure AbrirJugadores(var ME:TipoJugador);
  begin
    Reset(ME.D);
    Reset(ME.C);
    AbrirAVL(ME.I);
    AbrirHashAbierto(ME.L);
  end;

{------------------------------------------------------------------------------}

  Procedure CerrarJugadores(var ME:TipoJugador);
  begin
    Close(ME.D);
    Close(ME.C);
    CerrarAVL(ME.I);
    CerrarHashAbierto(ME.L);
  end;

{------------------------------------------------------------------------------}

  Procedure DestruirJugadores(var ME:TipoJugador);
  begin
    Erase(ME.D);
    Erase(ME.C);
    DestruirAVL(ME.I);
    DestruirHashAbierto(ME.L);
  end;

{------------------------------------------------------------------------------}

  Function BuscarJugador(var ME:TipoJugador; Nick:TipoNick):boolean;
  var
    Pos:TipoPos;

  begin
    BuscarJugador:=BuscarAVL(ME.I,Nick,Pos);
  end;

{------------------------------------------------------------------------------}

  Procedure CapturarJugador(var ME:TipoJugador; Nick:TipoNick; var J:TipoRegJugador);
  var
    Pos:TipoPos;
    Reg:TipoRegIndice;

  begin
    if BuscarAVL(ME.I,Nick,Pos)
    then CapturarAVL(ME.I,Pos,Reg);
    seek(ME.D,Reg.InfoPos);
    read(ME.D,J);
  end;

{------------------------------------------------------------------------------}

  Procedure InsertarJugador(var ME:TipoJugador; J:TipoRegJugador);
  var
    Pos:TipoPos;
    Reg:TipoRegIndice;

  begin
    //Inserto el registro indice en el arbol AVL
    Reg.Clave:=J.Nick;
    Reg.InfoPos:=FileSize(ME.D);
    if not BuscarAVL(ME.I,J.Nick,Pos)
    then InsertarAVL(ME.I,Reg,Pos);

    J.FechaHora:= Now;
    J.FyH_U_Conexion:= J.FechaHora;
    J.Bloqueado:=False;
    J.Cerrado:=False;
    //Guardo los datos
    seek(ME.D,Reg.InfoPos);
    write(ME.D,J);
  end;

{------------------------------------------------------------------------------}

  Procedure AltaJugador(var ME:TipoJugador; J:TipoRegJugador);

  begin
    J.Tipo:=True;
    InsertarJugador(ME,J);
  end;

{------------------------------------------------------------------------------}

  Procedure AltaJugadorFicticio(var ME:TipoJugador; var J:TipoRegJugador);
  var
    RC:TipoJugadorControl;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    RC.UltFicticio:=RC.UltFicticio + 1;
    J.Nick:='X_' + PreCerosInteger(6,RC.UltFicticio);
    J.Clave:='';
    J.Nombre:='Jugador';
    J.Apellidos:=inttostr(RC.UltFicticio);
    J.Foto:=Rutas.RutaSinFoto;
    J.Tipo:=False;
    InsertarJugador(ME,J);
    seek(ME.C,0);
    write(ME.C,RC);
  end;

{------------------------------------------------------------------------------}

  Procedure ModificarJugador(var ME:TipoJugador; J:TipoRegJugador);
  var
    Pos:TipoPos;
    Reg:TipoRegIndice;

  begin
    if BuscarAVL(ME.I,J.Nick,Pos)
    then begin
      CapturarAVL(ME.I,Pos,Reg);
      seek(ME.D,Reg.InfoPos);
      write(ME.D,J);
    end;
  end;

{------------------------------------------------------------------------------}

  Procedure BajaJugador(var ME:TipoJugador; Nick:TipoNick);
  {Solo se elimina el acceso a los datos desde el arbol AVL, ya que sera a traves
  de este que el jugador puede acceder al sistema. El administrador podra
  ver los datos del jugador desde el acceso por Hash}
  var
    Pos:TipoPos;

  begin
    //Elimino el registro indice del arbol AVL
    if BuscarAVL(ME.I,Nick,Pos)
    then EliminarAVL(ME.I,Pos);
  end;

{------------------------------------------------------------------------------}

  Function JugadorCerrado(var ME:TipoJugador; Nick:TipoNick):boolean;
  var
    Pos:TipoPos;
    J:TipoRegJugador;
    Reg:TipoRegIndice;

  begin
    if BuscarAVL(ME.I,Nick,Pos)
    then CapturarAVL(ME.I,Pos,Reg);
    seek(ME.D,Reg.InfoPos);
    read(ME.D,J);
    JugadorCerrado:=J.Cerrado;
  end;

{------------------------------------------------------------------------------}

  Procedure CerrarJugador(var ME:TipoJugador; Nick:TipoNick);
  var
    Pos:TipoPos;
    J:TipoRegJugador;
    Reg:TipoRegLogged;

  begin
    if BuscarHashAbierto(ME.L,Nick,Pos)
    then CapturarHashAbierto(ME.L,Pos,Reg);
    seek(ME.D,Reg.InfoPos);
    read(ME.D,J);
    J.Cerrado:=True;
    seek(ME.D,Reg.InfoPos);
    write(ME.D,J);
  end;

{------------------------------------------------------------------------------}

  Procedure RestaurarJugador(var ME:TipoJugador; Nick:TipoNick);
  var
    Pos:TipoPos;
    J:TipoRegJugador;
    Reg:TipoRegIndice;

  begin
    if BuscarAVL(ME.I,Nick,Pos)
    then CapturarAVL(ME.I,Pos,Reg);
    seek(ME.D,Reg.InfoPos);
    read(ME.D,J);
    J.Cerrado:=False;
    seek(ME.D,Reg.InfoPos);
    write(ME.D,J);
  end;

{------------------------------------------------------------------------------}

  Function JugadorBloqueado(var ME:TipoJugador; Nick:TipoNick):boolean;
  var
    Pos:TipoPos;
    J:TipoRegJugador;
    Reg:TipoRegIndice;

  begin
    if BuscarAVL(ME.I,Nick,Pos)
    then CapturarAVL(ME.I,Pos,Reg);
    seek(ME.D,Reg.InfoPos);
    read(ME.D,J);
    JugadorBloqueado:=J.Bloqueado;
  end;

{------------------------------------------------------------------------------}

  Procedure BloquearJugador(var ME:TipoJugador; Nick:TipoNick);
  var
    Pos:TipoPos;
    J:TipoRegJugador;
    Reg:TipoRegIndice;

  begin
    if BuscarAVL(ME.I,Nick,Pos)
    then CapturarAVL(ME.I,Pos,Reg);
    seek(ME.D,Reg.InfoPos);
    read(ME.D,J);
    J.Bloqueado:=True;
    seek(ME.D,Reg.InfoPos);
    write(ME.D,J);
  end;

{------------------------------------------------------------------------------}

  Procedure DesbloquearJugador(var ME:TipoJugador; Nick:TipoNick);
  var
    Pos:TipoPos;
    J:TipoRegJugador;
    Reg:TipoRegIndice;

  begin
    if BuscarAVL(ME.I,Nick,Pos)
    then CapturarAVL(ME.I,Pos,Reg);
    seek(ME.D,Reg.InfoPos);
    read(ME.D,J);
    J.Bloqueado:=False;
    seek(ME.D,Reg.InfoPos);
    write(ME.D,J);
  end;

{------------------------------------------------------------------------------}

  Function LoggedJugador(var ME:TipoJugador; Nick:TipoNick):boolean;
  var
    Pos:TipoPos;

  begin
    LoggedJugador:=BuscarHashAbierto(ME.L,Nick,Pos);
  end;

{------------------------------------------------------------------------------}

  Procedure LogInJugador(var ME:TipoJugador; Nick:TipoNick);
  var
    Pos:TipoPos;
    RI:TipoRegIndice;
    Reg:TipoRegLogged;
    J:TipoRegJugador;

  begin
    if BuscarAVL(ME.I,Nick,Pos)
    then CapturarAVL(ME.I,Pos,RI);

    Reg.InfoPos:=RI.InfoPos;
    if not BuscarHashAbierto(ME.L,Nick,Pos)
    then begin
      AgregarHashAbierto(ME.L,Pos,Reg);
      seek(ME.D,Reg.InfoPos);
      read(ME.D,J);
      J.FyH_U_Conexion:=Now;
      seek(ME.D,Reg.InfoPos);
      write(ME.D,J);
    end;
  end;

{------------------------------------------------------------------------------}

  Procedure LogOutJugador(var ME:TipoJugador; Nick:TipoNick);
  var
    Pos:TipoPos;

  begin
    if BuscarHashAbierto(ME.L,Nick,Pos)
    then EliminarHashAbierto(ME.L,Pos);
  end;

{------------------------------------------------------------------------------}
  Function LogPosible(var ME:TipoJugador):boolean;
  var
    RC:TipoJugadorControl;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    LogPosible:= RC.CantLogged < _MAX_LOGGED;
  end;

{------------------------------------------------------------------------------}
  Function ClaveEnUso(var ME:TipoJugador; Pass:TipoPass):boolean;
  var
    Pos:TipoPos;
    Reg:TipoRegIndice;
    J:TipoRegJugador;
    EnUso:boolean;

  begin
    EnUso:=False;
    Pos:=PrimeroAVL(ME.I);
    While (Pos <> _POSNULA) and not EnUso
    do begin
      CapturarAVL(ME.I,Pos,Reg);
      seek(ME.D,Reg.InfoPos);
      read(ME.D,J);
      if J.Clave = Pass
      then EnUso:=True;
      Pos:=ProximoAVL(ME.I,Pos);
    end;
    ClaveEnUso:=EnUso;
  end;
{------------------------------------------------------------------------------}

end.

