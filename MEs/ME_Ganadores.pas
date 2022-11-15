unit ME_Ganadores;

interface

uses
  LO_ArbolTrinario, Formatos;

const
  _POSNULA = LO_ArbolTrinario._POSNULA;
  _CLAVENULA = LO_ArbolTrinario._CLAVENULA;

type
  TipoNick = LO_ArbolTrinario.TipoClave;
  Pos = TipoPos;

  TipoRegJuego = TipoTriNodo;

  TipoRegGanador = TipoTriDatos;

  TipoRegPremio = record
                    Nomenclador:string[2];
                    Numero:integer;
                    Importe:real;
                    IndexPos:TipoPos;
                  end;

  TipoArchivoPremio = File of TipoRegPremio;

  TipoGanador = record
                    D:TipoArchivoPremio;
                    I:TipoTrinario;
                  end;


    Procedure CrearGanadores(var ME:TipoGanador; Nombre,Ruta:string);
    Procedure DestruirGanadores(var ME:TipoGanador);
    Procedure AbrirGanadores(var ME:TipoGanador);
    Procedure CerrarGanadores(var ME:TipoGanador);

    Function BuscarGanadoresJuego(var ME:TipoGanador; Juego:integer):boolean;
    Procedure InsertarGanadoresJuego(var ME:TipoGanador; Juego:integer);
    Procedure BorrarGanadoresJuego(var ME:TipoGanador; Juego:integer);

    Function BuscarPremioGanador(var ME:TipoGanador; Nick:TipoNick):boolean;
    Procedure CapturarPremioGanador(var ME:TipoGanador; Nick:TipoNick; var Reg:TipoRegPremio);
    Procedure AgregarPremioGanador(var ME:TipoGanador; Nick:TipoNick; Reg:TipoRegPremio);
    Procedure ModificarPremioGanador(var ME:TipoGanador; Nick:TipoNick; Reg:TipoRegPremio);
    Procedure EliminarPremioGanador(var ME:TipoGanador; Nick:TipoNick);

    Function PrimerPremioJuego(var ME:TipoGanador):TipoRegPremio;
    Function UltimoPremioJuego(var ME:TipoGanador):TipoRegPremio;
    Function AnteriorPremioJuego(var ME:TipoGanador; Reg:TipoRegPremio):TipoRegPremio;
    Function ProximoPremioJuego(var ME:TipoGanador; Reg:TipoRegPremio):TipoRegPremio;

implementation

  Procedure CrearGanadores(var ME:TipoGanador; Nombre,Ruta:string);
  var
    bControlDatos:boolean;

  begin
    Assign(ME.D,Ruta + Nombre + '.dat');
    {$I-} {Directiva de Compilacion: debilita el control de errores de delphi
    En caso de error, no cierra la aplicacion}
    Reset(ME.D);
    bControlDatos := (IOResult = 0);
    if not(bControlDatos)
    then Rewrite(ME.D);
    CrearTrinario(ME.I,Nombre);
  end;

{------------------------------------------------------------------------------}

  Procedure DestruirGanadores(var ME:TipoGanador);
  begin
    Erase(ME.D);
    DestruirTrinario(ME.I);
  end;

{------------------------------------------------------------------------------}

  Procedure AbrirGanadores(var ME:TipoGanador);
  begin
    Reset(ME.D);
    AbrirTrinario(ME.I);
  end;

{------------------------------------------------------------------------------}

  Procedure CerrarGanadores(var ME:TipoGanador);
  begin
    Close(ME.D);
    CerrarTrinario(ME.I);
  end;

{------------------------------------------------------------------------------}

  Function BuscarGanadoresJuego(var ME:TipoGanador; Juego:integer):boolean;
  var
    Pos:TipoPos;

  begin
    BuscarGanadoresJuego:=BuscarDatosTrinario(ME.I,PreCerosInteger(8,Juego),pos);
  end;

{------------------------------------------------------------------------------}

  Procedure InsertarGanadoresJuego(var ME:TipoGanador; Juego:integer);
  var
    Pos:TipoPos;
    Reg:TipoRegJuego;

  begin
    Reg.Clave:=PreCerosInteger(8,Juego);
    if not BuscarNodoTrinario(ME.I,Reg.Clave,Pos)
    then InsertarNodoTrinario(ME.I,Reg.Clave,Pos);
  end;

{------------------------------------------------------------------------------}

  Procedure BorrarGanadoresJuego(var ME:TipoGanador; Juego:integer);
  var
    Pos:TipoPos;
    Reg:TipoRegJuego;

  begin
    Reg.Clave:=PreCerosInteger(8,Juego);
    if BuscarNodoTrinario(ME.I,Reg.Clave,Pos)
    then BorrarNodoTrinario(ME.I,Pos);
  end;

{------------------------------------------------------------------------------}

  Function PrimerPremioJuego(var ME:TipoGanador):TipoRegPremio;
  var
    Pos:TipoPos;
    RG:TipoRegGanador;
    Reg:TipoRegPremio;

  begin
    Pos:=PrimerDatosTrinario(ME.I);
    CapturarDatosTrinario(ME.I,Pos,RG);
    seek(ME.D,RG.InfoPos);
    read(ME.D,Reg);
    PrimerPremioJuego:=Reg;
  end;

{------------------------------------------------------------------------------}

  Function UltimoPremioJuego(var ME:TipoGanador):TipoRegPremio;
  var
    Pos:TipoPos;
    RG:TipoRegGanador;
    Reg:TipoRegPremio;

  begin
    Pos:=UltimoDatosTrinario(ME.I);
    CapturarDatosTrinario(ME.I,Pos,RG);
    seek(ME.D,RG.InfoPos);
    read(ME.D,Reg);
    UltimoPremioJuego:=Reg;
  end;

{------------------------------------------------------------------------------}

  Function AnteriorPremioJuego(var ME:TipoGanador; Reg:TipoRegPremio):TipoRegPremio;
  var
    RG:TipoRegGanador;

  begin
    CapturarDatosTrinario(ME.I,AnteriorDatosTrinario(ME.I,Reg.IndexPos),RG);
    seek(ME.D,RG.InfoPos);
    read(ME.D,Reg);
    AnteriorPremioJuego:=Reg;
  end;

{------------------------------------------------------------------------------}

  Function ProximoPremioJuego(var ME:TipoGanador; Reg:TipoRegPremio):TipoRegPremio;
  var
    RG:TipoRegGanador;

  begin
    CapturarDatosTrinario(ME.I,ProximoDatosTrinario(ME.I,Reg.IndexPos),RG);
    seek(ME.D,RG.InfoPos);
    read(ME.D,Reg);
    ProximoPremioJuego:=Reg;
  end;

{------------------------------------------------------------------------------}

  Function BuscarPremioGanador(var ME:TipoGanador; Nick:TipoNick):boolean;
  var
    Pos:TipoPos;

  begin
    BuscarPremioGanador:=BuscarDatosTrinario(ME.I,Nick,Pos);
  end;

{------------------------------------------------------------------------------}

  Procedure CapturarPremioGanador(var ME:TipoGanador; Nick:TipoNick; var Reg:TipoRegPremio);
  var
    RG:TipoRegGanador;
    Pos:TipoPos;

  begin
    if BuscarDatosTrinario(ME.I,Nick,Pos)
    then CapturarDatosTrinario(ME.I,Pos,RG);
    seek(ME.D,RG.InfoPos);
    read(ME.D,Reg);
  end;

{------------------------------------------------------------------------------}

  Procedure AgregarPremioGanador(var ME:TipoGanador; Nick:TipoNick; Reg:TipoRegPremio);
   var
    RG:TipoRegGanador;
    Pos:TipoPos;

  begin
    RG.Clave:=Nick;
    if not BuscarDatosTrinario(ME.I,Nick,Pos)
    then AgregarDatosTrinario(ME.I,RG,Pos);

    Reg.IndexPos:=Pos;
    seek(ME.D,RG.InfoPos);
    write(ME.D,Reg);
  end;

{------------------------------------------------------------------------------}

  Procedure ModificarPremioGanador(var ME:TipoGanador; Nick:TipoNick; Reg:TipoRegPremio);
  var
    RG:TipoRegGanador;
    Pos:TipoPos;

  begin
    if BuscarDatosTrinario(ME.I,Nick,Pos)
    then CapturarDatosTrinario(ME.I,Pos,RG);
    seek(ME.D,RG.InfoPos);
    write(ME.D,Reg);
  end;

{------------------------------------------------------------------------------}

  Procedure EliminarPremioGanador(var ME:TipoGanador; Nick:TipoNick);
  var
    Pos:TipoPos;

  begin
    if BuscarDatosTrinario(ME.I,Nick,Pos)
    then EliminarDatosTrinario(ME.I,pos);
  end;

{------------------------------------------------------------------------------}

end.
