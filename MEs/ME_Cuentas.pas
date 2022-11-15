unit ME_Cuentas;

interface

uses
  LO_HashCerrado, StrUtils, SysUtils;

const

  _POSNULA = LO_HashCerrado._POSNULA;
  _CLAVENULA = LO_HashCerrado._CLAVENULA;

type
  TipoNick = TipoClave;
  TipoPos = LO_HashCerrado.TipoPos;
  TipoRegCuenta = TipoDatosCerrado;
  TipoRegAsiento = record
                  FechaHora:TDateTime; //Fecha y Hora de su registro
                  Concepto:string[100]; //Identifica la accion
                  Debe,Haber,Saldo:real; //Datos del asiento
                  Enlace:TipoPos;
                end;

  TipoArchivoCuenta = file of TipoRegAsiento;

  TipoCuentaControl = file of real;

  TipoCuenta = record
                  D:TipoArchivoCuenta;
                  C:TipoCuentaControl;
                  H:TipoHashCerrado;
                end;

  Procedure CrearCuentas(var ME:TipoCuenta; Nombre,Ruta:string);
  Procedure AbrirCuentas(var ME:TipoCuenta);
  Procedure CerrarCuentas(var ME:TipoCuenta);
  Procedure DestruirCuentas(var ME:TipoCuenta);

  Function BuscarCuenta(var ME:TipoCuenta; Nick:TipoNick):boolean;
  Function CuentaAbierta(var ME:TipoCuenta; Nick:TipoNick):boolean;
  Function SaldoCuenta(var ME:TipoCuenta; Nick:TipoNick):real;

  Procedure AltaCuenta(var ME:TipoCuenta; Nick:TipoNick; Monto:Real);
  Procedure ComprarFichas(var ME:TipoCuenta; Nick:TipoNick; Monto:Real);
  Procedure RetirarSaldo(var ME:TipoCuenta; Nick:TipoNick; Monto:Real);
  Procedure AnularSaldo(var ME:TipoCuenta; Nick:TipoNick; Monto:Real);
  Procedure ApuestaJuego(var ME:TipoCuenta; Nick:TipoNick; Monto:real; Juego:integer);
  Procedure PremioJuego(var ME:TipoCuenta; Nick:TipoNick; Monto:real; Juego:integer);
  Procedure RegaloJuego(var ME:TipoCuenta; Nick:TipoNick; Monto:real; Juego:integer);
  Procedure BajaCuenta(var ME:TipoCuenta; Nick:TipoNick);

  Function PrimerAsientoCuenta(var ME:TipoCuenta; Nick:TipoNick):TipoRegAsiento;
  Function ProximoAsientoCuenta(var ME:TipoCuenta; Reg:TipoRegAsiento):TipoRegAsiento;
  Function UltimoAsientoCuenta(var ME:TipoCuenta; Reg:TipoRegAsiento):TipoRegAsiento;

  Function ObtenerMinimo(var ME:TipoCuenta):real;
  Procedure DefinirMinimo(var ME:TipoCuenta; Monto:real);

  Function PosNula:TipoPos;

implementation

  Procedure CrearCuentas(var ME:TipoCuenta; Nombre,Ruta:string);
  var
    Num:real;
    bControlOK,bControlDatos:boolean;

  begin
    Num:=1000;
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
      seek(ME.C,0);
      write(ME.C,Num);
    end;
    Close(ME.D);
    Close(ME.C);
    CrearHashCerrado(ME.H,Nombre + '-Hash',Ruta);
    {$i+}
  end;

{------------------------------------------------------------------------------}

  Procedure AbrirCuentas(var ME:TipoCuenta);
  begin
    Reset(ME.D);
    Reset(ME.C);
    AbrirHashCerrado(ME.H);
  end;

{------------------------------------------------------------------------------}

  Procedure CerrarCuentas(var ME:TipoCuenta);
  begin
    Close(ME.D);
    Close(ME.C);
    CerrarHashCerrado(ME.H);
  end;

{------------------------------------------------------------------------------}

  Procedure DestruirCuentas(var ME:TipoCuenta);
  begin
    Erase(ME.D);
    Erase(ME.C);
    DestruirHashCerrado(ME.H);
  end;

{------------------------------------------------------------------------------}

  Function BuscarCuenta(var ME:TipoCuenta; Nick:TipoNick):boolean;
  var
    Pos:TipoPos;

  begin
    BuscarCuenta:=BuscarHashCerrado(ME.H,Nick,Pos);
  end;

{------------------------------------------------------------------------------}

  Function CuentaAbierta(var ME:TipoCuenta; Nick:TipoNick):boolean;
  var
    Reg:TipoRegAsiento;

  begin
    Reg:=PrimerAsientoCuenta(ME,Nick);
    Reg:=UltimoAsientoCuenta(ME,Reg);
    CuentaAbierta:=(Reg.Concepto <> 'Baja de Cuenta');
  end;

{------------------------------------------------------------------------------}

  Function SaldoCuenta(var ME:TipoCuenta; Nick:TipoNick):real;
  var
    Reg:TipoRegAsiento;

  begin
    Reg:=PrimerAsientoCuenta(ME,Nick);
    Reg:=UltimoAsientoCuenta(ME,Reg);
    SaldoCuenta:=Reg.Saldo;
  end;

{------------------------------------------------------------------------------}

  Procedure AltaCuenta(var ME:TipoCuenta; Nick:TipoNick; Monto:Real);
  var
    Pos:TipoPos;
    RCuenta:TipoRegCuenta;
    Minimo:real;
    Reg:TipoRegAsiento;

  begin
    //Obtengo el monto minimo para abrir una cuenta
    seek(ME.C,0);
    read(ME.C,Minimo);

    //Ingreso el registro indice en el archivo Hash, y guardo la posicion del primer asiento
    RCuenta.Clave:=Nick;
    RCuenta.InfoPos:=FileSize(ME.D);
    if not BuscarHashCerrado(ME.H,Nick,Pos)
    then AgregarHashCerrado(ME.H,Pos,RCuenta);

    //Lleno, con los datos de la apertura de la cuenta, el nuevo asiento y lo guardo
    Reg.FechaHora:=Now;
    Reg.Concepto:='Alta de Cuenta';
    if Monto < Minimo
    then Reg.Debe:= Minimo
    else Reg.Debe:= Monto;
    Reg.Haber:=0;
    Reg.Saldo:=Reg.Debe;
    Reg.Enlace:=_POSNULA;
    
    seek(ME.D,RCuenta.InfoPos);
    write(ME.D,Reg);
  end;

{------------------------------------------------------------------------------}

  Procedure NuevoAsiento(var ME:TipoCuenta; Reg:TipoRegAsiento; Nick:TipoNick);
  var
    Pos:TipoPos;
    RCuenta:TipoRegCuenta;
    Raux:TipoRegAsiento;

  begin

    if BuscarHashCerrado(ME.H,Nick,Pos)
    then CapturarHashCerrado(ME.H,Pos,RCuenta);
    Pos:=RCuenta.InfoPos;

    //Obtengo el ultimo registro de la lista
    While Raux.Enlace <> _POSNULA
    do begin
      seek(ME.D,Pos);
      read(ME.D,Raux);
      if Raux.Enlace <> _POSNULA
      then Pos:=Raux.Enlace;
    end;
    Raux.Enlace:=FileSize(ME.D);

    //Lleno los datos del nuevo asiento y guardo los ultimos dos
    Reg.FechaHora:=Now;
    if Reg.Saldo = -1 //El nuevo asiento es una baja de cuenta
    then Reg.Haber:=Raux.Saldo;
    Reg.Saldo:=Raux.Saldo - Reg.Haber + Reg.Debe;
    Reg.Enlace:=_POSNULA;

    seek(ME.D,Pos);
    write(ME.D,Raux);
    seek(ME.D,Raux.Enlace);
    write(ME.D,Reg);
  end;


{------------------------------------------------------------------------------}

  Procedure ComprarFichas(var ME:TipoCuenta; Nick:TipoNick; Monto:real);
  var
    Reg:TipoRegAsiento;

  begin
    Reg.Concepto:='Compra Fichas';
    Reg.Debe:=Monto;
    Reg.Haber:=0;
    NuevoAsiento(ME,Reg,Nick);
  end;

{------------------------------------------------------------------------------}

  Procedure RetirarSaldo(var ME:TipoCuenta; Nick:TipoNick; Monto:real);
  var
    Reg:TipoRegAsiento;

  begin

    Reg.Concepto:='Retiro Saldo';
    Reg.Debe:=0;
    Reg.Haber:=Monto;
    NuevoAsiento(ME,Reg,Nick);
  end;

{------------------------------------------------------------------------------}

  Procedure AnularSaldo(var ME:TipoCuenta; Nick:TipoNick; Monto:real);
  var
    Reg:TipoRegAsiento;

  begin

    Reg.Concepto:='Anular Saldo';
    Reg.Debe:=0;
    Reg.Haber:=Monto;
    NuevoAsiento(ME,Reg,Nick);
  end;

{------------------------------------------------------------------------------}

  Procedure ApuestaJuego(var ME:TipoCuenta; Nick:TipoNick; Monto:real; Juego:integer);
  var
    Reg:TipoRegAsiento;

  begin

    Reg.Concepto:='Apuesta Juego ' + inttostr(Juego);
    Reg.Debe:=0;
    Reg.Haber:=Monto;
    NuevoAsiento(ME,Reg,Nick);
  end;

{------------------------------------------------------------------------------}

  Procedure PremioJuego(var ME:TipoCuenta; Nick:TipoNick; Monto:real; Juego:integer);
  var
    Reg:TipoRegAsiento;

  begin

    Reg.Concepto:='Premio Juego ' + inttostr(Juego);
    Reg.Debe:=Monto;
    Reg.Haber:=0;
    NuevoAsiento(ME,Reg,Nick);
  end;

{------------------------------------------------------------------------------}

  Procedure RegaloJuego(var ME:TipoCuenta; Nick:TipoNick; Monto:real; Juego:integer);
  var
    Reg:TipoRegAsiento;

  begin

    Reg.Concepto:='Regalo Juego ' + inttostr(Juego);
    Reg.Debe:=Monto;
    Reg.Haber:=0;
    NuevoAsiento(ME,Reg,Nick);
  end;

{------------------------------------------------------------------------------}

  Procedure BajaCuenta(var ME:TipoCuenta; Nick:TipoNick);
  var
    Reg:TipoRegAsiento;

  begin

    Reg.Concepto:='Baja de Cuenta';
    Reg.Debe:=0; //El campo Haber se llenara en NuevoAsiento
    Reg.Saldo:=-1; //Identifica al nuevo asiento como una baja de cuenta
    NuevoAsiento(ME,Reg,Nick);
  end;

{------------------------------------------------------------------------------}

  Function PrimerAsientoCuenta(var ME:TipoCuenta; Nick:TipoNick):TipoRegAsiento;
  var
    Pos:TipoPos;
    RHash:TipoDatosCerrado;
    Reg:TipoRegAsiento;

  begin
    //Obtengo registro indice del archivo Hash y lo elimino
    if BuscarHashCerrado(ME.H,Nick,Pos)
    then CapturarHashCerrado(ME.H,Pos,RHash);
    seek(ME.D,RHash.InfoPos);
    read(ME.D,Reg);
    PrimerAsientoCuenta:=Reg;
  end;

{------------------------------------------------------------------------------}

  Function ProximoAsientoCuenta(var ME:TipoCuenta; Reg:TipoRegAsiento):TipoRegAsiento;
  //Si Proximo devuelve como concepto 'EoF', entonces el parametro Reg es el ultimo asiento

  begin
    if Reg.Enlace <> _POSNULA
    then begin
      seek(ME.D,Reg.Enlace);
      read(ME.D,Reg);
    end
    else Reg.Concepto:='EoF';
    ProximoAsientoCuenta:=Reg;
  end;

{------------------------------------------------------------------------------}

  Function UltimoAsientoCuenta(var ME:TipoCuenta; Reg:TipoRegAsiento):TipoRegAsiento;

  begin
    While Reg.Enlace <> _POSNULA
    do begin
      seek(ME.D,Reg.Enlace);
      read(ME.D,Reg);
    end;
    UltimoAsientoCuenta:=Reg;
  end;

{------------------------------------------------------------------------------}

  Function ObtenerMinimo(var ME:TipoCuenta):real;
  var
    Monto:real;

  begin
    seek(ME.C,0);
    read(ME.C,Monto);
    ObtenerMinimo:=Monto;
  end;

{------------------------------------------------------------------------------}

  Procedure DefinirMinimo(var ME:TipoCuenta; Monto:real);

  begin
    seek(ME.C,0);
    write(ME.C,Monto);
  end;

{------------------------------------------------------------------------------}

  Function PosNula:TipoPos; //Si .Enlace = _POSNULA, entonces no hay mas asientos
  begin
    PosNula:=_POSNULA;
  end;

{------------------------------------------------------------------------------}

end.
