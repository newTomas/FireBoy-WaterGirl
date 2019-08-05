object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    635
    299)
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 272
    Top = 32
    Width = 177
    Height = 105
    Anchors = [akLeft, akTop, akRight, akBottom]
    Stretch = True
  end
  object Button1: TButton
    Left = 440
    Top = 272
    Width = 75
    Height = 25
    Caption = 'save'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 537
    Top = 272
    Width = 75
    Height = 25
    Caption = 'load'
    TabOrder = 1
    OnClick = Button2Click
  end
  object ListView1: TListView
    Left = 8
    Top = 8
    Width = 209
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
    TabOrder = 2
    ViewStyle = vsReport
    OnSelectItem = ListView1SelectItem
  end
  object Button3: TButton
    Left = 64
    Top = 176
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Panel1: TPanel
    Left = 296
    Top = 176
    Width = 185
    Height = 41
    BevelOuter = bvNone
    TabOrder = 4
  end
  object BitBtn1: TBitBtn
    Left = 176
    Top = 240
    Width = 65
    Height = 25
    Caption = #1053#1040#1057#1058#1056#1054#1049#1050#1048
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 25
    Font.Name = 'Tahoma'
    Font.Style = []
    Font.Quality = fqClearType
    ParentFont = False
    TabOrder = 5
  end
end
