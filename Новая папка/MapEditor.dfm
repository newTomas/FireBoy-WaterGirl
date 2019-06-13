object Form1: TForm1
  Left = 0
  Top = 0
  OnAlignPosition = FormAlignPosition
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsNone
  Caption = #1041#1077#1079#1099#1084#1103#1085#1085#1099#1081' - FireBoy & WaterGirl map edit'
  ClientHeight = 759
  ClientWidth = 1296
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object background: TImage
    Left = 0
    Top = 0
    Width = 105
    Height = 105
    Enabled = False
  end
  object MainMenu1: TMainMenu
    AutoHotkeys = maManual
    Left = 1032
    object N1: TMenuItem
      Caption = #1060#1072#1081#1083
      Visible = False
      object N2: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        ShortCut = 16463
        OnClick = N2Click
      end
      object N3: TMenuItem
        AutoHotkeys = maManual
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        ShortCut = 16467
        OnClick = N3Click
      end
      object N4: TMenuItem
        Caption = #1057#1086#1079#1076#1072#1090#1100
        ShortCut = 16462
        OnClick = N4Click
      end
      object N5: TMenuItem
        Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
        OnClick = N5Click
      end
      object N6: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        ShortCut = 32883
        OnClick = N6Click
      end
    end
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 928
    Top = 88
  end
end
