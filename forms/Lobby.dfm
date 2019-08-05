object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 720
  ClientWidth = 1280
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    1280
    720)
  PixelsPerInch = 96
  TextHeight = 13
  object Lobby: TPanel
    Left = 0
    Top = 0
    Width = 1280
    Height = 720
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    Visible = False
    object LPlayers: TListBox
      Left = 440
      Top = 200
      Width = 197
      Height = 300
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 0
    end
    object LReady: TCheckBox
      Left = 643
      Top = 477
      Width = 63
      Height = 17
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = #1043#1086#1090#1086#1074
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object LPlayerType: TRadioGroup
      Left = 643
      Top = 200
      Width = 197
      Height = 150
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = #1042#1099#1073#1086#1088' '#1087#1077#1088#1089#1086#1085#1072#1078#1072
      Columns = 2
      TabOrder = 2
    end
    object LChat: TMemo
      Left = 643
      Top = 382
      Width = 197
      Height = 89
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 3
    end
    object LMessage: TEdit
      Left = 643
      Top = 356
      Width = 121
      Height = 21
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 4
    end
    object LSend: TBitBtn
      Left = 765
      Top = 354
      Width = 75
      Height = 26
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = #1054#1058#1055#1056#1040#1042#1048#1058#1068
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
    end
    object LLeave: TBitBtn
      Left = 765
      Top = 473
      Width = 75
      Height = 25
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = #1055#1054#1050#1048#1053#1059#1058#1068
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
    end
  end
end
