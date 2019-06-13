object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Fire&Water'
  ClientHeight = 720
  ClientWidth = 1280
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 160
    Top = 241
    Width = 10
    Height = 13
    Caption = 'IP'
    Enabled = False
    Visible = False
  end
  object Label2: TLabel
    Left = 160
    Top = 287
    Width = 27
    Height = 13
    Caption = 'PORT'
    Enabled = False
    Visible = False
  end
  object Label5: TLabel
    Left = 168
    Top = 369
    Width = 86
    Height = 21
    Caption = 'Server Chat'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object Edit1: TEdit
    Left = 160
    Top = 260
    Width = 121
    Height = 21
    Hint = '123'
    Enabled = False
    TabOrder = 0
    Visible = False
    OnClick = Edit1Click
    OnKeyUp = FormKeyUp
  end
  object Edit2: TEdit
    Left = 160
    Top = 306
    Width = 121
    Height = 21
    Hint = '123'
    Enabled = False
    TabOrder = 1
    Visible = False
    OnClick = Edit2Click
    OnKeyUp = FormKeyUp
  end
  object Button1: TButton
    Left = 160
    Top = 341
    Width = 75
    Height = 22
    Caption = 'Connect'
    Enabled = False
    TabOrder = 2
    Visible = False
    OnClick = Button1Click
    OnKeyUp = FormKeyUp
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 38
    Width = 185
    Height = 137
    Caption = 'GroupBox1'
    Enabled = False
    TabOrder = 3
    Visible = False
    object Label3: TLabel
      Left = 3
      Top = 41
      Width = 33
      Height = 13
      Caption = 'Adress'
    end
    object Label4: TLabel
      Left = 3
      Top = 87
      Width = 22
      Height = 13
      Caption = 'Host'
    end
    object CheckBox1: TCheckBox
      Left = 3
      Top = 18
      Width = 97
      Height = 17
      Caption = 'Connected'
      Enabled = False
      TabOrder = 0
    end
    object Edit3: TEdit
      Left = 3
      Top = 60
      Width = 121
      Height = 21
      TabOrder = 1
      Text = 'Edit3'
    end
    object Edit4: TEdit
      Left = 3
      Top = 106
      Width = 121
      Height = 21
      TabOrder = 2
      Text = 'Edit4'
    end
  end
  object Edit5: TEdit
    Left = 16
    Top = 396
    Width = 300
    Height = 21
    Enabled = False
    TabOrder = 4
    Visible = False
    OnKeyUp = FormKeyUp
  end
  object Send: TButton
    Left = 322
    Top = 398
    Width = 75
    Height = 21
    Caption = 'Send'
    Enabled = False
    TabOrder = 5
    Visible = False
    OnClick = SendClick
    OnKeyUp = FormKeyUp
  end
  object Memo1: TMemo
    Left = 16
    Top = 433
    Width = 381
    Height = 173
    Enabled = False
    Lines.Strings = (
      '')
    TabOrder = 6
    Visible = False
  end
  object Connect: TButton
    Left = 544
    Top = 241
    Width = 393
    Height = 36
    Caption = #1055#1088#1080#1089#1086#1077#1076#1080#1085#1080#1090#1100#1089#1103' '#1082' '#1089#1077#1088#1074#1077#1088#1091
    TabOrder = 7
    OnClick = ConnectClick
    OnKeyUp = FormKeyUp
  end
  object Create: TButton
    Left = 544
    Top = 283
    Width = 393
    Height = 36
    Caption = #1057#1086#1079#1076#1072#1090#1100' '#1089#1074#1086#1081' '#1089#1077#1088#1074#1077#1088
    TabOrder = 8
    OnClick = CreateClick
    OnKeyUp = FormKeyUp
  end
  object Settings: TButton
    Left = 544
    Top = 325
    Width = 393
    Height = 36
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
    TabOrder = 9
    OnKeyUp = FormKeyUp
  end
  object Exit: TButton
    Left = 544
    Top = 367
    Width = 393
    Height = 36
    Caption = #1053#1045' '#1053#1040#1046#1048#1052#1040#1058#1068
    TabOrder = 10
    OnClick = ExitClick
    OnKeyUp = FormKeyUp
  end
  object Back: TButton
    Left = 160
    Top = 374
    Width = 40
    Height = 22
    Caption = 'Back'
    Enabled = False
    TabOrder = 11
    Visible = False
    OnClick = BackClick
    OnKeyUp = FormKeyUp
  end
  object StartButton: TButton
    Left = 943
    Top = 241
    Width = 90
    Height = 162
    Caption = #1053#1072#1095#1072#1090#1100' '#1080#1075#1088#1091
    Enabled = False
    TabOrder = 12
    Visible = False
    OnClick = StartButtonClick
  end
  object Timer1: TTimer
    Interval = 5
    OnTimer = Timer1Timer
  end
end
