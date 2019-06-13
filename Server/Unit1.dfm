object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 393
    Top = 8
    Width = 20
    Height = 13
    Caption = 'Port'
  end
  object Label2: TLabel
    Left = 396
    Top = 107
    Width = 45
    Height = 13
    Caption = 'IP adress'
  end
  object Label3: TLabel
    Left = 396
    Top = 134
    Width = 61
    Height = 13
    Caption = 'Remote host'
  end
  object Label4: TLabel
    Left = 396
    Top = 161
    Width = 31
    Height = 13
    Caption = 'Status'
  end
  object Label5: TLabel
    Left = 396
    Top = 188
    Width = 72
    Height = 13
    Caption = 'Local IP adress'
  end
  object Button1: TButton
    Left = 520
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Activate'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 393
    Top = 27
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object CheckBox1: TCheckBox
    Left = 393
    Top = 64
    Width = 97
    Height = 17
    Caption = 'Connected'
    Enabled = False
    TabOrder = 2
  end
  object Edit2: TEdit
    Left = 474
    Top = 104
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 3
  end
  object Edit3: TEdit
    Left = 474
    Top = 131
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 4
  end
  object Edit4: TEdit
    Left = 474
    Top = 158
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 5
  end
  object Edit5: TEdit
    Left = 474
    Top = 185
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 6
  end
  object Button2: TButton
    Left = 294
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Send'
    TabOrder = 7
  end
  object Edit6: TEdit
    Left = 8
    Top = 26
    Width = 280
    Height = 21
    TabOrder = 8
  end
  object Memo1: TMemo
    Left = 8
    Top = 53
    Width = 361
    Height = 238
    Lines.Strings = (
      'Memo1')
    TabOrder = 9
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 0
    OnConnect = IdTCPServer1Connect
    OnDisconnect = IdTCPServer1Disconnect
    OnExecute = IdTCPServer1Execute
    Left = 488
    Top = 232
  end
end
