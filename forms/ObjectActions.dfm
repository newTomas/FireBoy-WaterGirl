object Form2: TForm2
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1089#1074#1103#1079#1077#1081' '#1086#1073#1098#1077#1082#1090#1072
  ClientHeight = 226
  ClientWidth = 294
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  PixelsPerInch = 96
  TextHeight = 13
  object ActionsList: TListView
    Left = 8
    Top = 8
    Width = 278
    Height = 150
    Columns = <
      item
        Caption = 'Type'
      end
      item
        Caption = 'id'
      end
      item
        Caption = 'X'
      end
      item
        Caption = 'Y'
      end>
    TabOrder = 0
    ViewStyle = vsReport
  end
  object ActionControlGroup: TGroupBox
    Left = 8
    Top = 164
    Width = 278
    Height = 55
    Enabled = False
    TabOrder = 1
    object y: TEdit
      Left = 241
      Top = 0
      Width = 35
      Height = 21
      NumbersOnly = True
      TabOrder = 0
      TextHint = 'Y'
    end
    object id: TEdit
      Left = 159
      Top = 0
      Width = 35
      Height = 21
      Hint = 
        #1053#1072#1078#1084#1080#1090#1077' '#1085#1072' '#1085#1077#1086#1073#1093#1086#1076#1080#1084#1099#1081' '#1086#1073#1098#1077#1082#1090' '#1080' '#1077#1075#1086' id '#1074#1089#1090#1072#1085#1077#1090' '#1089#1102#1076#1072' '#1072#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082 +
        #1080
      NumbersOnly = True
      ReadOnly = True
      TabOrder = 1
      TextHint = 'id'
    end
    object x: TEdit
      Left = 200
      Top = 0
      Width = 35
      Height = 21
      NumbersOnly = True
      TabOrder = 2
      TextHint = 'X'
    end
    object delete: TButton
      Left = 0
      Top = 30
      Width = 88
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 3
    end
    object ActionsSelect: TComboBox
      Left = 1
      Top = 0
      Width = 152
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 4
      Text = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1086#1073#1098#1077#1082#1090
      Items.Strings = (
        #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1086#1073#1098#1077#1082#1090
        #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1080#1075#1088#1086#1082#1072
        #1059#1073#1080#1090#1100' '#1080#1075#1088#1086#1082#1072
        #1048#1079#1084#1077#1085#1080#1090#1100' '#1089#1087#1072#1074#1085)
    end
  end
  object create: TButton
    Left = 102
    Top = 194
    Width = 88
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1090#1100
    TabOrder = 2
  end
  object apply: TButton
    Left = 198
    Top = 194
    Width = 88
    Height = 25
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    TabOrder = 3
  end
end
