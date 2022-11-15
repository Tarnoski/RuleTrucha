unit UnitMod;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UsuarioActual, ControladorLibrerias, ExtCtrls;

type
  TfMod = class(TForm)
    Label3: TLabel;
    Label4: TLabel;
    lNom: TLabel;
    lApe: TLabel;
    imgFoto: TImage;
    eNom: TEdit;
    eApe: TEdit;
    bConfirm: TButton;
    bBack: TButton;
    bPhoto: TButton;
    procedure bConfirmClick(Sender: TObject);
    procedure bBackClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fMod: TfMod;

implementation

uses
  Formatos, ManejadorErrores, ME_Jugadores, UnitMenu;

{$R *.dfm}

procedure TfMod.bConfirmClick(Sender: TObject);
  var
    flagNom,flagApe:boolean;

begin

  flagNom:=False;
  lNom.Width:=289;
  if not StringVacio(eNom.Text)
  then if SoloLetras(eNom.Text)
    then if Length(eNom.Text) <= 100
      then flagNom:=True
      else lNom.Caption:=Error(305) //El nombre no puede tener mas de 100 caracteres
    else lNom.Caption:=Error(203) //El nombre no es valido
  else lNom.Caption:=Error(104); //Campo vacio

  flagApe:=False;
  lApe.Width:=289;
  if not StringVacio(eApe.Text)
  then if SoloLetras(eApe.Text)
    then if Length(eApe.Text) <= 100
      then flagApe:=True
      else lApe.Caption:=Error(306) //El apellido no puede tener mas de 100 caracteres
    else lApe.Caption:=Error(203) //El apellido no es valido
  else lApe.Caption:=Error(104); //Campo vacio

  if flagNom and flagApe
  then begin
    Usuario.Nombre:=eNom.Text;
    Usuario.Apellidos:=eApe.Text;
    ModificarJugador(Jugadores,Usuario);
    ShowMessage(Error(0));
  end
  else ShowMessage(Error(106));
end;

procedure TfMod.bBackClick(Sender: TObject);
begin
  fMenu.Show;
  fMod.Hide;
end;

procedure TfMod.FormShow(Sender: TObject);

begin
  eNom.Text:=Usuario.Nombre;
  eApe.Text:=Usuario.Apellidos;
end;

end.
