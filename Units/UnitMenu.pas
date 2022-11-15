unit UnitMenu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UsuarioActual, ControladorLibrerias, ExtCtrls;

type
  TfMenu = class(TForm)
    bLogout: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    GroupBox2: TGroupBox;
    bUpdate: TButton;
    bClose: TButton;
    imgFoto: TImage;
    lNick: TLabel;
    lNom: TLabel;
    lApe: TLabel;
    grbFichas: TGroupBox;
    eMonto: TEdit;
    Label5: TLabel;
    bBuy: TButton;
    GroupBox3: TGroupBox;
    lStatus: TLabel;
    lPremio: TLabel;
    bPass: TButton;
    bMoves: TButton;
    bRetirar: TButton;
    Label4: TLabel;
    lSaldo: TLabel;
    lMonto: TLabel;
    procedure bLogoutlick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bUpdateClick(Sender: TObject);
    procedure bPassClick(Sender: TObject);
    procedure bMovesClick(Sender: TObject);
    procedure bCloseClick(Sender: TObject);
    procedure bBuyClick(Sender: TObject);
    procedure bRetirarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fMenu: TfMenu;

implementation

uses
  Formatos, ManejadorErrores,
  ME_Jugadores, ME_Cuentas,
  UnitLogin, UnitMod, UnitPass, UnitMoves, UnitBaja;

{$R *.dfm}

procedure TfMenu.bLogoutlick(Sender: TObject);
begin
  LogOut;
  fLogin.Show;
  fMenu.Hide;
end;

procedure TfMenu.FormShow(Sender: TObject);
var
  Reg:TipoRegJugador;
  
begin
  CapturarJugador(Jugadores,Usuario.Nick,Reg);
  lNick.Caption:=Usuario.Nick;
  lNom.Caption:=Usuario.Nombre;
  lApe.Caption:=Usuario.Apellidos;
  lSaldo.Caption:=floattostr(SaldoCuenta(Cuentas,Usuario.Nick));
end;

procedure TfMenu.bUpdateClick(Sender: TObject);
begin
  fMod.Show;
  fMenu.Hide;
end;

procedure TfMenu.bPassClick(Sender: TObject);
begin
  fPass.Show;
  fMenu.Hide;
end;

procedure TfMenu.bMovesClick(Sender: TObject);
begin
  fMoves.Show;
  fMenu.Hide;
end;

procedure TfMenu.bCloseClick(Sender: TObject);
begin
  fBaja.Show;
  fMenu.Hide;
end;

procedure TfMenu.bBuyClick(Sender: TObject);
var
  flagMonto:boolean;
  Monto:real;

begin
  flagMonto:=False;
  if not StringVacio(eMonto.Text)
  then if EsNumerico(eMonto.Text)
    then begin
      Monto:=strtofloat(eMonto.Text);
      if Monto >= 0
      then flagMonto:=True
      else lMonto.Caption:=Error(402); //El monto es menor a cero
    end
    else lMonto.Caption:=Error(203) //El monto no es valido
  else lMonto.Caption:=Error(104); //Campo vacio

  if flagMonto
  then begin
    ComprarFichas(Cuentas,Usuario.Nick,Monto);
    ShowMessage(Error(0));
    lSaldo.Caption:=floattostr(SaldoCuenta(Cuentas,Usuario.Nick));
  end;
end;

procedure TfMenu.bRetirarClick(Sender: TObject);
var
  flagMonto:boolean;
  Monto:real;

begin
  flagMonto:=False;
  lMonto.Caption:='';
  lMonto.Width:=145;
  lMonto.Height:=65;
  if not StringVacio(eMonto.Text)
  then if EsNumerico(eMonto.Text)
    then begin
      Monto:=strtofloat(eMonto.Text);
      if Monto <= SaldoCuenta(Cuentas,Usuario.Nick)
      then flagMonto:=True
      else lMonto.Caption:=Error(403); //El monto es menor al saldo
    end
    else lMonto.Caption:=Error(203) //El monto no es valido
  else lMonto.Caption:=Error(104); //Campo vacio

  if flagMonto
  then begin
    RetirarSaldo(Cuentas,Usuario.Nick,Monto);
    ShowMessage(Error(0));
    lSaldo.Caption:=floattostr(SaldoCuenta(Cuentas,Usuario.Nick));
  end;
end;

end.
