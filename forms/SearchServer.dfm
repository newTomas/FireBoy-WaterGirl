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
  object SearchServer: TPanel
    Left = 0
    Top = 0
    Width = 1280
    Height = 720
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    Visible = False
    object SSAddress: TEdit
      Left = 490
      Top = 280
      Width = 300
      Height = 21
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
      TextHint = 'IP:PORT'
    end
    object SSReturn: TBitBtn
      Left = 490
      Top = 513
      Width = 100
      Height = 25
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = #1042#1045#1056#1053#1059#1058#1068#1057#1071
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 14
      Font.Name = 'Tahoma'
      Font.Style = []
      Font.Quality = fqClearType
      ParentFont = False
      TabOrder = 1
    end
    object SSGetInfo: TBitBtn
      Left = 590
      Top = 513
      Width = 100
      Height = 25
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = #1048#1053#1060#1054#1056#1052#1040#1062#1048#1071
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 14
      Font.Name = 'Tahoma'
      Font.Style = []
      Font.Quality = fqClearType
      ParentFont = False
      TabOrder = 2
    end
    object SSConnect: TBitBtn
      Left = 690
      Top = 513
      Width = 100
      Height = 25
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = #1055#1054#1044#1050#1051#1070#1063#1048#1058#1068#1057#1071
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 14
      Font.Name = 'Tahoma'
      Font.Style = []
      Font.Quality = fqClearType
      ParentFont = False
      TabOrder = 3
    end
    object SSServerInfo: TListView
      Left = 490
      Top = 307
      Width = 300
      Height = 200
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = #1053#1072#1079#1074#1072#1085#1080#1077
        end
        item
          Caption = #1048#1075#1088#1086#1082#1086#1074
        end
        item
          Caption = #1050#1072#1088#1090#1072
        end
        item
          Caption = #1055#1080#1085#1075
        end>
      Items.ItemData = {
        05360000000100000000000000FFFFFFFFFFFFFFFF04000000FFFFFFFF000000
        00000078991A2A0098D01A2A00E8CA1A2A0078CA1A2AFFFFFFFFFFFFFFFF}
      TabOrder = 4
      ViewStyle = vsReport
    end
  end
end
