object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 225
  ClientWidth = 332
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 8
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 8
    Top = 8
    Width = 318
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
  end
  object Button2: TButton
    Left = 89
    Top = 48
    Width = 75
    Height = 25
    Caption = 'UnLoad'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 170
    Top = 48
    Width = 75
    Height = 25
    Caption = 'RUN'
    TabOrder = 3
  end
  object ListBox1: TListBox
    Left = 7
    Top = 79
    Width = 319
    Height = 138
    ItemHeight = 13
    TabOrder = 4
  end
  object Button4: TButton
    Left = 251
    Top = 48
    Width = 75
    Height = 25
    Caption = 'LoadALL'
    TabOrder = 5
    OnClick = Button4Click
  end
end
