unit ControladorLibrerias;

interface

uses
  SysUtils, ME_Jugadores, ME_Cuentas, ME_Ruleta, Administrador, Rutas, Classes, Forms;


type
  TipoRuta = String;
  procedure Iniciar;
  procedure Abrir;
  procedure Cerrar;
  procedure Terminar;

var
  Jugadores:ME_Jugadores.TipoJugador;
  Cuentas:ME_Cuentas.TipoCuenta;
  Ruleta:ME_Ruleta.TipoRuleta;

implementation

  procedure Abrir;
  begin
    AbrirJugadores(Jugadores);
    AbrirCuentas(Cuentas);
    AbrirRuleta(Ruleta);
  end;

  procedure Iniciar;
  begin
    CrearJugadores(Jugadores,'Jugadores',RutaJugadores);
    CrearCuentas(Cuentas,'Cuentas',RutaCuentas);
    CrearRuleta(Ruleta,'Ruleta',RutaRuleta);
    Abrir;
    if not BuscarJugador(Jugadores,'croupier')
    then CrearCroupier(Jugadores, Cuentas);
  end;

  procedure Cerrar;
  begin
    CerrarJugadores(Jugadores);
    CerrarCuentas(Cuentas);
    CerrarRuleta(Ruleta);
  end;

  procedure Terminar;
  begin
    Cerrar;
    DestruirJugadores(Jugadores);
    DestruirCuentas(Cuentas);
    DestruirRuleta(Ruleta);
    Application.Terminate();
  end;
end.
