object Form1: TForm1
  Left = 0
  Top = 0
  Caption = #1041#1077#1079#1099#1084#1103#1085#1085#1099#1081' - FireBoy & WaterGirl map edit'
  ClientHeight = 720
  ClientWidth = 1280
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  DesignSize = (
    1280
    720)
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 192
    Top = 192
    Width = 105
    Height = 105
  end
  object line: TPanel
    Left = 0
    Top = 715
    Width = 1280
    Height = 1
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 0
  end
  object MainMenu1: TMainMenu
    object N1: TMenuItem
      Caption = #1060#1072#1081#1083
      object N2: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        OnClick = N2Click
      end
      object N3: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        OnClick = N3Click
      end
      object N4: TMenuItem
        Caption = #1057#1086#1079#1076#1072#1090#1100
        OnClick = N4Click
      end
      object N5: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = N5Click
      end
    end
  end
end
