unit UnitAdmin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ControladorLibrerias, UsuarioActual, StdCtrls;

type
  TfAdmin = class(TForm)
    bLogout: TButton;
    GroupBox1: TGroupBox;
    bNew: TButton;
    bListaJ: TButton;
    procedure bNewClick(Sender: TObject);
    procedure bLogoutClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fAdmin: TfAdmin;

implementation

uses
  ME_Ruleta, UnitJuego, UnitLogin;

{$R *.dfm}

procedure TfAdmin.bNewClick(Sender: TObject);
begin
  NuevoJuego(Ruleta);
  fJuego.Show;
  fAdmin.Hide;
end;

procedure TfAdmin.bLogoutClick(Sender: TObject);
begin
  Logout;
  fAdmin.Hide;
  fLogin.Show;
end;

end.
