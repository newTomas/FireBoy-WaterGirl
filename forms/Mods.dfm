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
  object Mods: TPanel
    Left = 0
    Top = 0
    Width = 1280
    Height = 720
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    Visible = False
    object MModsList: TListBox
      Left = 500
      Top = 200
      Width = 300
      Height = 400
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 0
    end
    object MReturn: TBitBtn
      Left = 600
      Top = 616
      Width = 75
      Height = 25
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = #1042#1045#1056#1053#1059#1058#1068#1057#1071
      TabOrder = 1
    end
  end
end
