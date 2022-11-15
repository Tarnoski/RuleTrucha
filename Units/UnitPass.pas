unit UnitPass;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UsuarioActual, ControladorLibrerias, StdCtrls;

type
  TfPass = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    lPass: TLabel;
    eNew: TEdit;
    eRepeat: TEdit;
    Label3: TLabel;
    eOld: TEdit;
    bConfirm: TButton;
    bBack: TButton;
    procedure bConfirmClick(Sender: TObject);
    procedure bBackClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fPass: TfPass;

implementation

uses
  Formatos, ManejadorErrores, ME_Jugadores, UnitMenu;

{$R *.dfm}

procedure TfPass.bConfirmClick(Sender: TObject);
var
  flagPass:boolean;

begin
  flagPass:=False;
  lPass.Width:=289;
  if not StringVacio(eNew.Text) or StringVacio(eOld.Text)
  then if eOld.Text = Usuario.Clave
    then if EsAlfaNumerico(eNew.Text)
      then if (Length(eNew.Text) > 5) and (Length(eNew.Text) < 12)
        then if eNew.Text = eRepeat.Text
          then if not ClaveEnUso(Jugadores,eNew.Text)
            then flagPass:=True
            else lPass.Caption:=Error(302) //La neva clave ya esta en uso
          else lPass.Caption:=Error(105) //Los dos campos no coinciden
        else lPass.Caption:=Error(304) //La nueva clave debe tener entre 6 y 12 caracteres
      else lPass.Caption:=Error(202) //La nueva clave no es valida
    else lPass.Caption:=Error(307) //Clave actual erronea
  else lPass.Caption:=Error(104); //Campo vacio

  if flagPass
  then begin
    Usuario.Clave:=eRepeat.Text;
    ModificarJugador(Jugadores,Usuario);
    ShowMessage(Error(0));
  end
  else ShowMessage(Error(106));

end;

procedure TfPass.bBackClick(Sender: TObject);
begin
  fMenu.Show;
  fPass.Hide;
end;

end.
