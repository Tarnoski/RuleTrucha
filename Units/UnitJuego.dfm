object fJuego: TfJuego
  Left = 123
  Top = 77
  Width = 1370
  Height = 541
  Caption = 'Juego'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object gbStatus: TGroupBox
    Left = 24
    Top = 24
    Width = 617
    Height = 105
    Caption = 'Estado del juego - Juego Creado'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object bApuestas: TButton
      Left = 16
      Top = 32
      Width = 105
      Height = 49
      Caption = 'Hagan sus apuestas'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      WordWrap = True
      OnClick = bApuestasClick
    end
    object bNoMore: TButton
      Left = 136
      Top = 32
      Width = 105
      Height = 49
      Caption = 'No va mas'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = bNoMoreClick
    end
    object bBall: TButton
      Left = 256
      Top = 32
      Width = 105
      Height = 49
      Caption = 'Tirar Bolilla'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = bBallClick
    end
    object bPrizes: TButton
      Left = 376
      Top = 32
      Width = 105
      Height = 49
      Caption = 'Repartir Premios'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      WordWrap = True
      OnClick = bPrizesClick
    end
    object bEnd: TButton
      Left = 496
      Top = 32
      Width = 105
      Height = 49
      Caption = 'Terminar Juego'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      WordWrap = True
      OnClick = bEndClick
    end
  end
end
