unit MapEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, FileCtrl, Menus,
  ComCtrls, TFNW, ImgList, ExtCtrls, Math,
  Jpeg, GIFImg, DLLManager;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem; 
    N5: TMenuItem;
    N6: TMenuItem;
    background: TImage;
    Timer1: TTimer;
    procedure Button2Click(Sender: TObject);
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

    procedure Remove(i: Word);

    procedure ov(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);
    procedure od(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
    procedure ou(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

    procedure mv(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);
    procedure md(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
    procedure mu(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
    
    procedure FormPaint(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure setformclose(Sender: TObject; var CanClose: Boolean);
    procedure SaveBtn(Sender: TObject);
    procedure FormAlignPosition(Sender: TWinControl; Control: TControl;
      var NewLeft, NewTop, NewWidth, NewHeight: Integer; var AlignRect: TRect;
      AlignInfo: TAlignInfo);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  gamename = 'FireBoy & Water Girl map edit';

var
  Form1: TForm1;
  Form2: TForm;
  FormPanel: TForm;
  settings: record
    width, height, players: TEdit;
    start: record
      x,y: TEdit;
    end;
    widthlabel, heightlabel, playerslabel, startxlabel, startylabel: TLabel;
    savebtn: TButton;
  end;
  manager: TDLLManager;
  mapname: string;
  save: record
    objs: array of Tmap;
    settings: TSettingsMap;
  end;
  F1: File of TSettingsMap;
  F2: File of Tmap;
  saved: boolean=true;
  fullscreen: boolean=false;
  img: record
    x,y: Word;
    down: boolean;
    arr: array of record
      img: TImage;
      name: string[32];
    end;
  end;
  obj: record
    x,y: Word;
    Width, Height: Word;
    down: boolean;
    moved: boolean;
    arr: array of record
      img: TImage;
      width, height: Word;
      selected: boolean;
      name: string[32];
    end;
  end;
  select: record
    x,y: Word;
    selecting: boolean;
  end;
  bkg: TImage;

implementation

{$R *.dfm}

procedure deselect;
var
  i: Word;
Begin
  for i := 0 to High(obj.arr) do
    obj.arr[i].selected := false;
End;

procedure TForm1.ApplyName;
Begin
  if mapname = '' then
    Caption := 'Безымянный - ' + gamename
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
      obj.arr[(Sender as TImage).Tag].Width := obj.Width + x - obj.x;
      obj.arr[(Sender as TImage).Tag].Height := obj.Height + y - obj.y;
      (Sender as TImage).Top := (Sender as TImage).Top-1;  
      (Sender as TImage).Top := (Sender as TImage).Top+1;
    End else
    Begin
      if obj.arr[(Sender as TImage).Tag].selected then
      Begin
        if Length(obj.arr) > 0 then for i := 0 to High(obj.arr) do if obj.arr[i].selected then
        Begin
          if ssShift in Shift then
            obj.arr[i].img.Left := RoundUp(obj.arr[i].img.Left + x - obj.x, 1 + ord(ssShift in Shift)*4 + ord(ssCtrl in Shift) + ord((ssShift in Shift) and (ssCtrl in Shift))*4)
          else obj.arr[i].img.Left := obj.arr[i].img.Left + x - obj.x;
          if ssShift in Shift then
            obj.arr[i].img.Top := RoundUp(obj.arr[i].img.Top + y - obj.y, 1 + ord(ssShift in Shift)*4 + ord(ssCtrl in Shift) + ord((ssShift in Shift) and (ssCtrl in Shift))*4)
          else obj.arr[i].img.Top := obj.arr[i].img.Top + y - obj.y;
        End;
      End else
      Begin
        deselect;
        obj.arr[(Sender as TImage).Tag].selected := true;
        if ssShift in Shift then
          obj.arr[(Sender as TImage).Tag].img.Left := RoundUp(obj.arr[(Sender as TImage).Tag].img.Left + x - obj.x, 1 + ord(ssShift in Shift)*4 + ord(ssCtrl in Shift) + ord((ssShift in Shift) and (ssCtrl in Shift))*4)
        else obj.arr[(Sender as TImage).Tag].img.Left := obj.arr[(Sender as TImage).Tag].img.Left + x - obj.x;

        if ssShift in Shift then
          obj.arr[(Sender as TImage).Tag].img.Top := RoundUp(obj.arr[(Sender as TImage).Tag].img.Top + y - obj.y, 1 + ord(ssShift in Shift)*4 + ord(ssCtrl in Shift) + ord((ssShift in Shift) and (ssCtrl in Shift))*4)
        else obj.arr[(Sender as TImage).Tag].img.Top := obj.arr[(Sender as TImage).Tag].img.Top + y - obj.y;
      End;
    End;
    Form1.Repaint;
  End;
End;

procedure TForm1.od(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
Begin
  obj.x := x;
  obj.y := y;
  obj.Width := (Sender as TImage).Width;
  obj.Height := (Sender as TImage).Height;
  obj.down := true;
  obj.moved := false;
  saved := false;
End;

procedure TForm1.ou(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
var
  selected: Word;
  i: Word;
Begin
  selected := 0;
  //if (Sender as TImage).Top > line.Top then Remove((Sender as TImage).Tag);
  obj.down := false;
  if not (ssCtrl in Shift) and (not obj.moved) then deselect;
  if not obj.moved then obj.arr[(Sender as TImage).Tag].selected := true;
  if obj.moved then
  Begin
    for i := 0 to High(obj.arr) do if obj.arr[i].selected then inc(selected);
    if selected = 1 then obj.arr[(Sender as TImage).Tag].selected := False;
  End;

  Form1.Repaint;
End;

procedure TForm1.mv(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);
Begin
  if img.down then
  Begin
    if ssShift in Shift then (Sender as TImage).Left := RoundUp((Sender as TImage).Left + x - img.x, 1 + ord(ssShift in Shift)*4 + ord(ssCtrl in Shift) + ord((ssShift in Shift) and (ssCtrl in Shift))*4)
    else (Sender as TImage).Left := (Sender as TImage).Left + x - img.x;

    if ssShift in Shift then (Sender as TImage).Top := RoundUp((Sender as TImage).Top + y - img.y, 1 + ord(ssShift in Shift)*4 + ord(ssCtrl in Shift) + ord((ssShift in Shift) and (ssCtrl in Shift))*4)
    else (Sender as TImage).Top := (Sender as TImage).Top + y - img.y;
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
  if ((Sender as TImage).Top < 0) or ((Sender as TImage).Top > FormPanel.Height) or ((Sender as TImage).Left < 0) or ((Sender as TImage).Left > FormPanel.Width) then
  Begin
    SetLength(obj.arr, Length(obj.arr)+1);
    obj.arr[High(obj.arr)].name := img.arr[(Sender as TImage).Tag].name;
    obj.arr[High(obj.arr)].img := TImage.Create(Form1);
    obj.arr[High(obj.arr)].img.Parent := Form1;
    obj.arr[High(obj.arr)].img.Picture.Bitmap := (Sender as TImage).Picture.Bitmap;
    obj.arr[High(obj.arr)].img.Left := (Sender as TImage).Left + FormPanel.Left;
    obj.arr[High(obj.arr)].img.Top := (Sender as TImage).Top + FormPanel.Top + (FormPanel.Height - FormPanel.ClientHeight);
    obj.arr[High(obj.arr)].img.Width := obj.arr[High(obj.arr)].img.Picture.Bitmap.Width;
    obj.arr[High(obj.arr)].img.Height := obj.arr[High(obj.arr)].img.Picture.Bitmap.Height;
    obj.arr[High(obj.arr)].width := obj.arr[High(obj.arr)].img.Width;
    obj.arr[High(obj.arr)].height := obj.arr[High(obj.arr)].img.Height;

    obj.arr[High(obj.arr)].img.tag := High(obj.arr);

    obj.arr[High(obj.arr)].img.Align := alCustom;
    obj.arr[High(obj.arr)].img.Stretch := true;
    obj.arr[High(obj.arr)].img.Picture.Bitmap.TransparentMode := tmFixed;
    obj.arr[High(obj.arr)].img.Picture.Bitmap.TransparentColor := (Sender as TImage).Picture.Bitmap.TransparentColor;
    obj.arr[High(obj.arr)].img.Transparent := true;

    obj.arr[High(obj.arr)].img.OnMouseDown := od;
    obj.arr[High(obj.arr)].img.OnMouseUp := ou;
    obj.arr[High(obj.arr)].img.OnMouseMove := ov;
  end;
  (Sender as TImage).Top := 0;
  if (Sender as TImage).tag = 0 then (Sender as TImage).Left := 0
  else (Sender as TImage).Left := img.arr[(Sender as TImage).tag - 1].img.Left + img.arr[(Sender as TImage).tag - 1].img.Picture.Bitmap.Width;
  img.down := false;
End;

function TForm1.LoadMap: boolean;
var
  i: Word;
begin
  AssignFile(F2, mapname);
  Reset(F2);
  //SetLength(mapname,0);
  SetLength(Obj.arr,0);
  SetLength(save.objs,0);
  while not Eof(F2) do
  Begin
    SetLength(save.objs,Length(save.objs)+1);
    Read(F2,save.objs[High(save.objs)]);
    SetLength(Obj.arr,Length(Obj.arr)+1);
    obj.arr[High(Obj.arr)].width := save.objs[High(save.objs)].width;
    obj.arr[High(Obj.arr)].height := save.objs[High(save.objs)].height;
    obj.arr[High(Obj.arr)].img := TImage.Create(Form1);
    obj.arr[High(Obj.arr)].img.Parent := Form1;
    if Length(img.arr) > 0 then
    Begin
      for i := 0 to High(img.arr) do if img.arr[i].name = save.objs[High(save.objs)].name then
      Begin
        Obj.arr[High(Obj.arr)].img.Picture.Bitmap := img.arr[i].img.Picture.Bitmap;
        Obj.arr[High(Obj.arr)].name := save.objs[High(save.objs)].name;
        Obj.arr[High(Obj.arr)].img.Tag := High(Obj.arr);
        Obj.arr[High(Obj.arr)].img.Width := Obj.arr[High(Obj.arr)].img.Picture.Bitmap.Width;
        Obj.arr[High(Obj.arr)].img.Height := Obj.arr[High(Obj.arr)].img.Picture.Bitmap.Height;
        obj.arr[High(obj.arr)].img.Align := alCustom;
        obj.arr[High(obj.arr)].img.Stretch := true;
        obj.arr[High(obj.arr)].img.Picture.Bitmap.TransparentMode := tmFixed;
        obj.arr[High(obj.arr)].img.Picture.Bitmap.TransparentColor := img.arr[i].img.Picture.Bitmap.TransparentColor;
        obj.arr[High(obj.arr)].img.Transparent := true;
        Obj.arr[High(Obj.arr)].img.Left := save.objs[High(save.objs)].x;
        Obj.arr[High(Obj.arr)].img.Top := save.objs[High(save.objs)].y;

        Obj.arr[High(Obj.arr)].img.OnMouseDown := od;
        Obj.arr[High(Obj.arr)].img.OnMouseUp := ou;
        Obj.arr[High(Obj.arr)].img.OnMouseMove := ov;

        break;
      End;
      if Obj.arr[High(Obj.arr)].name = '' then
      Begin
        ShowMessage('DLL '+save.objs[High(save.objs)].name+'.dll not found.');
        SetLength(save.objs,Length(save.objs)-1);
        SetLength(Obj.arr,Length(Obj.arr)-1);
      End;
    End;
  End;
  CloseFile(F2);
  AssignFile(F1, mapname+'.settings');
  Reset(F1);
  Read(F1,save.settings);
  Width := save.settings.width;
  Height := save.settings.height;
  result := true;
End;

function TForm1.SaveMap:boolean;
var
  i: Word;
  SaveDialog: TSaveDialog;
Begin
  result := false;
  SaveDialog := TSaveDialog.Create(self);
  SaveDialog.Filter := 'File of Map|*.dat';
  if SaveDialog.Execute then
  Begin
    mapname := SaveDialog.FileName;
    Caption := mapname + ' - ' + gamename;
    AssignFile(F1, mapname+'.settings');
    Rewrite(F1);
    Write(F1, save.settings);
    CloseFile(F1);

    AssignFile(F2, mapname);
    Rewrite(F2);

    for i := 0 to High(obj.arr) do
    Begin
      SetLength(save.objs, Length(save.objs)+1);
      save.objs[i].x := obj.arr[i].img.Left;
      save.objs[i].y := obj.arr[i].img.Top;
      save.objs[i].width := obj.arr[i].width;
      save.objs[i].height := obj.arr[i].height;
      save.objs[i].name := obj.arr[i].name;
      Write(F2, save.objs[i]);
    End;

    CloseFile(F2);
    saved := true;
    result := true;
  End;
End;

function TForm1.CheckSaveMap:boolean;
Begin
  result := false;
  if (not Saved) then
    case MessageDlg('Вы хотите сохранить изменения в карте?',mtConfirmation,mbYesNoCancel,0) of
      mrYes: if not SaveMap then exit;
      mrCancel: exit;
    end;
  result := true;
End;

procedure TForm1.Button2Click(Sender: TObject);
var
  F: File of TMap;
  Sv: TMap;
begin
  Reset(F);
  SetLength(save.objs,0);
  while not Eof(F) do
  Begin
    Read(F,Sv);
    SetLength(save.objs,Length(save.objs)+1);
    save.objs[High(save.objs)] := Sv;
  End;
  ShowMessage(IntToStr(Length(save.objs)));
end;

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

procedure TForm1.Remove(i: Word);
Begin
  obj.arr[i].img.Free;
  if i < High(obj.arr) then for i := i to High(obj.arr)-1 do
  Begin
    obj.arr[i] := obj.arr[i+1];
    obj.arr[i].img.Tag := i;
  End;
  SetLength(obj.arr, Length(obj.arr)-1);
End;

procedure TForm1.FormCreate(Sender: TObject);
var
  bit: TBitmap;
  animbit: TBitMap;
  test: TImage;
  i: Word;
  myobj: TObj;
  Stngs: ^TSettings;
  bkg: TJPEGImage;

begin
  FormPanel := TForm.Create(Form1);
  FormPanel.Parent := Form1;
  //FormPanel.Visible := false;
  FormPanel.ClientWidth := 0;
  FormPanel.ClientHeight := 0;
  FormPanel.BorderStyle := bsToolWindow;
  FormPanel.Show;

  bkg := TJPEGImage.Create;
  bkg.LoadFromFile('background.jpg');
  background.Picture.Bitmap.Assign(bkg);
  save.settings.width := background.Picture.Bitmap.Width;
  save.settings.height := background.Picture.Bitmap.Height;
  background.Anchors := [akLeft,akTop,akRight,akBottom];
  background.Stretch := true;
  background.Width := ClientWidth;
  background.Height := ClientHeight;
  background.Align := alCustom;
  //background.Visible := false;

  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Color := clBlue;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psDash;

  myobj := TObj.Create;
  manager.LoadALL('mods', nil, myobj);

  if myobj.Count > 0 then for i := 0 to myobj.Count - 1 do
  Begin
    bit := TBitmap.Create;
    try
      bit.Assign(myobj.pic[i]);
      SetLength(img.arr,Length(img.arr)+1);

      img.arr[i].img := TImage.Create(FormPanel);
      img.arr[i].img.Parent := FormPanel;
      img.arr[i].img.tag := i;
      img.arr[i].img.Anchors := [akLeft,akBottom];

      if i = 0 then img.arr[i].img.Left := 0
      else img.arr[i].img.Left := img.arr[i-1].img.Left + img.arr[i-1].img.Picture.Bitmap.Width;

      if FormPanel.ClientHeight < img.arr[i].img.Height then FormPanel.ClientHeight := img.arr[i].img.Height;


      img.arr[i].img.Top := 0;
      img.arr[i].img.Picture.Bitmap := bit;

      img.arr[i].Name := myobj.Name[i];

      img.arr[i].img.Picture.Bitmap.TransparentMode := tmFixed;
      Stngs := myobj.Settings[i];
      img.arr[i].img.Picture.Bitmap.TransparentColor := Stngs.Transparent;
      img.arr[i].img.Transparent := true;

      {if Stngs.animation then
      Begin
        test := TImage.Create(form1);
        test.Parent := form1;
        test.Canvas.Draw(0,0,myobj.GIF[i].Images.Frames[0].Bitmap);
        test.Picture.Bitmap.TransparentColor := clBlack;
        test.Picture.Bitmap.TransparentMode := tmFixed;
        test.Transparent := true;
        img.arr[i].img.Canvas.Draw(Stngs.AnimPos.x,Stngs.AnimPos.y,test.Picture.Bitmap);
        test.Free;
      End;}

      img.arr[i].img.OnMouseDown := md;
      img.arr[i].img.OnMouseUp := mu;
      img.arr[i].img.OnMouseMove := mv;

      bit.Free;
    except

    end;
  End;

  FormPanel.ClientWidth := img.arr[High(img.arr)].img.Left + img.arr[High(img.arr)].img.Width;

  {myobj := TObj.Create;
  manager.LoadALL('mods', nil, myobj);

  if myobj.Count > 0 then for i := 0 to myobj.Count - 1 do
  Begin
    bit := TBitmap.Create;
    try
      bit.Assign(myobj.pic[i]);
      SetLength(img.arr,Length(img.arr)+1); 

      img.arr[i].img := TImage.Create(Form1);
      img.arr[i].img.Parent := Form1;   
      img.arr[i].img.tag := i;
      img.arr[i].img.Anchors := [akLeft,akBottom];
      
      if i = 0 then img.arr[i].img.Left := 0
      else img.arr[i].img.Left := img.arr[i-1].img.Left + img.arr[i-1].img.Picture.Bitmap.Width;
      
      if bit.Height > ClientHeight - line.Top then line.Top := ClientHeight - bit.Height;

      img.arr[i].img.Top := ClientHeight - bit.Height;
      img.arr[i].img.Picture.Bitmap := bit;

      img.arr[i].Name := myobj.Name[i];

      img.arr[i].img.Picture.Bitmap.TransparentMode := tmFixed;
      Stngs := myobj.Settings[i];
      img.arr[i].img.Picture.Bitmap.TransparentColor := Stngs.Transparent;
      img.arr[i].img.Transparent := true;

      {if Stngs.animation then
      Begin
        test := TImage.Create(form1);
        test.Parent := form1;
        test.Canvas.Draw(0,0,myobj.GIF[i].Images.Frames[0].Bitmap);
        test.Picture.Bitmap.TransparentColor := clBlack;
        test.Picture.Bitmap.TransparentMode := tmFixed;
        test.Transparent := true;
        img.arr[i].img.Canvas.Draw(Stngs.AnimPos.x,Stngs.AnimPos.y,test.Picture.Bitmap);
        test.Free;
      End;

      img.arr[i].img.OnMouseDown := md;
      img.arr[i].img.OnMouseUp := mu;
      img.arr[i].img.OnMouseMove := mv;

      bit.Free;
    except

    end;
  End; }

end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: Word;
begin
  case Key of
    VK_DELETE:
    Begin
      i := 0;
      while High(obj.arr) >= i do
      Begin
        if obj.arr[i].selected then
        Begin
          Remove(i);
          dec(i);
        End;
        inc(i);
      End;
      Form1.Repaint;
    End;
    ord('I'):
    Begin
      FormPanel.Visible := not FormPanel.Visible;
      FormPanel.Left := 0;
      FormPanel.Top := 0;
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
    Rectangle(select.x, select.y, x, y);
  End;
  if y <= 20 then N1.Visible := true else N1.Visible := false;
  //for I := 0 to High(img.arr) do img.arr[i].img.Visible := (y >= line.Top);
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Word;
begin

  if length(obj.arr) > 0 then for i := 0 to High(obj.arr) do
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
  x,y: Word;
  i: Word;
begin
  //Canvas.Draw(0,0,bkg.Picture.Bitmap);
  {Canvas.Pen.Style := psSolid;
  Canvas.Pen.Color := $e6e6e6;
  Canvas.Pen.Width := 1;

  for x := 1 to ClientWidth div 10 do
  Begin
    Canvas.MoveTo(x*10, 0);
    Canvas.LineTo(x*10, ClientHeight);
  End;
  for y := 1 to ClientHeight div 10 do
  Begin
    Canvas.MoveTo(0, y*10);
    Canvas.LineTo(ClientWidth, y*10);
  End;}


  {Canvas.Pen.Width := 2;
  Canvas.Pen.Color := clBlue;

  if Length(obj.arr) > 0 then for i := 0 to High(obj.arr) do
    if(obj.arr[i].selected) then Canvas.Rectangle(obj.arr[i].img.Left - 1, obj.arr[i].img.Top - 1, obj.arr[i].img.Width + obj.arr[i].img.Left + 2, obj.arr[i].img.Height + obj.arr[i].img.Top + 2);

  Canvas.Pen.Style := psDash;
  Canvas.Pen.Color := clBlue;}
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
      if Length(obj.arr) > 0 then for i := 0 to High(obj.arr) do obj.arr[i].img.Free;
      SetLength(obj.arr, 0);
      mapname := opendialog.FileName;
      ApplyName;
      LoadMap;
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
    if Length(obj.arr) > 0 then for i := 0 to High(obj.arr) do obj.arr[i].img.Free;
    SetLength(obj.arr, 0);
    mapname := '';
    ApplyName;
    saved := true;
  End;
end;

procedure TForm1.setformclose(Sender: TObject; var CanClose: Boolean);
Begin
  Form1.Enabled := true;
  FormPanel.Enabled := true;
  CanClose := true;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i: Word;
  x,y: Word;
begin
  {Canvas.Pen.Style := psSolid;
  Canvas.Pen.Color := $e6e6e6;
  Canvas.Pen.Width := 1;

  for x := 1 to ClientWidth div 10 do
  Begin
    Canvas.MoveTo(x*10, 0);
    Canvas.LineTo(x*10, ClientHeight);
  End;
  for y := 1 to ClientHeight div 10 do
  Begin
    Canvas.MoveTo(0, y*10);
    Canvas.LineTo(ClientWidth, y*10);
  End;   }

  Canvas.Pen.Width := 2;
  Canvas.Pen.Color := clBlue;

  if Length(obj.arr) > 0 then for i := 0 to High(obj.arr) do
    if(obj.arr[i].selected) then Canvas.Rectangle(obj.arr[i].img.Left - 1, obj.arr[i].img.Top - 1, obj.arr[i].img.Width + obj.arr[i].img.Left + 2, obj.arr[i].img.Height + obj.arr[i].img.Top + 2);

  Canvas.Pen.Style := psDash;
  Canvas.Pen.Color := clBlue;
end;

procedure TForm1.SaveBtn(Sender: TObject);
Begin
  if Settings.width.Text <> '' then Form1.Width := StrToInt(Settings.width.Text);
  if Settings.width.Text <> '' then save.settings.width := StrToInt(Settings.width.Text);
  if Settings.height.Text <> '' then Form1.Height := StrToInt(Settings.height.Text);
  if Settings.height.Text <> '' then save.settings.height := StrToInt(Settings.height.Text);
  if settings.players.Text <> '' then save.settings.players := StrToInt(settings.players.Text);
  if settings.start.x.Text <> '' then save.settings.start[0].x := StrToInt(settings.start.x.Text);
  if settings.start.y.Text <> '' then save.settings.start[0].y := StrToInt(settings.start.y.Text);
End;

procedure TForm1.N5Click(Sender: TObject);
begin
  Form2 := TForm.Create(Form1);
  Form2.Parent := nil;
  settings.width := TEdit.Create(Form2);
  settings.height := TEdit.Create(Form2);
  settings.players := TEdit.Create(Form2);
  settings.start.x := TEdit.Create(Form2);
  settings.start.y := TEdit.Create(Form2);
  settings.savebtn := TButton.Create(Form2);
  settings.widthlabel := TLabel.Create(Form2);
  settings.heightlabel := TLabel.Create(Form2);
  settings.playerslabel := TLabel.Create(Form2);
  settings.startxlabel := TLabel.Create(Form2);
  settings.startylabel := TLabel.Create(Form2);
  settings.width.Parent := Form2;
  settings.height.Parent := Form2;
  settings.start.x.Parent := Form2;
  settings.start.y.Parent := Form2;
  settings.players.Parent := Form2;
  settings.savebtn.Parent := Form2;
  settings.widthlabel.Parent := Form2;
  settings.heightlabel.Parent := Form2;
  settings.playerslabel.Parent := Form2;
  settings.startxlabel.Parent := Form2;
  settings.startylabel.Parent := Form2;
  settings.width.Left := 34;
  settings.height.Left := settings.width.Left + settings.width.Width + 40;
  settings.start.x.Left := 34;
  settings.start.y.Left := settings.start.x.Left + settings.start.x.Width + 40;
  settings.players.Left := 34;
  settings.players.Top := settings.width.Height + 6;
  settings.start.x.Top := settings.players.Top + settings.players.Height + 6;
  settings.start.y.Top := settings.players.Top + settings.players.Height + 6;
  settings.savebtn.Top := settings.start.x.Top + settings.start.x.Height + 6;
  settings.playerslabel.Top := settings.players.Top;
  settings.startxlabel.Top := settings.start.x.Top;
  settings.startylabel.Top := settings.start.y.Top;
  settings.startylabel.Left := settings.start.x.Left + settings.start.x.Width + 3;
  settings.widthlabel.Left := settings.width.Left + settings.width.Width + 3;
  settings.savebtn.OnClick := SaveBtn;
  settings.savebtn.Left := 34;
  settings.widthlabel.Caption := 'width:';
  settings.heightlabel.Caption := 'height:';
  settings.playerslabel.Caption := 'players:';
  settings.startxlabel.Caption := 'start x:';
  settings.startylabel.Caption := 'start y:';
  settings.savebtn.Caption := 'SAVE';
  settings.width.Text := IntToStr(Form1.Width);
  settings.height.Text := IntToStr(Form1.Height);
  settings.players.Text := IntToStr(save.settings.players);
  settings.start.x.Text := IntToStr(save.settings.start[0].x);
  settings.start.y.Text := IntToStr(save.settings.start[0].y);
  Form2.BorderIcons := [biSystemMenu,biMinimize];
  Form2.BorderStyle := bsSingle;
  Form2.Show;
  Form2.OnCloseQuery := setformclose;
  Form1.Enabled := false;
end;

procedure TForm1.N6Click(Sender: TObject);
begin
  Close;
end;

end.
