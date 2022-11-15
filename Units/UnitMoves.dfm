object fMoves: TfMoves
  Left = 192
  Top = 125
  Width = 631
  Height = 473
  Caption = 'Movimientos'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid1: TStringGrid
    Left = 40
    Top = 32
    Width = 545
    Height = 305
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 0
    ColWidths = (
      180
      161
      64
      64
      64)
  end
  object bBack: TButton
    Left = 248
    Top = 360
    Width = 115
    Height = 41
    Caption = 'Volver'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = bBackClick
  end
end
