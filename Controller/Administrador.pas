unit Administrador;

interface

uses
  ME_Jugadores, ME_Cuentas, Rutas;

   procedure CrearCroupier(var Jugadores:TipoJugador; var Cuentas:TipoCuenta);
   Function CroupierConectado(var Jugadores:TipoJugador):boolean;

implementation



  procedure CrearCroupier(var Jugadores:TipoJugador; var Cuentas:TipoCuenta);
  var
    ADMIN:TipoRegJugador;
    Minimo:real;

  begin
    //Creo al jugador/usuario 'croupier'
    ADMIN.Nick:='croupier';
    ADMIN.Clave:='mondongo';
    ADMIN.Nombre:='Administrador';
    ADMIN.Apellidos:='Sistema';
    ADMIN.Foto:=RutaSinFoto;
    AltaJugador(Jugadores,ADMIN);
    //Creo la cuenta corriente de la casa, y dejo su saldo en 0
    Minimo:=ObtenerMinimo(Cuentas);
    AltaCuenta(Cuentas,ADMIN.Nick,Minimo);
    AnularSaldo(Cuentas,ADMIN.Nick,Minimo);
  end;

  Function CroupierConectado(var Jugadores:TipoJugador):boolean;
  begin
    CroupierConectado:=LoggedJugador(Jugadores,'croupier');
  end;

end.
 