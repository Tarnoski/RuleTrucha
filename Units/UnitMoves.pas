unit UnitMoves;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, UsuarioActual, ControladorLibrerias, StdCtrls;

type
  TfMoves = class(TForm)
    StringGrid1: TStringGrid;
    bBack: TButton;
    procedure bBackClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fMoves: TfMoves;

implementation

uses
  ME_Cuentas, UnitMenu;

{$R *.dfm}

procedure TfMoves.bBackClick(Sender: TObject);
begin
  fMenu.Show;
  fMoves.Hide;
end;

procedure TfMoves.FormShow(Sender: TObject);
var
  Reg:TipoRegAsiento;
  cont:integer;

begin
  cont:=0;
  StringGrid1.Cells[0,cont]:='Concepto';
  StringGrid1.Cells[1,cont]:='Fecha y hora';
  StringGrid1.Cells[2,cont]:='Debe';
  StringGrid1.Cells[3,cont]:='Haber';
  StringGrid1.Cells[4,cont]:='Saldo';
  Reg:=PrimerAsientoCuenta(Cuentas,Usuario.Nick);
  repeat
    cont:=cont + 1;
    StringGrid1.RowCount:=cont + 1;
    StringGrid1.Cells[0,cont]:=Reg.Concepto;
    StringGrid1.Cells[1,cont]:=DateTimeToStr(Reg.FechaHora);
    StringGrid1.Cells[2,cont]:=FloatToStr(Reg.Debe);
    StringGrid1.Cells[3,cont]:=FloatToStr(Reg.Haber);
    StringGrid1.Cells[4,cont]:=FloatToStr(Reg.Saldo);
    Reg:=ProximoAsientoCuenta(Cuentas,Reg);
  until Reg.Concepto = 'EoF';
  StringGrid1.FixedRows:=1;
end;

end.
