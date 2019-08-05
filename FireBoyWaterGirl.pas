unit FireBoyWaterGirl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, Buttons, Math,
  Mask, ExtCtrls, TCP, TFNW, DLLManager, DateUtils, ShellApi, Vcl.ComCtrls, IdGlobal;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormAlignPosition(Sender: TWinControl; Control: TControl;
      var NewLeft, NewTop, NewWidth, NewHeight: Integer; var AlignRect: TRect;
      AlignInfo: TAlignInfo);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnConnectClick(Sender:TObject);
    procedure OnReturnToMMClick(Sender: TObject);
    procedure OnPlayClick(Sender: TObject);
    procedure OnCreateServerClick(Sender: TObject);
    procedure OnModsClick(Sender: TObject);
    procedure OnSettingsClick(Sender: TObject);
    procedure OnExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  IModsFunctions = class
    PlayerKill: PPlayerKill;
    Win: PWin;
    GetActivatedObject: PGetActivatedObject;
  end;

  TCPThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

  GameThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

var
  Form1: TForm1;
  myobj: TObj;
  mapsettings: TMapSettings;
  ModsFunctions: IModsFunctions;
  TCP: TCPClient;
  cl1: TCPThread;
  cl2: GameThread;
  manager: TDLLManager;
  items: array of record
    width, height, left, top, font: Word;
  end;
  maps: TMapsList;
  save: record
    objs: array of Tmap;
    settings: TSettingsMap;
  end;
  //F1: File of TSettingsMap;
  F2: File of Tmap;
  namemap: string;
  img: array of record
    anim: TAnim;
    name: string[32];
  end;
  obj: array of TMapObject;
  player: record
    name: string;
    ptype: Byte;
  end;
  players: array of TPlayer;
  gamewidth, gameheight: Word;
  keysPressed: record
    W,A,S,D,E: boolean;
  end;
  CurrentScene: string;


implementation

{$R *.dfm}

procedure ChangeScene(NewScene: string);
Begin
  CurrentScene := NewScene;
  try
    (Form1.FindComponent(CurrentScene) as TPanel).Visible := false;
  finally
  end;

  try
    (Form1.FindComponent(NewScene) as TPanel).Visible := true;
  finally
  end;
End;

function Inside(i: Word):boolean;
Begin
  result := false;
  if (players[player.ptype].Left <= obj[i].img.Left+obj[i].img.Width)
  and (obj[i].img.Left <= players[player.ptype].Left+players[player.ptype].img.Width)
  and (players[player.ptype].Top <= obj[i].img.Top+obj[i].img.Height)
  and (obj[i].img.Top <= players[player.ptype].Top+players[player.ptype].img.Height) then result := true;
End;
 {
procedure CheckDistance;
var
  i: word;
  stngs: ^TSettings;
  dist: Word;
  plr: TPos; //player center
  bj: TPos; // Obj center
Begin
  for I := 0 to High(obj) do
  Begin
    stngs := myobj.Settings[manager.IndexOf('mods\' + obj[i].name + '.dll')];
    if stngs.onDistance then
    Begin
      dist := Distance(players[player.ptype].Left + players[player.ptype].img.Width div 2, players[player.ptype].Top + players[player.ptype].img.Height div 2, obj[i].img.Left + obj[i].img.Width div 2, obj[i].img.Top + obj[i].img.Height div 2);
      if dist < stngs.Distance then manager.Run('mods\' + obj[i].name + '.dll', 'Distance', dist, i, obj[i].activate, player.ptype, @players[player.ptype]);
    End;
  end;
End;

procedure BelowAbove;
var
  i: word;
  stngs: ^TSettings;
Begin
  for I := 0 to High(obj) do
  Begin
    stngs := myobj.Settings[manager.IndexOf('mods\' + obj[i].name + '.dll')];
    if stngs.onAbove then
    Begin
      players[player.ptype].Top := players[player.ptype].Top + 1;
      if Inside(i) then
        manager.Run('mods\' + obj[i].name + '.dll', 'Above', 0, i, obj[i].activate, player.ptype, @players[player.ptype]);
      players[player.ptype].Top := players[player.ptype].Top - 1;
    end
    else if stngs.onBelow then
    Begin
      players[player.ptype].Top := players[player.ptype].Top - 1;
      if Inside(i) then manager.Run('mods\' + obj[i].name + '.dll', 'Below', 0, i, obj[i].activate, player.ptype, @players[player.ptype]);
      players[player.ptype].Top := players[player.ptype].Top + 1;
    end;
  end;
End;

function Collision:boolean;
var
  i: Word;
  stngs: ^TSettings;
Begin
  result := false;
  for I := 0 to High(obj) do
  Begin
    stngs := myobj.Settings[manager.IndexOf('mods\' + obj[i].name + '.dll')];
    result := Inside(i);

    if result then
    Begin
      if stngs.onInside then
      Begin
        manager.Run('mods\' + obj[i].name + '.dll', 'Inside', 0, i, obj[i].activate, player.ptype, @players[player.ptype]);
        result := false;
      End;
      if keys.E and stngs.onActivate then manager.Run('mods\' + obj[i].name + '.dll', 'Activate', 0, i, obj[i].activate, player.ptype, @players[player.ptype]);

      if stngs.collision then result := true;
      exit;
    End;

  End;
  if (players[player.ptype].Left < 0) or (players[player.ptype].Top < 0) or (Players[player.ptype].Left > Form1.ClientWidth-players[player.ptype].img.Width) or (Players[0].Top > Form1.ClientHeight-players[0].img.Height) then result := true;

End;

procedure MovePlayer;
Begin
  players[player.ptype].Left := players[player.ptype].Left + players[player.ptype].gravity.right;
  if Collision then players[player.ptype].Left :=  players[player.ptype].Left - players[player.ptype].gravity.right;
  players[player.ptype].Left := players[player.ptype].Left - players[player.ptype].gravity.left;
  if Collision then players[player.ptype].Left :=  players[player.ptype].Left + players[player.ptype].gravity.left;
  players[player.ptype].Left := players[player.ptype].Left - ord(keys.A) * 3;
  if Collision then players[player.ptype].Left :=  players[player.ptype].Left + ord(keys.A) * 3;
  players[player.ptype].Left := players[player.ptype].Left + ord(keys.D) * 3;
  if Collision then players[player.ptype].Left :=  players[player.ptype].Left - ord(keys.D) * 3;

  if players[player.ptype].gravity.down < 10 then inc(players[player.ptype].gravity.down);
  players[player.ptype].Top := players[player.ptype].Top + players[player.ptype].gravity.down;
  if Collision then
  Begin
    players[player.ptype].Top := players[player.ptype].Top - players[player.ptype].gravity.down;
    players[player.ptype].gravity.down := 1;
  end;

  if keys.W and (players[player.ptype].Top = players[player.ptype].img.Top) then players[player.ptype].jump := 16;
  players[player.ptype].Top := players[player.ptype].Top - players[player.ptype].jump;
  if Collision then players[player.ptype].Top := players[player.ptype].Top + players[player.ptype].jump;
  if players[player.ptype].jump > 0 then dec(players[player.ptype].jump);

  players[player.ptype].Top := players[player.ptype].Top - players[player.ptype].gravity.up;
  if Collision then players[player.ptype].Top := players[player.ptype].Top + players[player.ptype].gravity.up;

  if (players[player.ptype].img.Left <> players[player.ptype].Left) or (players[player.ptype].img.Top <> players[player.ptype].Top) then TCP.Send('cords|'+IntToStr(players[player.ptype].Left)+'|'+IntToStr(players[player.ptype].Top));

  players[player.ptype].img.Left := players[player.ptype].Left;
  players[player.ptype].img.Top := players[player.ptype].Top;

  BelowAbove;
  CheckDistance;

  //if (players[player.ptype].jump = players[player.ptype].gravity.down) and (players[player.ptype].jump > 0) then ShowMessage(IntToStr(players[player.ptype].img.Top));

End;  }

procedure Main;
var
  Start: TDateTime;
Begin
  //Start:=Now;
  //MovePlayer;
  //Sleep(31 - MilliSecondsBetween(Start, Now));
  Sleep(31);
  Main;
End;

{ GameThread }

procedure GameThread.Execute;
begin
  repeat
    //Start:=Now;
    //MovePlayer;
    //Sleep(31 - MilliSecondsBetween(Start, Now));
    Sleep(20);
  until (Terminated);
end;
{
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
  SetLength(obj,0);
  SetLength(save.objs,0);
  while not Eof(F2) do
  Begin
    SetLength(save.objs,Length(save.objs)+1);
    Read(F2,save.objs[High(save.objs)]);
    SetLength(obj,Length(obj)+1);
    obj[High(obj)].data := save.objs[High(save.objs)].data;
    obj[High(obj)].width := save.objs[High(save.objs)].width;
    obj[High(obj)].height := save.objs[High(save.objs)].height;
    if Length(img) > 0 then
    Begin
      for i := 0 to High(img) do if img[i].name = save.objs[High(save.objs)].name then
      Begin
        obj[High(obj)].img.Assign(img[i].anim.Image);
        obj[High(obj)].name := save.objs[High(save.objs)].name;
        SetLength(items, Length(items)+1);
        obj[High(obj)].img.Tag := High(items);
        obj[High(obj)].img.Width := obj[High(obj)].height;
        items[High(items)].width := obj[High(obj)].width;
        obj[High(obj)].img.Height := obj[High(obj)].height;
        items[High(items)].height := obj[High(obj)].height;
        obj[High(obj)].img.Stretch := true;
        obj[High(obj)].img.Left := save.objs[High(save.objs)].x;
        items[High(items)].left := obj[High(obj)].img.Left;
        obj[High(obj)].img.Top := save.objs[High(save.objs)].y;
        items[High(items)].top := obj[High(obj)].img.Top;
        obj[High(obj)].img.Align := alCustom;
        break;
      End;
      if obj[High(obj)].name = '' then
      Begin
        ShowMessage('DLL '+save.objs[High(save.objs)].name+'.dll not found.');
        SetLength(save.objs,Length(save.objs)-1);
        SetLength(obj,Length(obj)-1);
      End;
    End;
  End;

  players[1].img := TImage.Create(Form1);
  players[1].img.Parent := Form1;
  players[1].img.Picture.LoadFromFile('player2.bmp');
  players[1].img.Width := players[1].img.Picture.Bitmap.Width;
  players[1].img.Height := players[1].img.Picture.Bitmap.Height;
  players[1].img.Left := save.settings.start[0].x;
  players[1].Left := players[1].img.Left;
  players[1].img.Top := save.settings.start[0].y;
  players[1].Top := players[1].img.Top;

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
End;      }

{ TCPThread }

procedure TCPThread.Execute;
var
  s1: TStringList;
  msg: TMessageActions;
  Buffer: TIdBytes;
  f: file;
  FS: TFileStream;
begin
  repeat
    Buffer := TCP.Read;
    BytesToRaw(Buffer, msg, sizeof(msg));
    case msg of
      Ping: ;
      NeedsDownload: Begin
        AssignFile(f,'maps/'+namemap+'.dat');
        Rewrite(f);
        CloseFile(f);
        AssignFile(f,'maps/'+namemap+'.dat.settings');
        Rewrite(f);
        CloseFile(f);
        FS := TFileStream.Create('maps/'+namemap+'.dat', fmOpenWrite);
        FS.Size := -1;
        IdTCPClient.Socket.ReadStream(FS);
        FS.Free;
        FS := TFileStream.Create('maps/'+namemap+'.dat.settings', fmOpenWrite);
        IdTCPClient.Socket.ReadStream(FS);
        FS.Free;
      end;
      PlayerMove: ;
      ObjectMove: ;
      PlayerConnected: ;
      PlayerDisconnected: ;
      ChangePlayerType: ;
      TextMessage: ;
      ChangeMap: ;
      ChangeNick: ;
      PlayerReady: ;
      GameStart: ;
      GameEnd: ;
    end;
    {if CurrentScene = 'Game' then
    Begin
      //if msg.Action = PlayerMove then
      s1 := TStringList.Create;
      s1.Delimiter := '|';
      s1.StrictDelimiter := true;
      s1.DelimitedText := s;
      if s1[0] = 'cords' then
      Begin
        players[1-player.ptype].img.Left := StrToInt(s1[1]);
        players[1-player.ptype].img.Top := StrToInt(s1[2]);
      End;
    End else if CurrentScene = 'Lobby' then
    Begin
      if s = 'start' then
      Begin
        player.ptype := (TForm1.FindComponent('LPlayerType') as TRadioGroup).ItemIndex;
        ChangeScene('Game');
        Form1.BorderStyle := bsNone;
        Form1.Left := 0;
        Form1.Top := 0;
        SetLength(players, 2);
        LoadMap;
        players[player.ptype].gravity.down := 1;
        cl2 := GameThread.Create(false);
      End
      else if s = 'FireChosen' then
        Lobby.FireBoyChoice.Enabled := false
      else if s = 'WaterChosen' then
        Lobby.WaterGirlChoice.Enabled := false
      else if s = 'NotChosen' then
      begin
        Lobby.FireBoyChoice.Enabled := true;
        Lobby.WaterGirlChoice.Enabled := true;
      end;
      s1 := TStringList.Create;
      s1.Delimiter := '|';
      s1.StrictDelimiter := true;
      s1.DelimitedText := s;
      if s1[0] = 'info' then Lobby.MapLabel.Caption := 'Map: '+s1[1]
      else if s1[0] = 'new' then Lobby.PlayersList.Items.Add(s1[1])
      else if s1[0] = 'exit' then Lobby.PlayersList.Items.Delete(Lobby.PlayersList.Items.IndexOf(s1[2]));
    End;                }
  until (Terminated);
end;

{
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
        cl1 := TCPThread.Create(false);
      End;
    end;
  end;
end;   }

procedure TForm1.FormAlignPosition(Sender: TWinControl; Control: TControl;
  var NewLeft, NewTop, NewWidth, NewHeight: Integer; var AlignRect: TRect;
  AlignInfo: TAlignInfo);
begin
  if((items[Control.Tag].width = 0) or (items[Control.Tag].height = 0)) then exit;
  NewLeft := Round(items[Control.Tag].left * (ClientWidth/gamewidth));
  NewTop := Round(items[Control.Tag].top * (ClientHeight/gameheight));
  NewWidth := Round(items[Control.Tag].width * (ClientWidth/gamewidth));
  NewHeight := Round(items[Control.Tag].height * (ClientHeight/gameheight));

  if Control.ClassName = 'TBitBtn' then (Control as TBitBtn).Font.Height := Min((Control as TBitBtn).Height, (Control as TBitBtn).Width);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if cl1 <> nil then
  Begin
    cl1.DoTerminate;
    //cl1.Free;
  End;
  if cl2 <> nil then
  Begin
    cl2.DoTerminate;
    //cl2.Free;
  End;
  TCP.Disconnect;
  Sleep(35);
  CanClose := true;
end;

{ IModsFunctions }

function GetMapSettings:PMapSettings;
Begin
  //
End;

function GetActivatedObject(id: Byte): PMapObject;
begin
  result := @obj[id];
end;

procedure PlayerKill(playertype: Byte);
begin
  {players[playertype].img.Left := save.settings.start[0].x;
  players[playertype].Left := save.settings.start[0].x;

  players[playertype].img.Top := save.settings.start[0].y;
  players[playertype].Top := save.settings.start[0].y; }
end;

procedure Win;
begin
  //
end;

procedure ChangeSpawn(coords: Tpoint; playertype: SmallInt=-1);
Begin
  //
End;

procedure AddAnim(TType: TTAnimType; AType: TAnimType; Id, ms: Word; var start, stop);
Begin
  //
End;

procedure AddMove(AType: TMoveType; id: Word; coords: Tpoint);
Begin
  //
End;

function AddMovePlayer(id: Byte; coords: TPoint): boolean;
Begin
  //
End;

procedure TForm1.FormCreate(Sender: TObject);
var
  i: byte;
  sr: TSearchRec;
  Stngs: ^TSettings;
  bit: TBitmap;
begin
  RegisterClass(TLabel);
  RegisterClass(TListBox);
  RegisterClass(TCheckBox);
  RegisterClass(TRadioGroup);
  RegisterClass(TBitBtn);
  RegisterClass(TEdit);
  RegisterClass(TPanel);
  RegisterClass(TListView);
  RegisterClass(TMemo);

  CurrentScene := 'MainMenu';

  LoadDFMtoComponent('forms/MainMenu.dfm', Form1);
  LoadDFMtoComponent('forms/SearchServer.dfm', Form1);
  LoadDFMtoComponent('forms/Lobby.dfm', Form1);
  LoadDFMtoComponent('forms/Mods.dfm', Form1);

  (FindComponent('MMPlay') as TBitBtn).OnClick := OnPlayClick;
  (FindComponent('MMCreateServer') as TBitBtn).OnClick := OnCreateServerClick;
  (FindComponent('MMMods') as TBitBtn).OnClick := OnModsClick;
  (FindComponent('MMSettings') as TBitBtn).OnClick := OnSettingsClick;
  (FindComponent('MMExit') as TBitBtn).OnClick := OnExitClick;
  (FindComponent('MReturn') as TBitBtn).OnClick := OnReturnToMMClick;
  (FindComponent('SSReturn') as TBitBtn).OnClick := OnReturnToMMClick;
  (FindComponent('SSConnect') as TBitBtn).OnClick := OnConnectClick;

  ModsFunctions := IModsFunctions.Create;
  ModsFunctions.PlayerKill := @PlayerKill;
  ModsFunctions.Win := @Win;
  ModsFunctions.GetActivatedObject := @GetActivatedObject;

  gamewidth := 1280;
  gameheight := 720;
  myobj := TObj.Create;
  manager.LoadALL('mods', nil, myobj, @GetActivatedObject, @PlayerKill, @Win, @MapSettings);

  if myobj.Count > 0 then for i := 0 to myobj.Count - 1 do
  Begin
    (FindComponent('MModsList') as TListBox).Items.Add(myobj.Name[i]);
    try
      SetLength(img,Length(img)+1);

      stngs := myobj.Settings[i];

      img[i].anim := TAnim.Create(Form1, myobj.GIF[i], stngs.Transparent);
      img[i].Name := myobj.Name[i];
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

  TCP := TCPClient.create{(OnMsg)};
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    ord('W'): keysPressed.W := true;
    ord('A'): keysPressed.A := true;
    ord('S'): keysPressed.S := true;
    ord('D'): keysPressed.D := true;
    ord('E'): keysPressed.E := true;
  end;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    ord('W'): keysPressed.W := false;
    ord('A'): keysPressed.A := false;
    ord('S'): keysPressed.S := false;
    ord('D'): keysPressed.D := false;
    ord('E'): keysPressed.E := false;
  end;
end;

procedure TForm1.OnCreateServerClick(Sender: TObject);
begin
  ShellExecute(Form1.Handle, 'open', 'ServerProj.exe', nil, nil, SW_SHOWNORMAL);
end;

procedure TForm1.OnConnectClick(Sender:TObject);
var
  s: TStringList;
  ping: TPing;
Begin
  s := TStringList.Create;
  s.StrictDelimiter := true;
  s.Delimiter := ':';
  s.DelimitedText := (FindComponent('SSAddress') as TEdit).Text;
  ping := TCP.Connect(s[0], StrToInt(s[1]), maps);

  namemap := ping.map;
  //inlobby := true;
  ChangeScene('Lobby');
  cl1 := TCPThread.Create(false);
End;

procedure TForm1.OnReturnToMMClick(Sender: TObject);
Begin
  ChangeScene('MainMenu');
End;

procedure TForm1.OnExitClick(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.OnModsClick(Sender: TObject);
begin
  ChangeScene('Mods');
end;

procedure TForm1.OnPlayClick(Sender: TObject);
begin
  ChangeScene('SearchServer');
end;

procedure TForm1.OnSettingsClick(Sender: TObject);
begin
  //
end;

{ ILobby }

{procedure ILobby.OnClick(Sender: TObject);
begin
  // CheckBox
  if Sender.ClassName = 'TCheckBox' then
    if (Sender as TCheckBox).Checked then TCP.Send('Ready') else
      if Not (Sender as TCheckBox).Checked then TCP.Send('NotReady');

  // RadioButton
  if Sender.ClassName = 'TRadioButton' then
    if FireBoyChoice.Checked then
    begin
      ReadyCheckbox.Enabled := true;
      TCP.Send('FireChosen');
    end else
      if WaterGirlChoice.Checked then
      begin
        ReadyCheckbox.Enabled := true;
        TCP.Send('WaterChosen');
      end else
        if Exchange.Checked then
        begin
          ReadyCheckbox.Enabled := false;
          ReadyCheckbox.Checked := false;
          TCP.Send('NotChosen');
        end;
end;   }

end.
