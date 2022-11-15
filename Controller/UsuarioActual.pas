unit UsuarioActual;

interface

uses
  SysUtils, ME_Jugadores, Administrador, ControladorLibrerias, Classes, Forms;


type
  TipoRuta = String;
  Function LogIn(Nick:TipoNick; Pass:TipoPass):boolean;
  Function Logged(Nick:TipoNick):boolean;
  procedure LogOut;

var
  Usuario:ME_Jugadores.TipoRegJugador;

implementation

  Function LogIn(Nick:TipoNick; Pass:TipoPass):boolean;
  var
    J:TipoRegJugador;
    Correcto:boolean;

  begin
    Correcto:=False;
    if BuscarJugador(Jugadores,Nick)
    then begin
      CapturarJugador(Jugadores,Nick,J);
      if J.Clave = Pass
      then begin
        LogInJugador(Jugadores,Nick);
        CapturarJugador(Jugadores,Nick,Usuario);
        Correcto:=True;
      end;
    end;
    LogIn:=Correcto;
  end;

  Function Logged(Nick:TipoNick):boolean;
  begin
    Logged:=LoggedJugador(Jugadores,Nick);
  end;

  procedure LogOut;
  begin
    LogOutJugador(Jugadores,Usuario.Nick);
  end;

end.
