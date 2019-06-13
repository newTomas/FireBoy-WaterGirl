unit MapEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, FileCtrl, Vcl.Menus,
  Vcl.ComCtrls, TFNW, System.ImageList, Vcl.ImgList, Vcl.ExtCtrls, Math,
  Vcl.Imaging.pngimage, DLLManager;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    line: TPanel;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    function SaveMap: boolean;
    function LoadMap: boolean;

    function CheckSaveMap: boolean;
    procedure ApplyName;
    function MyRound(num: LongWord):LongWord;
    
    procedure md(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
    procedure mu(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
    procedure mv(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);
                                                                               
    procedure od(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
    procedure ou(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
    procedure ov(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);

    procedure Remove(i: Word);
    
    procedure FormPaint(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  gamename = 'FireBoy & Water Girl map edit';

var
  Form1: TForm1;
  manager: TDLLManager;
  map: array of Tmap;
  namemap: string;
  F: File of TMap;
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
    down: boolean;
    arr: array of record
      img: TImage;
      selected: boolean;
      name: string[32];
      rotate: Single;
    end;
  end;
  select: record
    x,y: Word;
    selecting: boolean;
  end;

implementation

{$R *.dfm}

procedure TForm1.ApplyName;
Begin
  if namemap = '' then
    Caption := 'Безымянный - ' + gamename
  else 
    Caption := namemap + ' - ' + gamename;
End;

function TForm1.MyRound(num: LongWord):LongWord;
Begin
  case (num mod 10) of
    0..2: result := num div 10 * 10;
    3..7: result := num div 10 * 10 + 5;
    8..9: result := (num div 10 + 1) * 10;
  end;
End;

procedure TForm1.ov(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);
var
  i: Word;
begin
  if obj.down then
  Begin
    if obj.arr[(Sender as TImage).Tag].selected then
    Begin
      if Length(obj.arr) > 0 then for i := 0 to High(obj.arr) do if obj.arr[i].selected then
      Begin
        obj.arr[i].img.Left := obj.arr[i].img.Left + x - obj.x;
        obj.arr[i].img.Top := obj.arr[i].img.Top + y - obj.y;
      End;
    End else
    Begin
      if ssShift in Shift then (Sender as TImage).Left := MyRound((Sender as TImage).Left + x - obj.x)
      else (Sender as TImage).Left := (Sender as TImage).Left + x - obj.x;

      if ssShift in Shift then (Sender as TImage).Top := MyRound((Sender as TImage).Top + y - obj.y)
      else (Sender as TImage).Top := (Sender as TImage).Top + y - obj.y;
    End;
  End;
End;

procedure TForm1.od(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
Begin
  obj.x := x;
  obj.y := y;
  obj.down := true;
  saved := false;
End;

procedure TForm1.ou(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
Begin
  if (Sender as TImage).Top > line.Top then Remove((Sender as TImage).Tag);
  obj.down := false;
End;

procedure TForm1.mv(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);
Begin
  if img.down then
  Begin
    if ssShift in Shift then (Sender as TImage).Left := MyRound((Sender as TImage).Left + x - img.x)
    else (Sender as TImage).Left := (Sender as TImage).Left + x - img.x;

    if ssShift in Shift then (Sender as TImage).Top := MyRound((Sender as TImage).Top + y - img.y)
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
Begin
  if (Sender as TImage).Top < line.Top then
  Begin
    SetLength(obj.arr, Length(obj.arr)+1);
    obj.arr[High(obj.arr)].name := img.arr[(Sender as TImage).Tag].name;
    obj.arr[High(obj.arr)].img := TImage.Create(Form1);
    obj.arr[High(obj.arr)].img.Parent := Form1;
    obj.arr[High(obj.arr)].img.Picture.Bitmap := (Sender as TImage).Picture.Bitmap;
    obj.arr[High(obj.arr)].img.Left := (Sender as TImage).Left;
    obj.arr[High(obj.arr)].img.Top := (Sender as TImage).Top;
    obj.arr[High(obj.arr)].img.Width := obj.arr[High(obj.arr)].img.Picture.Bitmap.Width;
    obj.arr[High(obj.arr)].img.Height := obj.arr[High(obj.arr)].img.Picture.Bitmap.Height;

    obj.arr[High(obj.arr)].img.tag := High(obj.arr);

    obj.arr[High(obj.arr)].img.OnMouseDown := od;
    obj.arr[High(obj.arr)].img.OnMouseUp := ou;
    obj.arr[High(obj.arr)].img.OnMouseMove := ov;
  end;
  (Sender as TImage).Top := ClientHeight - (Sender as TImage).Picture.Bitmap.Height;
  if (Sender as TImage).tag = 0 then (Sender as TImage).Left := 0
  else (Sender as TImage).Left := img.arr[(Sender as TImage).tag - 1].img.Left + img.arr[(Sender as TImage).tag - 1].img.Picture.Bitmap.Width;
  img.down := false;
End;

function TForm1.LoadMap: boolean;
var
  F: File of TMap;
  i: Word;
begin
  AssignFile(F, namemap);
  Reset(F);
  SetLength(map,0);
  SetLength(Obj.arr,0);
  while not Eof(F) do
  Begin
    SetLength(map,Length(map)+1);
    Read(F,map[High(Map)]);
    SetLength(Obj.arr,Length(Obj.arr)+1);
    obj.arr[High(Obj.arr)].img := TImage.Create(Form1);
    obj.arr[High(Obj.arr)].img.Parent := Form1;
    if Length(img.arr) > 0 then
    Begin
      for i := 0 to High(img.arr) do if img.arr[i].name = map[High(map)].name then
      Begin
        Obj.arr[High(Obj.arr)].img.Picture.Bitmap := img.arr[i].img.Picture.Bitmap;
        Obj.arr[High(Obj.arr)].name := Map[High(Map)].name;
        Obj.arr[High(Obj.arr)].rotate := Map[High(Map)].rotate;
        Obj.arr[High(Obj.arr)].img.Left := Map[High(Map)].x;
        Obj.arr[High(Obj.arr)].img.Top := Map[High(Map)].y;
        Obj.arr[High(Obj.arr)].img.Tag := High(Obj.arr);

        Obj.arr[High(Obj.arr)].img.Width := Obj.arr[High(Obj.arr)].img.Picture.Bitmap.Width;
        Obj.arr[High(Obj.arr)].img.Height := Obj.arr[High(Obj.arr)].img.Picture.Bitmap.Height;

        Obj.arr[High(Obj.arr)].img.OnMouseDown := od;
        Obj.arr[High(Obj.arr)].img.OnMouseUp := ou;
        Obj.arr[High(Obj.arr)].img.OnMouseMove := ov;

        break;
      End;
      if Obj.arr[High(Obj.arr)].name = '' then
      Begin
        ShowMessage('DLL '+Map[High(Map)].name+'.dll not found.');
        SetLength(map,Length(map)-1);
        SetLength(Obj.arr,Length(Obj.arr)-1);
      End;
    End;
  End;
  result := true;
End;

function TForm1.SaveMap:boolean;
var
  i: Byte;
  SaveDialog: TSaveDialog;
Begin
  result := false;
  SaveDialog := TSaveDialog.Create(self);
  SaveDialog.Filter := 'File of Map|*.dat';
  if SaveDialog.Execute then
  Begin
    namemap := SaveDialog.FileName;
    Caption := namemap + ' - ' + gamename;
    AssignFile(F, namemap);
    Rewrite(F);

    for i := 0 to High(obj.arr) do
    Begin
      SetLength(Map, Length(Map)+1);
      Map[i].x := obj.arr[i].img.Left;
      Map[i].y := obj.arr[i].img.Top;
      Map[i].name := obj.arr[i].name;
      Map[i].rotate := obj.arr[i].rotate;
      Write(F, Map[i]);
    End;

    CloseFile(F);
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

procedure TForm1.Button1Click(Sender: TObject);
begin
  //AssignFile(F, Edit1.Text);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  F: File of TMap;
  Sv: TMap;
begin
  Reset(F);
  SetLength(map,0);
  while not Eof(F) do
  Begin
    Read(F,Sv);
    SetLength(map,Length(map)+1);
    map[High(map)] := Sv;
  End;
  ShowMessage(IntToStr(Length(map)));
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //ShowWindow(FindWindow('Shell_TrayWnd', nil), sw_show);
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
  i: Word;
  myobj: TObj;

begin
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Color := clBlue;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psDash;

  myobj := TObj.Create;
  manager.LoadALL('..\..\mods', nil, myobj);  // Изначально запускается из Win32\Debug поэтому так пока что...

  if myobj.Count > 0 then for i := 0 to myobj.Count - 1 do
  Begin
    bit := TBitmap.Create;
    try
      bit.Assign(myobj.pic[i]);
      SetLength(img.arr,Length(img.arr)+1);

      img.arr[i].img := TImage.Create(Form1);
      img.arr[i].img.Parent := Form1;
      img.arr[i].img.Anchors := [akLeft,akBottom];
      
      if i = 0 then img.arr[i].img.Left := 0
      else img.arr[i].img.Left := img.arr[i-1].img.Left + img.arr[i-1].img.Picture.Bitmap.Width;
      
      if bit.Height > ClientHeight - line.Top then line.Top := ClientHeight - bit.Height;

      
      img.arr[i].img.Top := ClientHeight - bit.Height;
      img.arr[i].img.Picture.Bitmap := bit;

      img.arr[i].img.tag := i;
      img.arr[i].Name := myobj.Name[i];

      img.arr[i].img.OnMouseDown := md;
      img.arr[i].img.OnMouseUp := mu;
      img.arr[i].img.OnMouseMove := mv;

      bit.Free;
    except

    end;
  End;

end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case ord(Key) of
    VK_F11: if fullscreen then
    Begin
      fullscreen := false;
      Form1.WindowState:=wsNormal;
      Form1.BorderStyle:=bsSizeable;
      Form1.Width:=Screen.Width div 3 * 2;
      Form1.height:=Screen.Height div 3 * 2;
      FormStyle := fsNormal;
      Form1.Left := (Screen.Width - Form1.Width) div 2;
      Form1.Top := (Screen.Height - Form1.Height) div 2;
    End else
    Begin
      fullscreen := true;
      Form1.WindowState:=wsMaximized;
      Form1.BorderStyle:=bsNone;
      Form1.Width:=Screen.Width;
      Form1.height:=Screen.Height;
      FormStyle := fsStayOnTop;
      Form1.Left := 0;
      Form1.Top := 0;
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
begin
  if select.selecting then with Canvas do
  Begin
    Form1.Repaint;
    Rectangle(select.x, select.y, x, y);
  End;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Word;
begin

  for i := 0 to High(obj.arr) do
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
begin
  //ImageList1.SetSize(50,50);
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
      namemap := opendialog.FileName;
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
    SetLength(Map, 0);
    if Length(obj.arr) > 0 then for i := 0 to High(obj.arr) do obj.arr[i].img.Free;
    SetLength(obj.arr, 0);
    namemap := '';
    ApplyName;
    saved := true;
  End;
end;

procedure TForm1.N5Click(Sender: TObject);
begin
  if CheckSaveMap then Application.Terminate;
end;

end.
