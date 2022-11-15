unit UnitBaja;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UsuarioActual, ControladorLibrerias, ExtCtrls;

type
  TfBaja = class(TForm)
    Label5: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    imgFoto: TImage;
    eNick: TEdit;
    eNom: TEdit;
    eApe: TEdit;
    fConfirm: TButton;
    bBack: TButton;
    procedure FormCreate(Sender: TObject);
    procedure bBackClick(Sender: TObject);
    procedure fConfirmClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fBaja: TfBaja;

implementation

uses
  ManejadorErrores, ME_Jugadores, ME_Cuentas, UnitMenu, UnitLogin;

{$R *.dfm}

procedure TfBaja.FormCreate(Sender: TObject);
begin
  eNick.Text:=Usuario.Nick;
  eNom.Text:=Usuario.Nombre;
  eApe.Text:=Usuario.Apellidos;
end;

procedure TfBaja.bBackClick(Sender: TObject);
begin
  fMenu.Show;
  fBaja.Hide;
end;

procedure TfBaja.fConfirmClick(Sender: TObject);
begin
  BajaJugador(Jugadores,Usuario.Nick);
  BajaCuenta(Cuentas,Usuario.Nick);
  LogOut;
  fLogin.Show;
  fBaja.Hide;
end;

end.
