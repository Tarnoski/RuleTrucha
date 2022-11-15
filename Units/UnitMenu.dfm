object fMenu: TfMenu
  Left = 192
  Top = 125
  Width = 733
  Height = 509
  Caption = 'Menu'
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
  object lMonto: TLabel
    Left = 40
    Top = 392
    Width = 5
    Height = 16
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object bLogout: TButton
    Left = 192
    Top = 392
    Width = 105
    Height = 57
    Caption = 'Salir'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = bLogoutlick
  end
  object GroupBox1: TGroupBox
    Left = 320
    Top = 16
    Width = 353
    Height = 441
    Caption = 'Datos del Jugador'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object Label1: TLabel
      Left = 44
      Top = 32
      Width = 34
      Height = 20
      Alignment = taRightJustify
      Caption = 'Nick:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 20
      Top = 264
      Width = 60
      Height = 20
      Alignment = taRightJustify
      Caption = 'Nombre:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 20
      Top = 296
      Width = 60
      Height = 20
      Alignment = taRightJustify
      Caption = 'Apellido:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object imgFoto: TImage
      Left = 88
      Top = 64
      Width = 185
      Height = 185
    end
    object lNick: TLabel
      Left = 88
      Top = 32
      Width = 30
      Height = 20
      Caption = 'Nick'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lNom: TLabel
      Left = 88
      Top = 264
      Width = 56
      Height = 20
      Caption = 'Nombre'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lApe: TLabel
      Left = 88
      Top = 296
      Width = 64
      Height = 20
      Caption = 'Apellidos'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object bUpdate: TButton
      Left = 32
      Top = 328
      Width = 129
      Height = 41
      Caption = 'Actualizar datos'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = bUpdateClick
    end
    object bClose: TButton
      Left = 182
      Top = 376
      Width = 131
      Height = 41
      Caption = 'Cerrar Cuenta'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = bCloseClick
    end
    object bPass: TButton
      Left = 32
      Top = 376
      Width = 129
      Height = 41
      Caption = 'Cambiar Clave'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = bPassClick
    end
    object bMoves: TButton
      Left = 184
      Top = 328
      Width = 129
      Height = 41
      Caption = 'Movimientos'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = bMovesClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 40
    Top = 16
    Width = 257
    Height = 361
    Caption = 'Juego'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object Label4: TLabel
      Left = 64
      Top = 37
      Width = 45
      Height = 20
      Caption = 'Saldo:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lSaldo: TLabel
      Left = 120
      Top = 37
      Width = 41
      Height = 20
      Caption = 'Saldo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object grbFichas: TGroupBox
      Left = 16
      Top = 208
      Width = 217
      Height = 137
      Caption = 'Comprar Fichas'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      object Label5: TLabel
        Left = 24
        Top = 33
        Width = 49
        Height = 20
        Caption = 'Monto:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object eMonto: TEdit
        Left = 80
        Top = 29
        Width = 113
        Height = 28
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object bBuy: TButton
        Left = 16
        Top = 72
        Width = 81
        Height = 49
        Caption = 'Comprar Fichas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        WordWrap = True
        OnClick = bBuyClick
      end
      object bRetirar: TButton
        Left = 112
        Top = 72
        Width = 81
        Height = 49
        Caption = 'Retirar Dinero'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        WordWrap = True
        OnClick = bRetirarClick
      end
    end
    object GroupBox3: TGroupBox
      Left = 24
      Top = 64
      Width = 209
      Height = 121
      Caption = 'Estado del juego'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      object lStatus: TLabel
        Left = 40
        Top = 32
        Width = 119
        Height = 20
        Alignment = taCenter
        Caption = 'Juego terminado'
      end
      object lPremio: TLabel
        Left = 56
        Top = 80
        Width = 84
        Height = 20
        Alignment = taCenter
        Caption = 'No participo'
        WordWrap = True
      end
    end
  end
end
