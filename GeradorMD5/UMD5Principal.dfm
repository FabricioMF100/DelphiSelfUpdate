object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Ferramenta para gera'#231#227'o de MD5'
  ClientHeight = 128
  ClientWidth = 402
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 37
    Height = 13
    Caption = 'Arquivo'
  end
  object Label2: TLabel
    Left = 8
    Top = 72
    Width = 187
    Height = 13
    Caption = 'Chave MD5 para o arquivo selecionado'
  end
  object Edit1: TEdit
    Left = 8
    Top = 27
    Width = 265
    Height = 21
    TabStop = False
    ReadOnly = True
    TabOrder = 0
  end
  object Button1: TButton
    Left = 279
    Top = 25
    Width = 115
    Height = 25
    Caption = 'Selecionar Arquivo'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Edit2: TEdit
    Left = 8
    Top = 91
    Width = 305
    Height = 21
    TabStop = False
    ReadOnly = True
    TabOrder = 2
    Text = 'Selecione um arquivo acima'
  end
  object Button2: TButton
    Left = 319
    Top = 89
    Width = 75
    Height = 25
    Caption = 'Copiar'
    TabOrder = 3
    OnClick = Button2Click
  end
  object OpenDialog1: TOpenDialog
    Left = 200
    Top = 16
  end
end
