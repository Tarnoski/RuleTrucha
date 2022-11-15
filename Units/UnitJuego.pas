unit UnitJuego;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ControladorLibrerias, StdCtrls, Math;

type
  TfJuego = class(TForm)
    gbStatus: TGroupBox;
    bApuestas: TButton;
    bNoMore: TButton;
    bBall: TButton;
    bPrizes: TButton;
    bEnd: TButton;
    procedure bApuestasClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bNoMoreClick(Sender: TObject);
    procedure bBallClick(Sender: TObject);
    procedure bPrizesClick(Sender: TObject);
    procedure bEndClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fJuego: TfJuego;

implementation

uses
  ME_Ruleta, UnitAdmin;
{$R *.dfm}

procedure TfJuego.bApuestasClick(Sender: TObject);
var
  Reg:TipoRegRuleta;

begin
  UltimoJuego(Ruleta,Reg);
  if BuscarJuego(Ruleta,Reg.Juego)
  then Apuestas(Ruleta);
  bApuestas.Enabled:=False;
  bNoMore.Enabled:=True;
  gbStatus.Caption:='Estado del juego - Esperando apuestas';
end;

procedure TfJuego.FormShow(Sender: TObject);
begin
  bApuestas.Enabled:=True;
  bEnd.Enabled:=False;
  gbStatus.Caption:='Estado del juego - Partida creada';
end;

procedure TfJuego.bNoMoreClick(Sender: TObject);
var
  Reg:TipoRegRuleta;

begin
  UltimoJuego(Ruleta,Reg);
  if BuscarJuego(Ruleta,Reg.Juego)
  then NoVaMas(Ruleta);
  bNoMore.Enabled:=False;
  bBall.Enabled:=True;
  gbStatus.Caption:='Estado del juego - No se reciben mas apuestas';
end;

procedure TfJuego.bBallClick(Sender: TObject);
var
  Reg:TipoRegRuleta;
  result:TipoBolilla;

begin
  result:=Random(36);
  UltimoJuego(Ruleta,Reg);
  if BuscarJuego(Ruleta,Reg.Juego)
  then BolillaTirada(Ruleta,result);
  bBall.Enabled:=False;
  bPrizes.Enabled:=True;
  gbStatus.Caption:='Estado del juego - Bolilla Tirada';
end;

procedure TfJuego.bPrizesClick(Sender: TObject);
var
  Reg:TipoRegRuleta;

begin
  UltimoJuego(Ruleta,Reg);
  if BuscarJuego(Ruleta,Reg.Juego)
  then Premios(Ruleta);
  bPrizes.Enabled:=False;
  bEnd.Enabled:=True;
  gbStatus.Caption:='Estado del juego - Resultado: ' + inttostr(Reg.Bolilla);
end;

procedure TfJuego.bEndClick(Sender: TObject);
var
  Reg:TipoRegRuleta;

begin
  UltimoJuego(Ruleta,Reg);
  if BuscarJuego(Ruleta,Reg.Juego)
  then FinJuego(Ruleta);
  bApuestas.Enabled:=False;
  bNoMore.Enabled:=True;
  fAdmin.Show;
  fJuego.Hide;
end;

procedure TfJuego.FormCreate(Sender: TObject);
begin
  Randomize;
end;

end.

