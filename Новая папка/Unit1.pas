unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, Buttons, Math,
  Mask, ExtCtrls, TCP, TFNW, DLLManager, DateUtils, ShellApi;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormAlignPosition(Sender: TWinControl; Control: TControl;
      var NewLeft, NewTop, NewWidth, NewHeight: Integer; var AlignRect: TRect;
      AlignInfo: TAlignInfo);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  IMainMenu = class
    Btn1: TBitBtn;
    Btn2: TBitBtn;
    Btn3: TBitBtn;
    Btn4: TBitBtn;
    Btn5: TBitBtn;
    procedure Show;
    procedure Hide;
    procedure OnClick(Sender: TObject);
  end;

  IMods = class
    list: TListBox;
    return: TButton;
    procedure Show;
    procedure Hide;
    procedure OnClick(Sender: TObject);
  end;

  IServerSearch = class
    //list: TListBox;
    ServerIP: TEdit;
    ServerInfo: TListBox;
    ReturnBtn: TBitBtn;
    GetInfoBtn: TBitBtn;
    ConnectBtn: TBitBtn;
    procedure Show;
    procedure Hide;
    procedure OnClick(Sender: TObject);
  end;

  ILobby = class
    MapLabel: TLabel;
    PlayersList: TListBox;
    ReadyCheckbox: TCheckBox;
    //FireBoyCheckBox: TCheckBox;
    //WaterGirlCheckBox: TCheckBox;
    procedure Show;
    procedure Hide;
    procedure OnClick(Sender: TObject);
  end;

var
  Form1: TForm1;
  myobj: TObj;
  MainMenu: IMainMenu;
  Mods: IMods;
  Lobby: ILobby;
  TCP: TCPClient;
  SearchServer: IServerSearch;
  manager: TDLLManager;
  inlobby: Boolean;
  items: array of record
    width, height, left, top, font: Word;
  end;
  maps: TMapsList;
  save: record
    objs: array of Tmap;
    settings: TSettingsMap;
  end;
  F1: File of TSettingsMap;
  F2: File of Tmap;
  namemap: string;
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
    arr: array of record
      img: TImage;
      width, height: Word;
      selected: boolean;
      name: string[32];
      {scale: record
        Width,Height: Single;
      end; }
    end;
  end;
  players: array of record
    Left, Top: Word;
    img: TImage;
    jump: Byte;
    gravity: record
      left, right, down, up: Byte;
    end;
    anim: TAnim;
  end;
  gamewidth, gameheight: Word;
  keys: record
    W,A,S,D:boolean;
  end;


implementation

{$R *.dfm}

function Collision:boolean;
var
  i: Word;
  stngs: ^TSettings;
Begin
  result := false;
  for I := 0 to High(obj.arr) do
  Begin
    stngs := myobj.Settings[manager.IndexOf('mods\' + obj.arr[i].name + '.dll')];
    if (stngs.collision)
    and (players[0].Left <= obj.arr[i].img.Left+obj.arr[i].img.Width)
    and (obj.arr[i].img.Left <= players[0].Left+players[0].img.Width)
    and (players[0].Top <= obj.arr[i].img.Top+obj.arr[i].img.Height)
    and (obj.arr[i].img.Top <= players[0].Top+players[0].img.Height) then result := true;
  End;
  if (players[0].Left < 0) or (players[0].Top < 0) or (Players[0].Left > Form1.ClientWidth-players[0].img.Width) or (Players[0].Top > Form1.ClientHeight-players[0].img.Height) then result := true;
  
End;

procedure MovePlayer;
Begin
  players[0].Left := players[0].Left + players[0].gravity.right;
  if Collision then players[0].Left :=  players[0].Left - players[0].gravity.right;
  players[0].Left := players[0].Left - players[0].gravity.left;
  if Collision then players[0].Left :=  players[0].Left + players[0].gravity.left;
  players[0].Left := players[0].Left - ord(keys.A) * 3;
  if Collision then players[0].Left :=  players[0].Left + ord(keys.A) * 3;
  players[0].Left := players[0].Left + ord(keys.D) * 3;
  if Collision then players[0].Left :=  players[0].Left - ord(keys.D) * 3;

  if players[0].gravity.down < 10 then inc(players[0].gravity.down);
  players[0].Top := players[0].Top + players[0].gravity.down;
  if Collision then
  Begin
    players[0].Top := players[0].Top - players[0].gravity.down;
    players[0].gravity.down := 1;
  end;

  if keys.W and (players[0].Top = players[0].img.Top) then players[0].jump := 13;
  players[0].Top := players[0].Top - players[0].jump;
  if Collision then players[0].Top := players[0].Top + players[0].jump;
  if players[0].jump > 0 then dec(players[0].jump);

  players[0].Top := players[0].Top - players[0].gravity.up;
  if Collision then players[0].Top := players[0].Top + players[0].gravity.up;

  players[0].img.Left := players[0].Left;
  players[0].img.Top := players[0].Top;

  if (players[0].jump = players[0].gravity.down) and (players[0].jump > 0) then ShowMessage(IntToStr(players[0].img.Top));

End;

procedure Main;
var
  Start: TDateTime;
Begin
  Start:=Now;
  MovePlayer;
  Sleep(31 - MilliSecondsBetween(Start, Now));
  Main;
End;

function LoadMap: boolean;
var
  i: Word;
begin
  AssignFile(F1, 'maps/'+namemap+'.dat.settings');
  Reset(F1);
  Read(F1,save.settings);
  CloseFile(F1);
  Form1.ClientWidth := save.settings.width;
  Form1.ClientHeight := save.settings.height;

  gamewidth := save.settings.width;
  gameheight := save.settings.height;

  AssignFile(F2, 'maps/'+namemap+'.dat');
  Reset(F2);
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
        SetLength(items, Length(items)+1);
        Obj.arr[High(Obj.arr)].img.Tag := High(items);
        Obj.arr[High(Obj.arr)].img.Width := obj.arr[High(Obj.arr)].height;
        items[High(items)].width := obj.arr[High(Obj.arr)].width;
        Obj.arr[High(Obj.arr)].img.Height := obj.arr[High(Obj.arr)].height;
        items[High(items)].height := obj.arr[High(Obj.arr)].height;
        obj.arr[High(obj.arr)].img.Stretch := true;
        obj.arr[High(obj.arr)].img.Picture.Bitmap.TransparentMode := tmFixed;
        obj.arr[High(obj.arr)].img.Picture.Bitmap.TransparentColor := img.arr[i].img.Picture.Bitmap.TransparentColor;
        obj.arr[High(obj.arr)].img.Transparent := true;
        Obj.arr[High(Obj.arr)].img.Left := save.objs[High(save.objs)].x;
        items[High(items)].left := Obj.arr[High(Obj.arr)].img.Left;
        Obj.arr[High(Obj.arr)].img.Top := save.objs[High(save.objs)].y;
        items[High(items)].top := Obj.arr[High(Obj.arr)].img.Top;     
        obj.arr[High(obj.arr)].img.Align := alCustom;
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

  players[0].img := TImage.Create(Form1);
  players[0].img.Parent := Form1;
  players[0].img.Picture.LoadFromFile('player.bmp');
  players[0].img.Width := players[0].img.Picture.Bitmap.Width;
  players[0].img.Height := players[0].img.Picture.Bitmap.Height;
  players[0].img.Left := save.settings.start[0].x;
  players[0].Left := players[0].img.Left;
  players[0].img.Top := save.settings.start[0].y;
  players[0].Top := players[0].img.Top;

  CloseFile(F2);
  result := true;
End;

procedure IMainMenu.Hide;
Begin
  Btn1.Visible := false;
  Btn2.Visible := false;
  Btn3.Visible := false;
  Btn4.Visible := false;
  Btn5.Visible := false;
End;

procedure IMainMenu.Show;
Begin
  Btn1.Visible := true;
  Btn2.Visible := true;
  Btn3.Visible := true;
  Btn4.Visible := true;
  Btn5.Visible := true;
End;

procedure IMods.Hide;
begin
  list.visible := false;
  return.Visible := false;
end;

procedure IMods.OnClick(Sender: TObject);
begin
  Hide;
  MainMenu.Show;
end;

procedure IMods.Show;
begin
  list.visible := true;
  return.Visible := true;
end;

procedure IMainMenu.OnClick(Sender: TObject);
begin
  case (Sender as TBitBtn).Tag of
    1: Begin
       Hide;
       SearchServer.Show;
    End;
    2: ShellExecute(Form1.Handle, 'open', 'ServerProj.exe', nil, nil, SW_SHOWNORMAL);
    3: Begin
      Hide;
      Mods.Show;
    End;
    4: Sleep(1);
    5: Form1.Close;
  end;
end;

procedure onMsg(s: string);
var
  s1: TStringList;
Begin
  case inlobby of
    false: Begin

    End;
    true: Begin
      if s = 'start' then
      Begin
        Lobby.Hide;
        Form1.BorderStyle := bsNone;
        Form1.Left := 0;
        Form1.Top := 0;
        inlobby := false;      
        SetLength(players, 1);
        LoadMap;
        players[0].gravity.down := 1;
        Main;
        exit;
      End;
      s1 := TStringList.Create;
      s1.Delimiter := '|';
      s1.StrictDelimiter := true;
      s1.DelimitedText := s;
      if s1[0] = 'info' then Lobby.MapLabel.Caption := 'Map: '+s1[1]
      else if s1[0] = 'new' then Lobby.PlayersList.Items.Add(s1[1])
      else if s1[0] = 'exit' then Lobby.PlayersList.Items.Delete(Lobby.PlayersList.Items.IndexOf(s1[2]));

    End;
  end;
End;

procedure IServerSearch.Hide;
begin
  ServerIP.Visible := false;
  ServerInfo.Visible := false;
  ReturnBtn.Visible := false;
  GetInfoBtn.Visible := false;
  ConnectBtn.Visible := false;
end;

procedure IServerSearch.OnClick(Sender: TObject);
var
  ping: TPing;
  s: TStringList;
begin
  case (Sender as TBitBtn).Tag of
    8: Begin
      Hide;
      MainMenu.Show;
    end;
    9: Begin
      s := TStringList.Create;
      s.StrictDelimiter := true;
      s.Delimiter := ':';
      s.DelimitedText := SearchServer.ServerIP.Text;
      ping := TCP.Ping(s[0], StrToInt(s[1]));
      SearchServer.ServerInfo.Items.Add(ping.name + ' | ' + ping.map + ' | ' + IntToStr(ping.players) + ' | ' + IntToStr(ping.maxplayers));
    end;
    10: Begin
      s := TStringList.Create;
      s.StrictDelimiter := true;
      s.Delimiter := ':';
      s.DelimitedText := SearchServer.ServerIP.Text;
      ping := TCP.Connect(s[0], StrToInt(s[1]), maps);
      if ping.work then
      Begin
        namemap := ping.map;
        inlobby := true;
        SearchServer.Hide;
        Lobby.Show;
      End;
    end;
  end;
end;

procedure IServerSearch.Show;
begin
  ServerIP.Visible := true;
  ServerInfo.Visible := true;
  ReturnBtn.Visible := true;
  GetInfoBtn.Visible := true;
  ConnectBtn.Visible := true;
end;

procedure TForm1.FormAlignPosition(Sender: TWinControl; Control: TControl;
  var NewLeft, NewTop, NewWidth, NewHeight: Integer; var AlignRect: TRect;
  AlignInfo: TAlignInfo);
begin
  if((items[Control.Tag].width = 0) or (items[Control.Tag].height = 0)) then exit;
  NewLeft := Round(items[Control.Tag].left * (ClientWidth/gamewidth));
  NewTop := Round(items[Control.Tag].top * (ClientHeight/gameheight));
  NewWidth := Round(items[Control.Tag].width * (ClientWidth/gamewidth));
  NewHeight := Round(items[Control.Tag].height * (ClientHeight/gameheight));

  if Control.ClassName = 'TBitBtn' then (Control as TBitBtn).Font.Size := Round(items[Control.Tag].font * Min((ClientWidth/1280), (ClientHeight/720)));
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i: byte;
  sr: TSearchRec;
  Stngs: ^TSettings;
  bit: TBitmap;
begin
  gamewidth := 1280;
  gameheight := 720;
  myobj := TObj.Create;
  manager.LoadALL('mods', nil, myobj);

  mods := IMods.Create;

  with Mods do
  Begin
    list := TListBox.Create(Form1);
    list.Parent := Form1;
    list.Visible := false;
    list.Left := 500;
    list.Top := 200;
    list.Width := 300;
    list.Height := 400;

    return := TButton.Create(Form1);
    return.Parent := Form1;
    return.Visible := false;
    return.Left := list.Left + list.Width div 2 - return.Width div 2;
    return.Top := list.Top + list.Height + 6;
    return.Caption := '¬ÂÌÛÚ¸Òˇ';
    return.OnClick := OnClick;
  End;

  if myobj.Count > 0 then for i := 0 to myobj.Count - 1 do
  Begin
    Mods.list.Items.Add(myobj.Name[i]);
    bit := TBitmap.Create;
    try
      bit.Assign(myobj.pic[i]);
      SetLength(img.arr,Length(img.arr)+1); 

      img.arr[i].img := TImage.Create(Form1);
      //img.arr[i].img.Parent := Form1;
      img.arr[i].img.tag := i;
      //img.arr[i].img.Anchors := [akLeft,akBottom];
      {
      if i = 0 then img.arr[i].img.Left := 0
      else img.arr[i].img.Left := img.arr[i-1].img.Left + img.arr[i-1].img.Picture.Bitmap.Width;
      }
      //if bit.Height > ClientHeight - line.Top then line.Top := ClientHeight - bit.Height;

      //img.arr[i].img.Top := ClientHeight - bit.Height;
      img.arr[i].img.Picture.Bitmap := bit;

      img.arr[i].Name := myobj.Name[i];

      img.arr[i].img.Picture.Bitmap.TransparentMode := tmFixed;
      Stngs := myobj.Settings[i];
      img.arr[i].img.Picture.Bitmap.TransparentColor := Stngs.Transparent;
      img.arr[i].img.Transparent := true;
      {
      if Stngs.animation then
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
      }

      bit.Free;
    except

    end;
  End;

  if FindFirst('maps/*.dat',faAnyFile,sr) = 0 then
  repeat
    SetLength(maps, Length(maps)+1);
    maps[High(maps)].hash := MD5('maps/'+sr.Name);
    maps[High(maps)].name := Copy(sr.Name, 0, Length(sr.Name)-4);
  until FindNext(sr) <> 0;
  FindClose(sr);

  MainMenu := IMainMenu.Create;

  SetLength(items, 14);

  With MainMenu do
  Begin
    Btn1 := TBitBtn.Create(Form1);
    Btn1.Parent := Form1;
    Btn1.Tag := 1;
    Btn1.Caption := '»√–¿“‹';
    items[Btn1.Tag].left :=390;
    items[Btn1.Tag].top := 280;
    items[Btn1.Tag].width := 500;
    items[Btn1.Tag].height := 60;
    Btn1.Align := alCustom;
    Btn1.Anchors := [akLeft,akTop,akRight,akBottom];
    items[Btn1.Tag].font := 24;
    Btn1.OnClick := OnClick;

    Btn2 := TBitBtn.Create(Form1);
    Btn2.Parent := Form1;
    Btn2.Tag := 2;
    Btn2.Caption := '—Œ«ƒ¿“‹ —≈–¬≈–';
    items[Btn2.Tag].left := 390;
    items[Btn2.Tag].top := 400;
    items[Btn2.Tag].width := 500;
    items[Btn2.Tag].height := 60;
    Btn2.Align := alCustom;
    Btn2.Anchors := [akLeft,akTop,akRight,akBottom];
    items[Btn2.Tag].font := 24;
    Btn2.OnClick := OnClick;

    Btn3 := TBitBtn.Create(Form1);
    Btn3.Parent := Form1;
    Btn3.Tag := 3;
    Btn3.Caption := 'ÃŒƒ€';
    items[Btn3.Tag].left := 390;
    items[Btn3.Tag].top := 466;
    items[Btn3.Tag].width := 500;
    items[Btn3.Tag].height := 60;
    Btn3.Align := alCustom;
    Btn3.Anchors := [akLeft,akTop,akRight,akBottom];
    items[Btn3.Tag].font := 24;
    Btn3.OnClick := OnClick;

    Btn4 := TBitBtn.Create(Form1);
    Btn4.Parent := Form1;
    Btn4.Tag := 4;
    Btn4.Caption := 'Õ¿—“–Œ… »';
    items[Btn4.Tag].left := 390;
    items[Btn4.Tag].top := 532;
    items[Btn4.Tag].width := 500;
    items[Btn4.Tag].height := 60;
    Btn4.Align := alCustom;
    Btn4.Anchors := [akLeft,akTop,akRight,akBottom];
    items[Btn4.Tag].font := 24;
    Btn4.OnClick := OnClick;

    Btn5 := TBitBtn.Create(Form1);
    Btn5.Parent := Form1;
    Btn5.Tag := 5;
    Btn5.Caption := '¬€’Œƒ';
    items[Btn5.Tag].left := 390;
    items[Btn5.Tag].top := 598;
    items[Btn5.Tag].width := 500;
    items[Btn5.Tag].height := 60;
    Btn5.Align := alCustom;
    Btn5.Anchors := [akLeft,akTop,akRight,akBottom];
    items[Btn5.Tag].font := 24;
    Btn5.OnClick := OnClick;
  End;

  SearchServer := IServerSearch.Create;

  with SearchServer do
  Begin
    ServerIP := TEdit.Create(Form1);
    ServerIP.Parent := Form1;
    ServerIP.Tag := 6;
    ServerIP.Left := 490;
    items[ServerIP.Tag].left := ServerIP.Left;
    ServerIP.Top := 280;
    items[ServerIP.Tag].top := ServerIP.Top;
    ServerIP.Width := 300;
    items[ServerIP.Tag].width := ServerIP.Width;
    items[ServerIP.Tag].height := ServerIP.Height;
    ServerIP.Align := alCustom;
    ServerIP.Anchors := [akLeft,akTop,akRight,akBottom];
    ServerIP.Visible := false;

    ServerInfo := TListBox.Create(Form1);
    ServerInfo.Parent := Form1;
    ServerInfo.Tag := 7;
    ServerInfo.Left := 490;
    items[ServerInfo.Tag].left := ServerInfo.Left;
    ServerInfo.Top := 307;
    items[ServerInfo.Tag].top := ServerInfo.Top;
    ServerInfo.Width := 300;
    items[ServerInfo.Tag].width := ServerInfo.Width;
    ServerInfo.Height := 200;
    items[ServerInfo.Tag].height := ServerInfo.Height;
    ServerInfo.Align := alCustom;
    ServerInfo.Anchors := [akLeft,akTop,akRight,akBottom];
    ServerInfo.Visible := false;

    ReturnBtn := TBitBtn.Create(Form1);
    ReturnBtn.Parent := Form1;
    ReturnBtn.Tag := 8;
    ReturnBtn.Left := 490;
    items[ReturnBtn.Tag].left := ReturnBtn.Left;
    ReturnBtn.Top := 513;
    items[ReturnBtn.Tag].top := ReturnBtn.Top;
    ReturnBtn.Width := 70;
    items[ReturnBtn.Tag].width := ReturnBtn.Width;
    items[ReturnBtn.Tag].height := ReturnBtn.Height;
    ReturnBtn.Align := alCustom;
    ReturnBtn.Anchors := [akLeft,akTop,akRight,akBottom];
    ReturnBtn.Font.Size := 6;
    items[ReturnBtn.Tag].font := ReturnBtn.Font.Size;
    ReturnBtn.Caption := '¬≈–Õ”“‹—ﬂ';
    ReturnBtn.OnClick := OnClick;
    ReturnBtn.Visible := false;

    GetInfoBtn := TBitBtn.Create(Form1);
    GetInfoBtn.Parent := Form1;
    GetInfoBtn.Tag := 9;
    GetInfoBtn.Left := 605;
    items[GetInfoBtn.Tag].left := GetInfoBtn.Left;
    GetInfoBtn.Top := 513;
    items[GetInfoBtn.Tag].top := GetInfoBtn.Top;
    GetInfoBtn.Width := 70;
    items[GetInfoBtn.Tag].width := GetInfoBtn.Width;
    items[GetInfoBtn.Tag].height := GetInfoBtn.Height;
    GetInfoBtn.Align := alCustom;
    GetInfoBtn.Anchors := [akLeft,akTop,akRight,akBottom];
    GetInfoBtn.Font.Size := 6;
    items[GetInfoBtn.Tag].font := GetInfoBtn.Font.Size;
    GetInfoBtn.Caption := '»Õ‘Œ–Ã¿÷»ﬂ';
    GetInfoBtn.OnClick := OnClick;
    GetInfoBtn.Visible := false;

    ConnectBtn := TBitBtn.Create(Form1);
    ConnectBtn.Parent := Form1;
    ConnectBtn.Tag := 10;
    ConnectBtn.Left := 720;
    items[ConnectBtn.Tag].left := ConnectBtn.Left;
    ConnectBtn.Top := 513;
    items[ConnectBtn.Tag].top := ConnectBtn.Top;
    ConnectBtn.Width := 70;
    items[ConnectBtn.Tag].width := ConnectBtn.Width;
    items[ConnectBtn.Tag].height := ConnectBtn.Height;
    ConnectBtn.Align := alCustom;
    ConnectBtn.Anchors := [akLeft,akTop,akRight,akBottom];
    ConnectBtn.Font.Size := 6;
    items[ConnectBtn.Tag].font := ConnectBtn.Font.Size;
    ConnectBtn.Caption := 'œŒƒ Àﬁ◊»“‹—ﬂ';
    ConnectBtn.OnClick := OnClick;
    ConnectBtn.Visible := false;
  End;

  Lobby := ILobby.Create;

  with Lobby do
  Begin
    MapLabel := TLabel.Create(Form1);
    MapLabel.Parent := Form1;
    MapLabel.Tag := 11;
    items[MapLabel.Tag].left := 490;   
    items[MapLabel.Tag].top := 280;
    items[MapLabel.Tag].width := 300;
    items[MapLabel.Tag].height := 18;
    MapLabel.Align := alCustom;
    MapLabel.Anchors := [akLeft,akTop,akRight,akBottom];
    MapLabel.Font.Size := 14;
    MapLabel.Caption := '';
    MapLabel.OnClick := OnClick;
    MapLabel.Visible := false;

    PlayersList := TListBox.Create(Form1);
    PlayersList.Parent := Form1;
    PlayersList.Tag := 12;
    items[PlayersList.Tag].left := 490;
    items[PlayersList.Tag].top := 300;
    items[PlayersList.Tag].width := 500;
    items[PlayersList.Tag].height := 300;
    PlayersList.Align := alCustom;
    PlayersList.Anchors := [akLeft,akTop,akRight,akBottom];
    PlayersList.Font.Size := 12;
    PlayersList.Visible := false;

    ReadyCheckbox := TCheckBox.Create(Form1);
    ReadyCheckbox.Parent := Form1;
    ReadyCheckbox.Tag := 13;
    items[ReadyCheckbox.Tag].left := 490;
    items[ReadyCheckbox.Tag].top := 606;
    items[ReadyCheckbox.Tag].width := ReadyCheckbox.Width;
    items[ReadyCheckbox.Tag].height := ReadyCheckbox.Height;
    ReadyCheckbox.Caption := '√ÓÚÓ‚';
    ReadyCheckbox.Align := alCustom;
    ReadyCheckbox.Anchors := [akLeft,akTop,akRight,akBottom];
    ReadyCheckbox.Font.Size := 12;
    ReadyCheckbox.Visible := false; 
    ReadyCheckbox.OnClick := OnClick;
  End;

  TCP := TCPClient.create(onMsg);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    ord('W'): keys.W := true;
    ord('A'): keys.A := true;
    ord('S'): keys.S := true;
    ord('D'): keys.D := true;
  end;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    ord('W'): keys.W := false;
    ord('A'): keys.A := false;
    ord('S'): keys.S := false;
    ord('D'): keys.D := false;
  end;
end;

{ ILobby }

procedure ILobby.Hide;
begin
  MapLabel.Visible := false;
  PlayersList.Visible := false;
  ReadyCheckbox.Visible := false;
end;

procedure ILobby.OnClick(Sender: TObject);
begin
  if (Sender.ClassName = 'TCheckBox') and (Sender as TCheckBox).Checked then TCP.Send('Ready');
  if (Sender.ClassName = 'TCheckBox') and Not (Sender as TCheckBox).Checked then TCP.Send('NotReady');
  //if (Sender.ClassName = 'TCheckBox') and (Sender as TCheckBox).Checked then TCP.Send('Ready');
end;

procedure ILobby.Show;
begin
  MapLabel.Visible := true;
  PlayersList.Visible := true;
  ReadyCheckbox.Visible := true;
end;

end.
