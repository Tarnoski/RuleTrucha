unit UnitAlta;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ControladorLibrerias, ExtCtrls;

type
  TfAlta = class(TForm)
    Label5: TLabel;
    Label1: TLabel;
    ePass: TEdit;
    Label2: TLabel;
    eRepeat: TEdit;
    eNick: TEdit;
    eNom: TEdit;
    Label3: TLabel;
    eApe: TEdit;
    Label4: TLabel;
    lNick: TLabel;
    lPass: TLabel;
    lNom: TLabel;
    lApe: TLabel;
    bConfirm: TButton;
    bBack: TButton;
    bPhoto: TButton;
    imgFoto: TImage;
    Label6: TLabel;
    lMonto: TLabel;
    eMonto: TEdit;
    lMin: TLabel;
    procedure bConfirmClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bBackClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fAlta: TfAlta;

implementation

uses
  Formatos, ManejadorErrores, ME_Jugadores, ME_Cuentas, Rutas, UnitLogin;
{$R *.dfm}

procedure TfAlta.bConfirmClick(Sender: TObject);
  var
    flagNick,flagPass,flagNom,flagApe,flagMonto:boolean;
    Reg:TipoRegJugador;
    Minimo:real;

begin
  Minimo:=ObtenerMinimo(Cuentas);
  
  flagNick:=False;
  lNick.Caption:='';
  lNick.Width:=289;
  lNick.Height:=33;
  if not StringVacio(eNick.Text)
  then if EsAlfaNumerico(eNick.Text)
    then if Length(eNick.Text) <= 6
      then if not BuscarJugador(Jugadores,eNick.Text)
        then flagNick:=True
        else lNick.Caption:=Error(301) //El nick ya esta en uso
      else lNick.Caption:=Error(303) //El nick no puede tener mas de 6 caracteres
    else lNick.Caption:=Error(202) //La clave no es valida
  else lNick.Caption:=Error(104);  //Campo vacio

  flagPass:=False;
  lPass.Caption:='';
  lPass.Width:=289;
  lPass.Height:=33;
  if not StringVacio(ePass.Text)
  then if EsAlfaNumerico(ePass.Text)
    then if (Length(ePass.Text) > 5) and (Length(ePass.Text) < 12)
      then if ePass.Text = eRepeat.Text
        then if not ClaveEnUso(Jugadores,ePass.Text)
          then flagPass:=True
          else lPass.Caption:=Error(302) //La clave ya esta en uso
        else lPass.Caption:=Error(105) //Los dos campos no coinciden
      else lPass.Caption:=Error(304) //La clave debe tener entre 6 y 12 caracteres
    else lPass.Caption:=Error(202) //La clave no es valida
  else lPass.Caption:=Error(104); //Campo vacio

  flagNom:=False;
  lNom.Caption:='';
  lNom.Width:=289;
  lNom.Height:=33;
  if not StringVacio(eNom.Text)
  then if SoloLetras(eNom.Text)
    then if Length(eNom.Text) <= 100
      then flagNom:=True
      else lNom.Caption:=Error(305) //El nombre no puede tener mas de 100 caracteres
    else lNom.Caption:=Error(203) //El nombre no es valido
  else lNom.Caption:=Error(104); //Campo vacio

  flagApe:=False;
  lApe.Caption:='';
  lApe.Width:=289;
  lApe.Height:=33;
  if not StringVacio(eApe.Text)
  then if SoloLetras(eApe.Text)
    then if Length(eApe.Text) <= 100
      then flagApe:=True
      else lApe.Caption:=Error(306) //El apellido no puede tener mas de 100 caracteres
    else lApe.Caption:=Error(203) //El apellido no es valido
  else lApe.Caption:=Error(104); //Campo vacio

  flagMonto:=False;
  lMonto.Caption:='';
  lMonto.Width:=289;
  lMonto.Height:=33;
  if not StringVacio(eMonto.Text)
  then if EsNumerico(eMonto.Text)
    then if strtofloat(eMonto.Text) >= Minimo
      then flagMonto:=True
      else lMonto.Caption:=Error(401) //El monto es menor al minimo
    else lMonto.Caption:=Error(203) //El monto no es valido
  else lMonto.Caption:=Error(104); //Campo vacio

  if flagNick and flagPass and flagNom and flagApe and flagMonto
  then begin
    Reg.Nick:=eNick.Text;
    Reg.Clave:=ePass.Text;
    Reg.Nombre:=eNom.Text;
    Reg.Apellidos:=eApe.Text;
    AltaCuenta(Cuentas,Reg.Nick,strtofloat(eMonto.Text));
    AltaJugador(Jugadores,Reg);
    ShowMessage(Error(0));
  end
  else ShowMessage(Error(106));
end;

procedure TfAlta.FormCreate(Sender: TObject);
begin
  //imgFoto.Picture.LoadFromFile(Rutas.RutaSinFoto);
end;

procedure TfAlta.bBackClick(Sender: TObject);
begin
  fLogin.Show;
  fAlta.Hide;
end;

procedure TfAlta.FormShow(Sender: TObject);
begin
  lMin.Caption:=lMin.Caption + floattostr(ObtenerMinimo(Cuentas));
end;

end.
