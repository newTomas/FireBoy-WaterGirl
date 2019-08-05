unit DLLManager;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Dialogs, Jpeg, StdCtrls, GIFImg,
  TFNW;

type
  modinfo = record
    path, name: string;
  end;
  loadresult = (error, obj, player);
  TDLLManager = class
    function IndexOf(name: string):Word;
    function Load(modification: modinfo; ListBox: TListBox; GetActivatedObject: PGetActivatedObject; PlayerKill: PPlayerKill; Win: PWin; MapSettings: PMapSettings): loadresult;
    //function LoadJPEG(Handle: THandle):TJPEGImage;
    function LoadGIF(Handle: THandle):TGIFImage;
    function LoadGIFPlayer(Handle: THandle):TPlayerAnimations;
    function LoadALL(name: string; ListBox: TListBox; myobj: TObj; playerslist: TPlayers; GetActivatedObject: PGetActivatedObject; PlayerKill: PPlayerKill; Win: PWin; MapSettings: PMapSettings): boolean;
    function UnLoad(name: string; ListBox: TListBox=nil): boolean;
    procedure UnLoadAll(ListBox: TListBox=nil);
    function GetHandle(Index: Word):THandle;
    function Run(name: string; on: string; Dist: Word; ObjectId,ActivatedId,PlayerType: Byte; Player: PPlayer): boolean;
  private

  public

  end;

var
  Libs: array of record
    Name, path: string;
    Handle: THandle;
    functions: record
      Init: function(GetActivatedObject, PlayerKill, Win, MapSettings: Pointer): Pointer;
      onAbove: procedure(ObjectId,ActivatedId,PlayerType: Byte; Player: PPlayer);
      onBelow: procedure(ObjectId,ActivatedId,PlayerType: Byte; Player: PPlayer);
      onDistance: procedure(Dist: Word; ObjectId,ActivatedId,PlayerType: Byte; Player: PPlayer);
      onInside: procedure(ObjectId,ActivatedId,PlayerType: Byte; Player: PPlayer);
      onActivate: procedure(ObjectId,ActivatedId,PlayerType: Byte; Player: PPlayer);
    end;
    Settings: PSettings;
  end;
  Players: array of record
    name, path: string;
    Handle: THandle;
    Settings: PSettings;
  end;
  i: Word;

implementation

function TDLLManager.IndexOf(name: string):Word;
var
  i: Word;
Begin
  for i := 0 to High(Libs) do if Libs[i].name = name then
  begin
    result := i;
    Exit;
  end;
End;

function TDLLManager.Load(modification: modinfo; ListBox: TListBox; GetActivatedObject: PGetActivatedObject; PlayerKill: PPlayerKill; Win: PWin; MapSettings: PMapSettings): loadresult;
var
  wideChars: PWideChar;
Begin
  //Расширяем массив библиотек
  SetLength(Libs,Length(Libs)+1);
  //Чистим процедуры и фнукции от мусора
  @Libs[High(Libs)].functions.Init:=nil;
  {Пытаемся загрузить библиотеку}
  wideChars := PWideChar(WideString(modification.path));
  Libs[High(Libs)].Handle := LoadLibrary(wideChars);
  //Libs[High(Libs)].Handle := LoadLibrary(PAnsiChar('mods\'+name));
  Libs[High(Libs)].name := modification.name;
  Libs[High(Libs)].path := modification.path;

  if Libs[High(Libs)].Handle = 0 then
  Begin
    FreeLibrary(Libs[High(Libs)].Handle);
    SetLength(Libs, Length(Libs)-1);
    result := error;
  End;

  if Libs[High(Libs)].Handle <> 0 then
  begin
    @Libs[High(Libs)].functions.Init := GetProcAddress(Libs[High(Libs)].Handle,'Init');

    if @Libs[High(Libs)].functions.Init <> nil then
      Libs[High(Libs)].settings := Libs[High(Libs)].functions.Init(GetActivatedObject, PlayerKill, Win, MapSettings);

    if Libs[High(Libs)].settings.isPlayer then
    Begin
      SetLength(Players, length(Players)+1);
      Players[High(Players)].name := Libs[High(Libs)].name;
      Players[High(Players)].path := Libs[High(Libs)].path;
      Players[High(Players)].Handle := Libs[High(Libs)].Handle;
      Players[High(Players)].Settings := Libs[High(Libs)].Settings;
      SetLength(Libs, Length(Libs)-1);
      result := player;
    End else
    Begin
      if Libs[High(Libs)].settings.onDistance then
        @Libs[High(Libs)].functions.onDistance := GetProcAddress(Libs[High(Libs)].Handle,'onDistance');

      if Libs[High(Libs)].settings.onInside then
        @Libs[High(Libs)].functions.onInside:=GetProcAddress(Libs[High(Libs)].Handle,'onInside');

      if Libs[High(Libs)].settings.onAbove then
        @Libs[High(Libs)].functions.onAbove := GetProcAddress(Libs[High(Libs)].Handle,'onAbove');

      if Libs[High(Libs)].settings.onBelow then
        @Libs[High(Libs)].functions.onBelow := GetProcAddress(Libs[High(Libs)].Handle,'onBelow');

      result := obj;
    End;
  end;
End;

function TDLLManager.LoadGIF(Handle: THandle):TGIFImage;
Begin
  result := TGIFImage.Create;
  result.LoadFromStream(TResourceStream.Create(Handle, 'GIF', RT_RCDATA));
End;

function TDLLManager.LoadGIFPlayer(Handle: THandle):TPlayerAnimations;
Begin
  result.up := TGIFImage.Create;
  result.up.LoadFromStream(TResourceStream.Create(Handle, 'up', RT_RCDATA));
  result.down := TGIFImage.Create;
  result.down.LoadFromStream(TResourceStream.Create(Handle, 'down', RT_RCDATA));
  result.left := TGIFImage.Create;
  result.left.LoadFromStream(TResourceStream.Create(Handle, 'left', RT_RCDATA));
  result.right := TGIFImage.Create;
  result.right.LoadFromStream(TResourceStream.Create(Handle, 'right', RT_RCDATA));
  result.stand := TGIFImage.Create;
  result.stand.LoadFromStream(TResourceStream.Create(Handle, 'stand', RT_RCDATA));
  result.sit := TGIFImage.Create;
  result.sit.LoadFromStream(TResourceStream.Create(Handle, 'sit', RT_RCDATA));
  result.rightfast := TGIFImage.Create;
  result.rightfast.LoadFromStream(TResourceStream.Create(Handle, 'rightfast', RT_RCDATA));
  result.leftfast := TGIFImage.Create;
  result.leftfast.LoadFromStream(TResourceStream.Create(Handle, 'leftfast', RT_RCDATA));
end;

function TDLLManager.Run(name: string; on: string; Dist: Word; ObjectId,ActivatedId,PlayerType: Byte; Player: PPlayer): boolean;
begin
  result := true;
  if (on = 'Distance') and (Libs[IndexOf(name)].settings.onDistance) and (Libs[IndexOf(name)].settings.Distance <= Dist) then
    Libs[IndexOf(name)].functions.onDistance(Dist, ObjectId,ActivatedId,PlayerType,Player)
  else if (on = 'Inside') and (Libs[IndexOf(name)].settings.onInside) then
    Libs[IndexOf(name)].functions.onInside(ObjectId,ActivatedId,PlayerType,Player)
  else if (on = 'Above') and (Libs[IndexOf(name)].settings.onAbove) then
    Libs[IndexOf(name)].functions.onAbove(ObjectId,ActivatedId,PlayerType,Player)
  else if (on = 'Below') and (Libs[IndexOf(name)].settings.onBelow) then
    Libs[IndexOf(name)].functions.onBelow(ObjectId,ActivatedId,PlayerType,Player)
  else if (on = 'Activate') and (Libs[IndexOf(name)].settings.onActivate) then
    Libs[IndexOf(name)].functions.onActivate(ObjectId,ActivatedId,PlayerType,Player)
  else result := false;
end;

function TDLLManager.LoadALL(name: string; ListBox: TListBox; myobj: TObj; playerslist: TPlayers; GetActivatedObject: PGetActivatedObject; PlayerKill: PPlayerKill; Win: PWin; MapSettings: PMapSettings): boolean;
var
  search: TSearchRec;
  info: modinfo;
Begin
  if FindFirst(name + '\*.dll',faAnyFile,search) = 0 then
    repeat
      info.name := copy(search.Name, 0, Length(search.Name)-4);
      info.path := 'mods\'+search.Name;
      case Load(info, ListBox, GetActivatedObject, PlayerKill, Win, MapSettings) of
        player: if myobj <> nil then
          playerslist.Add(info.name, Players[High(Players)].Settings, LoadGIFPlayer(Players[High(Players)].Handle));
        obj: if myobj <> nil then
          myobj.Add(info.name, Libs[High(Libs)].Settings, LoadGIF(Libs[High(Libs)].Handle));
      end;
    until FindNext(search) <> 0;
  FindClose(search);
  result := true;
End;

function TDLLManager.UnLoad(name: string; ListBox: TListBox=nil): boolean;
var
  N: Word;
  i: Word;
Begin
  N := IndexOf(name);
  try
    FreeLibrary(Libs[N].Handle);
    if N <> High(Libs) then for i := N to High(Libs)-1 do Libs[i] := Libs[i+1];
    if (ListBox <> nil) then
    Begin
      ListBox.Selected[N] := true;
      ListBox.DeleteSelected;
    End;
    SetLength(Libs, Length(Libs)-1);
  except
    result := false;
  end;
  result := true;
End;

procedure TDLLManager.UnLoadAll(ListBox: TListBox=nil);
var
  i: Word;
Begin
  if Length(Libs) > 0 then for i := 0 to High(Libs) do FreeLibrary(Libs[i].Handle);
  SetLength(Libs, 0);
  if (ListBox <> nil) then ListBox.Items.Clear;
End;

function TDLLManager.GetHandle(Index: Word):THandle;
Begin
  result := Libs[Index].Handle;
End;

initialization
Begin
  SetLength(Libs,0);
End;

finalization
Begin
  if Length(Libs) > 0 then for i := 0 to High(Libs) do FreeLibrary(Libs[i].Handle);
  SetLength(Libs, 0);
End;

end.
