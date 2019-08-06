unit MapEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, FileCtrl, Menus,
  ComCtrls, TFNW, ImgList, ExtCtrls, Math,
  Jpeg, GIFImg, DLLManager, Vcl.JumpList, JSON, IOUtils;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem; 
    N5: TMenuItem;
    N6: TMenuItem;
    Timer1: TTimer;
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    function SaveMap: boolean;
    function LoadMap: boolean;

    function CheckSaveMap: boolean;
    procedure ApplyName;

    procedure RemoveObj(i: Word);
    procedure RemovePlayer(i: Word);

    procedure ov(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);
    procedure od(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
    procedure ou(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

    procedure PlayersMouseMove(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);
    procedure PlayersMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
    procedure PlayersMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

    procedure PlayerslistMouseMove(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);
    procedure PlayerslistMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
    procedure PlayerslistMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

    procedure mv(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);
    procedure md(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
    procedure mu(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure setformclose(Sender: TObject; var CanClose: Boolean);
    procedure FormAlignPosition(Sender: TWinControl; Control: TControl;
      var NewLeft, NewTop, NewWidth, NewHeight: Integer; var AlignRect: TRect;
      AlignInfo: TAlignInfo);
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  gamename = 'FireBoy & Water Girl map edit';

var
  Form1: TForm1;
  SettingsForm: TForm;
  ObjectActionFrom: TForm;
  ObjectsPanel: TForm;
  PlayersPanel: TForm;
  myobj: TObj;
  playerslist: TPlayers;
  settings: record
    cbox: TComboBox;
    {width, height, players,} selectid: TEdit;
    start: record
      x,y: TEdit;
    end;
    widthlabel, heightlabel, playerslabel, startxlabel, startylabel: TLabel;
    savebtn: TButton;
  end;
  manager: TDLLManager;
  mapname: string;
  save: record
    high: Word;
    objs: array[1..65535] of Tmap;
    settings: TSettingsMap;
  end;
  saved: boolean=true;
  fullscreen: boolean=false;
  img: record
    high: Word;
    x,y: Word;
    down: boolean;
    arr: array[1..65535] of record
      img: TImage;
      name: string[32];
    end;
  end;
  Players: record
    high: Word;
    x,y: Word;
    down: boolean;
    arr: array[1..255] of record
      img: TImage;
      name: string[32];
    end;
  end;
  PlayersObjs: record
    high: Word;
    activate: Word;
    x,y: Word;
    down: boolean;
    moved: boolean;
    arr: array[1..255] of record
      img: TImage;
      selected: boolean;
      name: string[32];
    end;
  end;
  obj: record
    high: Word;
    activate: Word;
    x,y: Word;
    Width, Height: Word;
    down: boolean;
    moved: boolean;
    arr: array[1..65535] of record
      img: TImage;
      width, height: Word;
      selected: boolean;
      name: string[32];
      data: array of TObjectData;
    end;
  end;
  select: record
    x,y: Word;
    selecting: boolean;
  end;
  bkg: TBitmap;
  F: File of TSettingsMap;

implementation

{$R *.dfm}

procedure deselect;
var
  i: Word;
Begin
  for i := 0 to obj.high do
    obj.arr[i].selected := false;
End;

procedure TForm1.ApplyName;
Begin
  if mapname = '' then
    Caption := '���������� - ' + gamename
  else
    Caption := mapname + ' - ' + gamename;
End;

procedure TForm1.ov(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);
var
  i: Word;
begin
  if obj.down then
  Begin
    obj.arr[(Sender as TImage).Tag].img.Hint := IntToStr((Sender as TImage).Left)+' '+IntToStr((Sender as TImage).Top);
    obj.arr[(Sender as TImage).Tag].img.ShowHint := true;
    obj.moved := true;
    if (obj.x/obj.Width >= 0.8) and (obj.y/obj.Height >= 0.8) then
    Begin
      Screen.Cursor := crSizeNWSE;
      obj.arr[(Sender as TImage).Tag].Width := obj.Width + x - obj.x;
      obj.arr[(Sender as TImage).Tag].Height := obj.Height + y - obj.y;
      (Sender as TImage).Top := (Sender as TImage).Top-1;  
      (Sender as TImage).Top := (Sender as TImage).Top+1;
    End else
    Begin
      Screen.Cursor := crSizeAll;
      if obj.arr[(Sender as TImage).Tag].selected then
      Begin
        if obj.high >= 1 then for i := 1 to obj.high do if obj.arr[i].selected then
          if ssShift in Shift then
          Begin
            obj.arr[i].img.Left := RoundUp(obj.arr[i].img.Left + x - obj.x, 1 + ord(ssShift in Shift)*4 + ord(ssCtrl in Shift) + ord((ssShift in Shift) and (ssCtrl in Shift))*4);
            obj.arr[i].img.Top := RoundUp(obj.arr[i].img.Top + y - obj.y, 1 + ord(ssShift in Shift)*4 + ord(ssCtrl in Shift) + ord((ssShift in Shift) and (ssCtrl in Shift))*4);
          End else
          Begin
            obj.arr[i].img.Left := obj.arr[i].img.Left + x - obj.x;
            obj.arr[i].img.Top := obj.arr[i].img.Top + y - obj.y;
          End;
      End else
      Begin
        deselect;
        obj.arr[(Sender as TImage).Tag].selected := true;
      End;
    End;
    Form1.Repaint;
  End;
End;

procedure TForm1.od(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
var
  Stngs: ^TSettings;
  i: Word;
Begin
  if Button = mbRight then
  Begin
    obj.activate := (Sender as TImage).Tag;
    ObjectActionFrom.Show;
    (ObjectActionFrom.FindComponent('ActionControlGroup') as TGroupBox).Enabled := false;
    (ObjectActionFrom.FindComponent('ActionsSelect') as TComboBox).ItemIndex := 0;
    (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items.Clear;
    if Length(obj.arr[obj.activate].data) > 0 then for i := 0 to High(obj.arr[obj.activate].data) do
    Begin
      (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items.Add;
      (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items[i].SubItems.Add(IntToStr(obj.arr[obj.activate].data[i].id));
      (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items[i].SubItems.Add(IntToStr(obj.arr[obj.activate].data[i].coords.x));
      (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items[i].SubItems.Add(IntToStr(obj.arr[obj.activate].data[i].coords.y));
      case obj.arr[obj.activate].data[i].ActionType of
        MoveObject: (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items[i].Caption := '����������� ������';
        MovePlayer: (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items[i].Caption := '����������� ������';
        KillPlayer: (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items[i].Caption := '����� ������';
        ChangeSpawn: (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items[i].Caption := '�������� �����';
      end;
    End;
  End else
  Begin
    if obj.activate > 0 then (ObjectActionFrom.FindComponent('id') as TEdit).Text := IntToStr((Sender as TImage).Tag) else
    Begin
      obj.x := x;
      obj.y := y;
      obj.Width := (Sender as TImage).Width;
      obj.Height := (Sender as TImage).Height;
      obj.down := true;
      obj.moved := false;
      saved := false;
    End;
  End;
End;

procedure TForm1.ou(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
var
  selected: Word;
  i: Word;
Begin
  selected := 0;
  Screen.Cursor := crArrow;
  obj.down := false;
  if not (ssCtrl in Shift) and (not obj.moved) then deselect;
  if not obj.moved then obj.arr[(Sender as TImage).Tag].selected := true;
  if obj.moved then
  Begin
    for i := 1 to obj.high do if obj.arr[i].selected then inc(selected);
    if selected = 1 then obj.arr[(Sender as TImage).Tag].selected := False;
  End;

  Form1.Repaint;
End;

procedure TForm1.PlayerslistMouseMove(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);
Begin
  if Players.down then
  Begin
    if ssShift in Shift then
    Begin
      (Sender as TImage).Left := RoundUp((Sender as TImage).Left + x - Players.x, 1 + ord(ssShift in Shift)*4 + ord(ssCtrl in Shift) + ord((ssShift in Shift) and (ssCtrl in Shift))*4);
      (Sender as TImage).Top := RoundUp((Sender as TImage).Top + y - Players.y, 1 + ord(ssShift in Shift)*4 + ord(ssCtrl in Shift) + ord((ssShift in Shift) and (ssCtrl in Shift))*4);
    end else
    Begin
      (Sender as TImage).Left := (Sender as TImage).Left + x - Players.x;
      (Sender as TImage).Top := (Sender as TImage).Top + y - Players.y;
    End;
    if ((Sender as TImage).Top < 0) or ((Sender as TImage).Top > PlayersPanel.Height) or ((Sender as TImage).Left < 0) or ((Sender as TImage).Left > PlayersPanel.Width) then
      Screen.Cursor := crDrag
    else Screen.Cursor := crArrow;
  End;
End;

procedure TForm1.PlayerslistMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
Begin
  Players.x := x;
  Players.y := y;
  Players.down := true;
  saved := false;
End;

procedure TForm1.PlayerslistMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
var
  i: Byte;
Begin
  Screen.Cursor := crArrow;
  if ((Sender as TImage).Top < 0) or ((Sender as TImage).Top > PlayersPanel.Height) or ((Sender as TImage).Left < 0) or ((Sender as TImage).Left > PlayersPanel.Width) then
  Begin
    inc(PlayersObjs.high);
    PlayersObjs.arr[PlayersObjs.high].name := Players.arr[(Sender as TImage).Tag].name;
    PlayersObjs.arr[PlayersObjs.high].img := TImage.Create(Form1);
    PlayersObjs.arr[PlayersObjs.high].img.Parent := Form1;
    PlayersObjs.arr[PlayersObjs.high].img.Picture.Bitmap := (Sender as TImage).Picture.Bitmap;
    PlayersObjs.arr[PlayersObjs.high].img.Left := (Sender as TImage).Left + PlayersPanel.Left;
    PlayersObjs.arr[PlayersObjs.high].img.Top := (Sender as TImage).Top + PlayersPanel.Top + (PlayersPanel.Height - PlayersPanel.ClientHeight);
    PlayersObjs.arr[PlayersObjs.high].img.Width := PlayersObjs.arr[PlayersObjs.high].img.Picture.Bitmap.Width;
    PlayersObjs.arr[PlayersObjs.high].img.Height := PlayersObjs.arr[PlayersObjs.high].img.Picture.Bitmap.Height;

    PlayersObjs.arr[PlayersObjs.high].img.tag := PlayersObjs.high;

    PlayersObjs.arr[PlayersObjs.high].img.Picture.Bitmap.TransparentMode := tmFixed;
    PlayersObjs.arr[PlayersObjs.high].img.Picture.Bitmap.TransparentColor := (Sender as TImage).Picture.Bitmap.TransparentColor;
    PlayersObjs.arr[PlayersObjs.high].img.Transparent := true;

    PlayersObjs.arr[PlayersObjs.high].img.OnMouseDown := PlayersMouseDown;
    PlayersObjs.arr[PlayersObjs.high].img.OnMouseUp := PlayersMouseUp;
    PlayersObjs.arr[PlayersObjs.high].img.OnMouseMove := PlayersMouseMove;

    Players.arr[(Sender as TImage).Tag].img.Free;

    if Players.high > (Sender as TImage).Tag then for i := (Sender as TImage).Tag to Players.high-1 do
    Begin
      Players.arr[i] := Players.arr[i+1];
      Players.arr[i].img.Tag := i;
    End;

    dec(Players.high);
  end else
  Begin
    (Sender as TImage).Top := 0;
    if (Sender as TImage).tag = 1 then (Sender as TImage).Left := 0
    else (Sender as TImage).Left := Players.arr[(Sender as TImage).tag - 1].img.Left + Players.arr[(Sender as TImage).tag - 1].img.Picture.Bitmap.Width;
  End;

  Players.down := false;
End;

procedure TForm1.PlayersMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if obj.activate > 0 then (ObjectActionFrom.FindComponent('id') as TEdit).Text := IntToStr((Sender as TImage).Tag) else
  Begin
    PlayersObjs.x := x;
    PlayersObjs.y := y;
    PlayersObjs.down := true;
    PlayersObjs.moved := false;
    saved := false;
  End;
end;

procedure TForm1.PlayersMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  i: Word;
begin
  if PlayersObjs.down then
  Begin
    PlayersObjs.arr[(Sender as TImage).Tag].img.Hint := IntToStr((Sender as TImage).Left)+' '+IntToStr((Sender as TImage).Top);
    PlayersObjs.arr[(Sender as TImage).Tag].img.ShowHint := true;
    PlayersObjs.moved := true;

    Screen.Cursor := crSizeAll;
    if PlayersObjs.arr[(Sender as TImage).Tag].selected then
    Begin
      if PlayersObjs.high >= 1 then for i := 1 to PlayersObjs.high do if PlayersObjs.arr[i].selected then
        if ssShift in Shift then
        Begin
          PlayersObjs.arr[i].img.Left := RoundUp(PlayersObjs.arr[i].img.Left + x - PlayersObjs.x, 1 + ord(ssShift in Shift)*4 + ord(ssCtrl in Shift) + ord((ssShift in Shift) and (ssCtrl in Shift))*4);
          PlayersObjs.arr[i].img.Top := RoundUp(PlayersObjs.arr[i].img.Top + y - PlayersObjs.y, 1 + ord(ssShift in Shift)*4 + ord(ssCtrl in Shift) + ord((ssShift in Shift) and (ssCtrl in Shift))*4);
        End else
        Begin
          PlayersObjs.arr[i].img.Left := PlayersObjs.arr[i].img.Left + x - PlayersObjs.x;
          PlayersObjs.arr[i].img.Top := PlayersObjs.arr[i].img.Top + y - PlayersObjs.y;
        End;
    End else
    Begin
      deselect;
      PlayersObjs.arr[(Sender as TImage).Tag].selected := true;
    End;

    Form1.Repaint;
  End;
end;

procedure TForm1.PlayersMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  selected: Word;
  i: Word;
begin
  selected := 0;
  Screen.Cursor := crArrow;
  PlayersObjs.down := false;
  if not (ssCtrl in Shift) and (not PlayersObjs.moved) then deselect;
  if not PlayersObjs.moved then PlayersObjs.arr[(Sender as TImage).Tag].selected := true;
  if PlayersObjs.moved then
  Begin
    for i := 1 to PlayersObjs.high do if PlayersObjs.arr[i].selected then inc(selected);
    if selected = 1 then PlayersObjs.arr[(Sender as TImage).Tag].selected := False;
  End;

  Form1.Repaint;
end;

procedure TForm1.mv(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);
Begin
  if img.down then
  Begin
    if ssShift in Shift then
    Begin
      (Sender as TImage).Left := RoundUp((Sender as TImage).Left + x - img.x, 1 + ord(ssShift in Shift)*4 + ord(ssCtrl in Shift) + ord((ssShift in Shift) and (ssCtrl in Shift))*4);
      (Sender as TImage).Top := RoundUp((Sender as TImage).Top + y - img.y, 1 + ord(ssShift in Shift)*4 + ord(ssCtrl in Shift) + ord((ssShift in Shift) and (ssCtrl in Shift))*4);
    end else
    Begin
      (Sender as TImage).Left := (Sender as TImage).Left + x - img.x;
      (Sender as TImage).Top := (Sender as TImage).Top + y - img.y;
    End;
    if ((Sender as TImage).Top < 0) or ((Sender as TImage).Top > ObjectsPanel.Height) or ((Sender as TImage).Left < 0) or ((Sender as TImage).Left > ObjectsPanel.Width) then
      Screen.Cursor := crDrag
    else Screen.Cursor := crArrow;
  End;
End;

procedure TForm1.md(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
Begin
  img.x := x;
  img.y := y;
  img.down := true;
  saved := false;
End;

procedure TForm1.mu(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
var
  RS: TResourceStream;
Begin
  Screen.Cursor := crArrow;
  if ((Sender as TImage).Top < 0) or ((Sender as TImage).Top > ObjectsPanel.Height) or ((Sender as TImage).Left < 0) or ((Sender as TImage).Left > ObjectsPanel.Width) then
  Begin
    inc(obj.high);
    obj.arr[obj.high].name := img.arr[(Sender as TImage).Tag].name;
    obj.arr[obj.high].img := TImage.Create(Form1);
    obj.arr[obj.high].img.Parent := Form1;
    obj.arr[obj.high].img.Picture.Bitmap := (Sender as TImage).Picture.Bitmap;
    obj.arr[obj.high].img.Left := (Sender as TImage).Left + ObjectsPanel.Left;
    obj.arr[obj.high].img.Top := (Sender as TImage).Top + ObjectsPanel.Top + (ObjectsPanel.Height - ObjectsPanel.ClientHeight);
    obj.arr[obj.high].img.Width := obj.arr[obj.high].img.Picture.Bitmap.Width;
    obj.arr[obj.high].img.Height := obj.arr[obj.high].img.Picture.Bitmap.Height;
    obj.arr[obj.high].width := obj.arr[obj.high].img.Width;
    obj.arr[obj.high].height := obj.arr[obj.high].img.Height;

    obj.arr[obj.high].img.tag := obj.high;

    obj.arr[obj.high].img.Align := alCustom;
    obj.arr[obj.high].img.Stretch := true;
    obj.arr[obj.high].img.Picture.Bitmap.TransparentMode := tmFixed;
    obj.arr[obj.high].img.Picture.Bitmap.TransparentColor := (Sender as TImage).Picture.Bitmap.TransparentColor;
    obj.arr[obj.high].img.Transparent := true;

    obj.arr[obj.high].img.OnMouseDown := od;
    obj.arr[obj.high].img.OnMouseUp := ou;
    obj.arr[obj.high].img.OnMouseMove := ov;
  end;
  (Sender as TImage).Top := 0;
  if (Sender as TImage).tag = 1 then (Sender as TImage).Left := 0
  else (Sender as TImage).Left := img.arr[(Sender as TImage).tag - 1].img.Left + img.arr[(Sender as TImage).tag - 1].img.Picture.Bitmap.Width;
  img.down := false;
End;

function TForm1.LoadMap: boolean;
var
  i, j, k: Word;
  json: TJSONArray;
  jsonobj: TJSONObject;
  jsondataarr: TJSONArray;
  jsondata: TJSONObject;
begin
  obj.high := 0;
  json := TJSONObject.ParseJSONValue(TFile.ReadAllText(mapname)) as TJSONArray;
  if json.Count > 0 then for i := 0 to json.Count - 1 do
  Begin
    inc(obj.high);
    if img.high > 0 then for j := 1 to img.high do if img.arr[j].name = json.Items[i].FindValue('name').Value then
    Begin
      obj.arr[obj.high].width := StrToInt(json.Items[i].FindValue('width').Value);
      obj.arr[obj.high].height := StrToInt(json.Items[i].FindValue('height').Value);
      obj.arr[obj.high].name := json.Items[i].FindValue('name').Value;
      obj.arr[obj.high].img := TImage.Create(Form1);
      obj.arr[obj.high].img.Parent := Form1;
      Obj.arr[obj.high].img.Tag := obj.high;
      Obj.arr[obj.high].img.Width := Obj.arr[obj.high].img.Picture.Bitmap.Width;
      Obj.arr[obj.high].img.Height := Obj.arr[obj.high].img.Picture.Bitmap.Height;
      obj.arr[obj.high].img.Align := alCustom;
      obj.arr[obj.high].img.Stretch := true;
      obj.arr[obj.high].img.Picture.Bitmap := img.arr[j].img.Picture.Bitmap;
      obj.arr[obj.high].img.Picture.Bitmap.TransparentMode := tmFixed;
      obj.arr[obj.high].img.Picture.Bitmap.TransparentColor := img.arr[j].img.Picture.Bitmap.TransparentColor;
      obj.arr[obj.high].img.Transparent := true;
      Obj.arr[obj.high].img.Left := StrToInt(json.Items[i].FindValue('x').Value);
      Obj.arr[obj.high].img.Top := StrToInt(json.Items[i].FindValue('y').Value);

      Obj.arr[obj.high].img.OnMouseDown := od;
      Obj.arr[obj.high].img.OnMouseUp := ou;
      Obj.arr[obj.high].img.OnMouseMove := ov;

      SetLength(obj.arr[obj.high].data, (json.Items[i].FindValue('data') as TJSONArray).Count);

      if Length(obj.arr[obj.high].data) > 0 then for k := 0 to High(obj.arr[obj.high].data) do
      Begin
        obj.arr[obj.high].data[k].ActionType := TObjectActions(StrToInt((json.Items[i].FindValue('data') as TJSONArray).Items[k].FindValue('ActionType').Value));
        obj.arr[obj.high].data[k].id := StrToInt((json.Items[i].FindValue('data') as TJSONArray).Items[k].FindValue('id').Value);
        obj.arr[obj.high].data[k].coords.X := StrToInt((json.Items[i].FindValue('data') as TJSONArray).Items[k].FindValue('x').Value);
        obj.arr[obj.high].data[k].coords.Y := StrToInt((json.Items[i].FindValue('data') as TJSONArray).Items[k].FindValue('y').Value);
      End;

      break;
    End;
    if Obj.arr[obj.high].name = '' then
    Begin
      ShowMessage('DLL '+json.Items[i].FindValue('name').Value+'.dll not found.');
      dec(obj.high);
    End;
  End;

  {while not Eof(F2) do
  Begin
    inc(save.high);
    Read(F2,save.objs[save.high]);
    inc(obj.high);
    obj.arr[obj.high].width := save.objs[obj.high].width;
    obj.arr[obj.high].height := save.objs[obj.high].height;
    obj.arr[obj.high].img := TImage.Create(Form1);
    obj.arr[obj.high].img.Parent := Form1;
    //obj.arr[obj.high].data := save.objs[obj.high].data;
    if Length(img.arr) > 0 then
    Begin
      for i := 1 to img.high do if img.arr[i].name = save.objs[save.high].name then
      Begin
        Obj.arr[obj.high].img.Picture.Bitmap := img.arr[i].img.Picture.Bitmap;
        Obj.arr[obj.high].name := save.objs[save.high].name;
        Obj.arr[obj.high].img.Tag := obj.high;
        Obj.arr[obj.high].img.Width := Obj.arr[obj.high].img.Picture.Bitmap.Width;
        Obj.arr[obj.high].img.Height := Obj.arr[obj.high].img.Picture.Bitmap.Height;
        obj.arr[obj.high].img.Align := alCustom;
        obj.arr[obj.high].img.Stretch := true;
        obj.arr[obj.high].img.Picture.Bitmap.TransparentMode := tmFixed;
        obj.arr[obj.high].img.Picture.Bitmap.TransparentColor := img.arr[i].img.Picture.Bitmap.TransparentColor;
        obj.arr[obj.high].img.Transparent := true;
        Obj.arr[obj.high].img.Left := save.objs[save.high].x;
        Obj.arr[obj.high].img.Top := save.objs[save.high].y;

        Obj.arr[obj.high].img.OnMouseDown := od;
        Obj.arr[obj.high].img.OnMouseUp := ou;
        Obj.arr[obj.high].img.OnMouseMove := ov;

        break;
      End;
      if Obj.arr[obj.high].name = '' then
      Begin
        ShowMessage('DLL '+save.objs[save.high].name+'.dll not found.');
        dec(save.high);
        dec(obj.high);
      End;
    End;
  End; }

  {AssignFile(F1, mapname+'.settings');
  Reset(F1);
  Read(F1,save.settings);
  Width := save.settings.width;
  Height := save.settings.height; }
  result := true;
End;

function TForm1.SaveMap:boolean;
var
  i, j: Word;
  SaveDialog: TSaveDialog;
  json: TJSONArray;
  jsonobj: TJSONObject;
  jsondataarr: TJSONArray;
  jsondata: TJSONObject;
Begin
  result := false;
  SaveDialog := TSaveDialog.Create(self);
  SaveDialog.Filter := 'File of Map|*.dat';
  SaveDialog.DefaultExt := 'dat';
  if SaveDialog.Execute then
  Begin
    mapname := SaveDialog.FileName;
    Caption := mapname + ' - ' + gamename;
    AssignFile(F, mapname+'.settings');
    Rewrite(F);
    Write(F, save.settings);
    CloseFile(F);

    json := TJSONArray.Create;

    if obj.high > 1 then for i := 1 to obj.high do
    Begin
      json.AddElement(TJSONObject.Create);
      jsonobj := json.Items[pred(json.Count)] as TJSONObject;

      jsondataarr := TJSONArray.Create;
      if Length(obj.arr[i].data) > 0 then
      Begin
        for j := 0 to High(obj.arr[i].data) do
        Begin
          jsondataarr.AddElement(TJSONObject.Create);
          jsondata := jsondataarr.Items[pred(jsondataarr.Count)] as TJSONObject;

          jsondata.AddPair('ActionType', TJSONNumber.Create(Word(obj.arr[i].data[j].ActionType)))
            .AddPair('id', TJSONNumber.Create(obj.arr[i].data[j].id))
            .AddPair('x', TJSONNumber.Create(obj.arr[i].data[j].coords.X))
            .AddPair('y', TJSONNumber.Create(obj.arr[i].data[j].coords.Y));
        End;
      End;

      jsonobj.AddPair('x', TJSONNumber.Create(obj.arr[i].img.Left))
        .AddPair('y', TJSONNumber.Create(obj.arr[i].img.Top))
        .AddPair('width', TJSONNumber.Create(obj.arr[i].width))
        .AddPair('height', TJSONNumber.Create(obj.arr[i].height))
        .AddPair('name', obj.arr[i].name)
        .AddPair('data', jsondataarr);
    End;

    TFile.WriteAllText(mapname, json.Format(2));

    saved := true;
    result := true;
  End;
End;

procedure ApplyObjectActions(Sender: TObject);
var
  i: Word;
begin
  if (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items.Count > 0 then
  Begin
    SetLength(obj.arr[obj.activate].data, (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items.Count);
    for i := 0 to (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items.Count - 1 do
    Begin
      if (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items[i].Caption = '����������� ������' then obj.arr[obj.activate].data[i].ActionType := MoveObject
      else if (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items[i].Caption = '����������� ������' then obj.arr[obj.activate].data[i].ActionType := MovePlayer
      else if (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items[i].Caption = '����� ������' then obj.arr[obj.activate].data[i].ActionType := KillPlayer
      else if (ObjectActionFrom.FindComponent('ActionsList') as TListView).Items[i].Caption = '�������� �����' then obj.arr[obj.activate].data[i].ActionType := ChangeSpawn;

      obj.arr[obj.activate].data[i].id := StrToInt((ObjectActionFrom.FindComponent('ActionsList') as TListView).Items[i].SubItems[0]);
      obj.arr[obj.activate].data[i].coords.X := StrToInt((ObjectActionFrom.FindComponent('ActionsList') as TListView).Items[i].SubItems[1]);
      obj.arr[obj.activate].data[i].coords.Y := StrToInt((ObjectActionFrom.FindComponent('ActionsList') as TListView).Items[i].SubItems[2]);
    End;
  End;

end;

procedure CreateObjectAction(Sender: TObject);
var
  ActionsList: TListView;
Begin
  ActionsList := (ObjectActionFrom.FindComponent('ActionsList') as TListView);
  ActionsList.Items.Add;
  ActionsList.Items[ActionsList.Items.Count - 1].Caption := '����������� ������';
  ActionsList.Items[ActionsList.Items.Count - 1].SubItems.Add('0');
  ActionsList.Items[ActionsList.Items.Count - 1].SubItems.Add('0');
  ActionsList.Items[ActionsList.Items.Count - 1].SubItems.Add('0');
End;

procedure DeleteObjectAction(Sender: TObject);
Begin
  (ObjectActionFrom.FindComponent('ActionsList') as TListView).Selected.Delete;
End;

procedure SelectObjectAction(Sender: TObject; Item: TListItem; Selected: Boolean);
Begin
  Selected := (ObjectActionFrom.FindComponent('ActionsList') as TListView).Selected <> nil;
  (ObjectActionFrom.FindComponent('ActionControlGroup') as TGroupBox).Enabled := Selected;
  if not Selected then exit;
  if Item.Caption = '����������� ������' then (ObjectActionFrom.FindComponent('ActionsSelect') as TComboBox).ItemIndex := 0
  else if Item.Caption = '����������� ������' then (ObjectActionFrom.FindComponent('ActionsSelect') as TComboBox).ItemIndex := 1
  else if Item.Caption = '����� ������' then (ObjectActionFrom.FindComponent('ActionsSelect') as TComboBox).ItemIndex := 2
  else if Item.Caption = '�������� �����' then (ObjectActionFrom.FindComponent('ActionsSelect') as TComboBox).ItemIndex := 3;

  (ObjectActionFrom.FindComponent('id') as TEdit).Text := (ObjectActionFrom.FindComponent('ActionsList') as TListView).Selected.SubItems[0];
  (ObjectActionFrom.FindComponent('x') as TEdit).Text := (ObjectActionFrom.FindComponent('ActionsList') as TListView).Selected.SubItems[1];
  (ObjectActionFrom.FindComponent('y') as TEdit).Text := (ObjectActionFrom.FindComponent('ActionsList') as TListView).Selected.SubItems[2];
End;

procedure ChangeActonsSelect(Sender: TObject);
Begin
  (ObjectActionFrom.FindComponent('id') as TEdit).ReadOnly := (ObjectActionFrom.FindComponent('ActionsSelect') as TComboBox).ItemIndex <= 1;
  (ObjectActionFrom.FindComponent('x') as TEdit).ReadOnly := (ObjectActionFrom.FindComponent('ActionsSelect') as TComboBox).ItemIndex = 2;
  (ObjectActionFrom.FindComponent('y') as TEdit).ReadOnly := (ObjectActionFrom.FindComponent('ActionsSelect') as TComboBox).ItemIndex = 2;
  (ObjectActionFrom.FindComponent('ActionsList') as TListView).Selected.Caption := (ObjectActionFrom.FindComponent('ActionsSelect') as TComboBox).Text;
End;

procedure ChangeId(Sender: TObject);
Begin
  if (ObjectActionFrom.FindComponent('id') as TEdit).Text <> '' then
    (ObjectActionFrom.FindComponent('ActionsList') as TListView).Selected.SubItems[0] := (ObjectActionFrom.FindComponent('id') as TEdit).Text;
End;

procedure ChangeX(Sender: TObject);
Begin
  if (ObjectActionFrom.FindComponent('x') as TEdit).Text <> '' then
    (ObjectActionFrom.FindComponent('ActionsList') as TListView).Selected.SubItems[1] := (ObjectActionFrom.FindComponent('x') as TEdit).Text;
End;

procedure ChangeY(Sender: TObject);
Begin
  if (ObjectActionFrom.FindComponent('y') as TEdit).Text <> '' then
    (ObjectActionFrom.FindComponent('ActionsList') as TListView).Selected.SubItems[2] := (ObjectActionFrom.FindComponent('y') as TEdit).Text;
End;

procedure ObjectActionFromClose(Sender: TObject; var CanClose: Boolean);
Begin
  obj.activate := 0;
End;

function TForm1.CheckSaveMap:boolean;
Begin
  result := false;
  if (not Saved) then
    case MessageDlg('�� ������ ��������� ��������� � �����?',mtConfirmation,mbYesNoCancel,0) of
      mrYes: if not SaveMap then exit;
      mrCancel: exit;
    end;
  result := true;
End;

procedure backalign(Sender: TWinControl; Control: TControl;
  var NewLeft, NewTop, NewWidth, NewHeight: Integer; var AlignRect: TRect;
  AlignInfo: TAlignInfo);
Begin
  NewWidth := Form1.ClientWidth;
  NewHeight := Form1.ClientHeight;
End;

procedure TForm1.FormAlignPosition(Sender: TWinControl; Control: TControl;
  var NewLeft, NewTop, NewWidth, NewHeight: Integer; var AlignRect: TRect;
  AlignInfo: TAlignInfo);
var
  i: Word;
begin
  if ((Control as TImage).Name <> 'background') and (obj.arr[(Control as TImage).Tag].Height > 0) and (obj.arr[(Control as TImage).Tag].Width > 0) then
  Begin
    NewHeight := obj.arr[(Control as TImage).Tag].Height;
    NewWidth := obj.arr[(Control as TImage).Tag].Width;
  End else if (Control as TImage).Name = 'background' then
  Begin
    NewWidth := Width;
    NewHeight := Height;
  End;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //ShowWindow(FindWindow('Shell_TrayWnd', nil), sw_show);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if CheckSaveMap then CanClose := true else CanClose := false;
end;

procedure TForm1.RemoveObj(i: Word);
Begin
  obj.arr[i].img.Free;
  if i < obj.high then for i := i to obj.high-1 do
  Begin
    obj.arr[i] := obj.arr[i+1];
    obj.arr[i].img.Tag := i;
  End;
  dec(obj.high);
End;

procedure TForm1.RemovePlayer(i: Word);
Begin
  Inc(Players.high);
  Players.arr[Players.high].img := TImage.Create(PlayersPanel);
  Players.arr[Players.high].img.Parent := PlayersPanel;
  Players.arr[Players.high].img.Picture.Bitmap := PlayersObjs.arr[i].img.Picture.Bitmap;
  Players.arr[Players.high].img.Width := PlayersObjs.arr[i].img.Picture.Bitmap.Width;
  Players.arr[Players.high].img.Height := PlayersObjs.arr[i].img.Picture.Bitmap.Height;
  Players.arr[Players.high].img.Transparent := true;
  Players.arr[Players.high].img.OnMouseDown := PlayerslistMouseDown;
  Players.arr[Players.high].img.OnMouseUp := PlayerslistMouseUp;
  Players.arr[Players.high].img.OnMouseMove := PlayerslistMouseMove;
  Players.arr[Players.high].img.Tag := Players.high;
  Players.arr[Players.high].name := PlayersObjs.arr[i].name;
  Players.arr[Players.high].img.Top := 0;
  if Players.high = 1 then
    Players.arr[Players.high].img.Left := 0
  else Players.arr[Players.high].img.Left := Players.arr[Players.high-1].img.Left+Players.arr[Players.high-1].img.Width;

  PlayersObjs.arr[i].img.Free;
  if i < PlayersObjs.high then for i := i to PlayersObjs.high-1 do
  Begin
    PlayersObjs.arr[i] := PlayersObjs.arr[i+1];
    PlayersObjs.arr[i].img.Tag := i;
  End;
  dec(PlayersObjs.high);
End;

procedure TForm1.FormCreate(Sender: TObject);
var
  bit: TBitmap;
  animbit: TBitMap;
  test: TImage;
  i: Word;
  x,y: Word;
  Stngs: ^TSettings;
  jpg: TJPEGImage;

begin
  obj.high := 0;
  PlayersObjs.high := 0;

  RegisterClass(TComboBox);
  RegisterClass(TGroupBox);
  RegisterClass(TListView);
  RegisterClass(TEdit);
  RegisterClass(TButton);
  RegisterClass(TMemo);
  RegisterClass(TLabel);

  ObjectActionFrom := TForm.Create(Form1);
  LoadDFMtoComponent('forms/ObjectActions.dfm', ObjectActionFrom);
  ObjectActionFrom.Parent := Form1;
  @(ObjectActionFrom.FindComponent('apply') as TButton).OnClick := @ApplyObjectActions;
  @(ObjectActionFrom.FindComponent('create') as TButton).OnClick := @CreateObjectAction;
  @(ObjectActionFrom.FindComponent('delete') as TButton).OnClick := @DeleteObjectAction;
  @(ObjectActionFrom.FindComponent('ActionsList') as TListView).OnSelectItem := @SelectObjectAction;
  @(ObjectActionFrom.FindComponent('ActionsSelect') as TComboBox).OnChange := @ChangeActonsSelect;
  @(ObjectActionFrom.FindComponent('id') as TEdit).OnChange := @ChangeId;
  @(ObjectActionFrom.FindComponent('x') as TEdit).OnChange := @ChangeX;
  @(ObjectActionFrom.FindComponent('y') as TEdit).OnChange := @ChangeY;
  @ObjectActionFrom.OnCloseQuery := @ObjectActionFromClose;
  ObjectActionFrom.Hide;

  SettingsForm := TForm.Create(Form1);
  LoadDFMtoComponent('forms/SettingsForm.dfm', SettingsForm);

  ObjectsPanel := TForm.Create(Form1);
  ObjectsPanel.Parent := Form1;
  ObjectsPanel.ClientWidth := 0;
  ObjectsPanel.ClientHeight := 0;
  ObjectsPanel.BorderStyle := bsToolWindow;
  ObjectsPanel.Top := 5;
  ObjectsPanel.Show;

  PlayersPanel := TForm.Create(Form1);
  PlayersPanel.Parent := Form1;
  PlayersPanel.ClientWidth := 0;
  PlayersPanel.ClientHeight := 0;
  PlayersPanel.BorderStyle := bsToolWindow;
  PlayersPanel.Show;

  bkg := TBitmap.Create;
  try
    jpg := TJPEGImage.Create;
    jpg.LoadFromFile('background.jpg');
    bkg.Assign(jpg);
  except
  end;
  jpg.Free;
  {background.Picture.Bitmap.Assign(bkg);
  save.settings.width := background.Picture.Bitmap.Width;
  save.settings.height := background.Picture.Bitmap.Height;
  background.Anchors := [akLeft,akTop,akRight,akBottom];
  background.Stretch := true;
  background.Width := ClientWidth;
  background.Height := ClientHeight;
  background.Align := alCustom;  }
  //background.Visible := false;

  myobj := TObj.Create;
  playerslist := TPlayers.Create;
  manager.LoadALL('mods', nil, myobj, playerslist, nil, nil, nil, nil);
  obj.activate := 0;

  if myobj.Count > 0 then for i := 1 to myobj.Count do
  Begin
    bit := TBitmap.Create;
    try
      inc(img.high);

      img.arr[i].img := TImage.Create(ObjectsPanel);
      img.arr[i].img.Parent := ObjectsPanel;
      img.arr[i].img.tag := i;
      img.arr[i].img.Anchors := [akLeft,akBottom];

      if i = 1 then img.arr[i].img.Left := 0
      else img.arr[i].img.Left := img.arr[i-1].img.Left + img.arr[i-1].img.Picture.Bitmap.Width;

      if ObjectsPanel.ClientHeight < img.arr[i].img.Height then ObjectsPanel.ClientHeight := img.arr[i].img.Height;


      img.arr[i].img.Top := 0;
      img.arr[i].img.Picture.Assign(myobj.GIF[i-1].Images.First.Image.Bitmap);

      img.arr[i].Name := myobj.Name[i-1];

      img.arr[i].img.Picture.Bitmap.TransparentMode := tmFixed;
      Stngs := myobj.Settings[i-1];
      img.arr[i].img.Picture.Bitmap.TransparentColor := Stngs.Transparent;
      img.arr[i].img.Transparent := true;

      img.arr[i].img.OnMouseDown := md;
      img.arr[i].img.OnMouseUp := mu;
      img.arr[i].img.OnMouseMove := mv;

      bit.Free;
    except

    end;
  End;

  if playerslist.Count > 0 then for i := 1 to playerslist.Count do
  Begin
    bit := TBitmap.Create;
    try
      inc(Players.high);

      Players.arr[i].img := TImage.Create(PlayersPanel);
      Players.arr[i].img.Parent := PlayersPanel;
      Players.arr[i].img.tag := i;
      Players.arr[i].img.Anchors := [akLeft,akBottom];

      if i = 1 then Players.arr[i].img.Left := 0
      else Players.arr[i].img.Left := Players.arr[i-1].img.Left + Players.arr[i-1].img.Picture.Bitmap.Width;

      if PlayersPanel.ClientHeight < Players.arr[i].img.Height then PlayersPanel.ClientHeight := Players.arr[i].img.Height;

      Players.arr[i].img.Top := 0;
      Players.arr[i].img.Picture.Assign(playerslist.Anim[i-1].stand.Images.First.Image.Bitmap);
      Players.arr[i].img.Width := Players.arr[i].img.Picture.Bitmap.Width;
      Players.arr[i].img.Height := Players.arr[i].img.Picture.Bitmap.Height;

      Players.arr[i].Name := playerslist.Name[i-1];

      Players.arr[i].img.Picture.Bitmap.TransparentMode := tmFixed;
      Stngs := playerslist.Settings[i-1];
      Players.arr[i].img.Picture.Bitmap.TransparentColor := Stngs.Transparent;
      Players.arr[i].img.Transparent := true;

      Players.arr[i].img.OnMouseDown := PlayerslistMouseDown;
      Players.arr[i].img.OnMouseUp := PlayerslistMouseUp;
      Players.arr[i].img.OnMouseMove := PlayerslistMouseMove;

      bit.Free;
    except

    end;
  End;


  PlayersPanel.Top := ClientHeight - ObjectsPanel.Height - 20;
  ObjectsPanel.ClientWidth := img.arr[img.high].img.Left + img.arr[img.high].img.Width;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: Word;
begin
  case Key of
    VK_DELETE:
    Begin
      i := 1;
      while obj.high >= i do
      Begin
        if obj.arr[i].selected then
        Begin
          RemoveObj(i);
          dec(i);
        End;
        inc(i);
      End;

      i := 1;
      while PlayersObjs.high >= i do
      Begin
        if PlayersObjs.arr[i].selected then
        Begin
          RemovePlayer(i);
          dec(i);
        End;
        inc(i);
      End;

      Form1.Repaint;
    End;
    ord('I'):
    Begin
      ObjectsPanel.Visible := not ObjectsPanel.Visible;
      ObjectsPanel.Left := 0;
      ObjectsPanel.Top := 5;
    End;
  end;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  select.selecting := true;
  select.x := x;
  select.y := y;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  i: Word;
begin
  if select.selecting then with Canvas do
  Begin
    Repaint;
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := clBlue;
    Canvas.Pen.Width := 1;
    Canvas.Pen.Style := psDash;
    Rectangle(select.x, select.y, x, y);
  End;
  if y <= 20*(Ord(not N1.Visible)) then N1.Visible := true else N1.Visible := false;
  //for I := 0 to High(img.arr) do img.arr[i].img.Visible := (y >= line.Top);
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Word;
begin
  if obj.high > 1 then for i := 1 to obj.high do
    if ((obj.arr[i].img.Left >= min(select.x, x)) and
       (obj.arr[i].img.Left <= max(select.x, x)) and
       (obj.arr[i].img.Top >= min(select.y, y)) and
       (obj.arr[i].img.Top <= max(select.y, y))) or
       ((obj.arr[i].img.Left + obj.arr[i].img.Width >= min(select.x, x)) and
       (obj.arr[i].img.Left + obj.arr[i].img.Width <= max(select.x, x)) and
       (obj.arr[i].img.Top + obj.arr[i].img.Height >= min(select.y, y)) and
       (obj.arr[i].img.Top + obj.arr[i].img.Height <= max(select.y, y))) then obj.arr[i].selected := true
    else obj.arr[i].selected := false;

  select.selecting := false;
  Form1.Repaint;
end;

procedure TForm1.FormPaint(Sender: TObject);
var
  x,y,i: Word;
begin
  Canvas.Draw(0,0,bkg);

  Canvas.Pen.Color := clGray;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psDot;
  for x := 0 to clientwidth div 60 do
  Begin
    Canvas.MoveTo(x*60, 0);
    Canvas.LineTo(x*60, ClientHeight);
  End;
  for y := 0 to ClientHeight div 60 do
  Begin
    Canvas.MoveTo(0, y*60);
    Canvas.LineTo(ClientWidth, y*60);
  End;

  Canvas.Pen.Width := 2;
  Canvas.Pen.Color := clBlue;
  if obj.high >= 1 then for i := 1 to obj.high do if(obj.arr[i].selected) then
    Canvas.Rectangle(obj.arr[i].img.Left - 1, obj.arr[i].img.Top - 1, obj.arr[i].img.Width + obj.arr[i].img.Left + 2, obj.arr[i].img.Height + obj.arr[i].img.Top + 2);

  if PlayersObjs.high >= 1 then for i := 1 to PlayersObjs.high do if(PlayersObjs.arr[i].selected) then
    Canvas.Rectangle(PlayersObjs.arr[i].img.Left - 1, PlayersObjs.arr[i].img.Top - 1, PlayersObjs.arr[i].img.Width + PlayersObjs.arr[i].img.Left + 2, PlayersObjs.arr[i].img.Height + PlayersObjs.arr[i].img.Top + 2);
end;

procedure TForm1.N2Click(Sender: TObject);
var
  opendialog: TOpenDialog;
  i: Word;
begin
  if CheckSaveMap then
  Begin
    openDialog := TOpenDialog.Create(self);
    openDialog.Options := [ofFileMustExist];
    openDialog.Filter := 'File of Map|*.dat';
    if opendialog.Execute then
    Begin
      Timer1.Enabled := false;
      if obj.high > 1 then for i := 1 to obj.high do obj.arr[i].img.Free;
      obj.high := 1;
      mapname := opendialog.FileName;
      ApplyName;
      LoadMap;
      Timer1.Enabled := true;
    End;
  End;
end;

procedure TForm1.N3Click(Sender: TObject);
begin
  SaveMap;
end;

procedure TForm1.N4Click(Sender: TObject);
var
  i: Word;
begin
  if CheckSaveMap then
  Begin
    SetLength(mapname, 0);
    if obj.high > 1 then for i := 1 to obj.high do obj.arr[i].img.Free;
    obj.high := 1;
    mapname := '';
    ApplyName;
    saved := true;
  End;
end;

procedure TForm1.setformclose(Sender: TObject; var CanClose: Boolean);
Begin
  if (SettingsForm.FindComponent('width') as TEdit).Text <> '' then Form1.Width := StrToInt((SettingsForm.FindComponent('width') as TEdit).Text);
  if (SettingsForm.FindComponent('width') as TEdit).Text <> '' then save.settings.width := StrToInt((SettingsForm.FindComponent('width') as TEdit).Text);
  if (SettingsForm.FindComponent('height') as TEdit).Text <> '' then Form1.Height := StrToInt((SettingsForm.FindComponent('height') as TEdit).Text);
  if (SettingsForm.FindComponent('height') as TEdit).Text <> '' then save.settings.height := StrToInt((SettingsForm.FindComponent('height') as TEdit).Text);
  Form1.Enabled := true;
  ObjectsPanel.Enabled := true;
  CanClose := true;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i: Word;
  x,y: Word;
begin
  {Canvas.Pen.Width := 2;
  Canvas.Pen.Color := clBlue;

  Refresh;}

  if obj.high > 1 then for i := 1 to obj.high do
    if(obj.arr[i].selected) then Canvas.Rectangle(obj.arr[i].img.Left - 1, obj.arr[i].img.Top - 1, obj.arr[i].img.Width + obj.arr[i].img.Left + 2, obj.arr[i].img.Height + obj.arr[i].img.Top + 2);


  {if(obj.activate > 0) then
  Begin
    Canvas.MoveTo(obj.arr[obj.activate].img.Left + obj.arr[obj.activate].img.Width div 2, obj.arr[obj.activate].img.Top + obj.arr[obj.activate].img.Height div 2);
    Canvas.LineTo(Mouse.CursorPos.X, Mouse.CursorPos.Y);
  End; }
  {
  Canvas.Pen.Style := psDash;
  Canvas.Pen.Color := clBlue; }
end;

procedure TForm1.N5Click(Sender: TObject);
begin
  SettingsForm.Show;
  SettingsForm.OnCloseQuery := setformclose;
  Form1.Enabled := false;
  ObjectsPanel.Enabled := false;
end;

procedure TForm1.N6Click(Sender: TObject);
begin
  Close;
end;

end.
