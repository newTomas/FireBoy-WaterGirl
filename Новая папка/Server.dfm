object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 251
  ClientWidth = 477
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 43
    Width = 14
    Height = 13
    Caption = 'IP:'
  end
  object Label2: TLabel
    Left = 8
    Top = 62
    Width = 24
    Height = 13
    Caption = 'Port:'
  end
  object Label3: TLabel
    Left = 266
    Top = 43
    Width = 24
    Height = 13
    Caption = 'Map:'
  end
  object Edit1: TEdit
    Left = 53
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '127.0.0.1'
  end
  object Edit2: TEdit
    Left = 53
    Top = 59
    Width = 121
    Height = 21
    TabOrder = 1
    Text = '80'
  end
  object CheckBox1: TCheckBox
    Left = 53
    Top = 110
    Width = 97
    Height = 17
    Caption = 'Active'
    TabOrder = 2
    OnClick = CheckBox1Click
  end
  object CheckBox2: TCheckBox
    Left = 53
    Top = 87
    Width = 97
    Height = 17
    Caption = '127.0.0.1'
    TabOrder = 3
  end
  object Edit3: TEdit
    Left = 296
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 4
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 0
    OnConnect = IdTCPServer1Connect
    OnDisconnect = IdTCPServer1Disconnect
    OnExecute = IdTCPServer1Execute
    Left = 120
    Top = 160
  end
  object IdIPWatch1: TIdIPWatch
    Active = False
    HistoryFilename = 'iphist.dat'
    Left = 168
    Top = 160
  end
end
