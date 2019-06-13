unit DLLManager;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Dialogs, Jpeg, StdCtrls, GIFImg,
  TFNW;

type
  TDLLManager = class
    function IndexOf(name: string):Word;
    function Load(name: string; ListBox: TListBox=nil): boolean;
    function LoadJPEG(Handle: THandle):TJPEGImage;
    function LoadGIF(Handle: THandle):TGIFImage;
    function LoadALL(name: string; ListBox: TListBox=nil; myobj: TObj=nil): boolean;
    function UnLoad(name: string; ListBox: TListBox=nil): boolean;
    procedure UnLoadAll(ListBox: TListBox=nil);
    function GetHandle(Index: Word):THandle;
    function Run(name: string; on: string; blockpos: Tpos; playerpos: Tpos; side: byte=0; Dist: Word=0): boolean;
  private

  public

  end;

var
  Libs: array of record
    name: string;
    Handle: THandle;
    functions: record
      Init: function: Pointer;
      onAbove: procedure(side: byte; blockpos: Tpos; playerpos: Tpos);
      onBelow: procedure(side: byte; blockpos: Tpos; playerpos: Tpos);
      onDistance: procedure(Dist: Word; blockpos: Tpos; playerpos: Tpos);
      onInside: procedure(blockpos: Tpos; playerpos: Tpos);
    end;
    settings: ^TSettings;
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

function TDLLManager.Load(name: string; ListBox: TListBox=nil): boolean;
var
  wideChars: PWideChar;
Begin
  //Расширяем массив библиотек
  SetLength(Libs,Length(Libs)+1);
  //Чистим процедуры и фнукции от мусора
  @Libs[High(Libs)].functions.Init:=nil;
  {Пытаемся загрузить библиотеку}
  wideChars := PWideChar(WideString(name));
  Libs[High(Libs)].Handle := LoadLibrary(wideChars);
  //Libs[High(Libs)].Handle := LoadLibrary(PAnsiChar(name));
  Libs[High(Libs)].name := name;

  if Libs[High(Libs)].Handle = 0 then
  Begin
    FreeLibrary(Libs[High(Libs)].Handle);
    SetLength(Libs, Length(Libs)-1);
    result := false;
  End else
  Begin
    if (ListBox <> nil) then ListBox.Items.Add(name);
    result := true;
  End;

  if Libs[High(Libs)].Handle <> 0 then
  begin
    @Libs[High(Libs)].functions.Init := GetProcAddress(Libs[High(Libs)].Handle,'Init');

    if @Libs[High(Libs)].functions.Init <> nil then
      Libs[High(Libs)].settings := Libs[High(Libs)].functions.Init;

    if Libs[High(Libs)].settings.onDistance then
      @Libs[High(Libs)].functions.onDistance := GetProcAddress(Libs[High(Libs)].Handle,'onDistance');

    if Libs[High(Libs)].settings.onInside then
      @Libs[High(Libs)].functions.onInside:=GetProcAddress(Libs[High(Libs)].Handle,'onInside');

    if Libs[High(Libs)].settings.onAbove then
      @Libs[High(Libs)].functions.onAbove := GetProcAddress(Libs[High(Libs)].Handle,'onAbove');

    if Libs[High(Libs)].settings.onBelow then
      @Libs[High(Libs)].functions.onBelow := GetProcAddress(Libs[High(Libs)].Handle,'onBelow');
  end;
End;

function TDLLManager.LoadJPEG(Handle: THandle):TJPEGImage;
var
  RS: TResourceStream;
Begin
  result := TJPEGImage.Create;
  RS := TResourceStream.Create(Handle, 'PIC', RT_RCDATA);
  result.LoadFromStream(RS);
End;

function TDLLManager.LoadGIF(Handle: THandle):TGIFImage;
var
  RS: TResourceStream;
Begin
  result := nil;
  exit;
  if not Libs[High(Libs)].settings.animation then result := nil
  else Begin
    result := TGIFImage.Create;
    RS := TResourceStream.Create(Handle, 'GIF', RT_RCDATA);
    result.LoadFromStream(RS);
  End;
End;

function TDLLManager.Run(name: string; on: string; blockpos: Tpos; playerpos: Tpos; side: byte=0; Dist: Word=0): boolean;
begin
  result := true;
  if (on = 'Distance') and (Libs[IndexOf(name)].settings.onDistance) and (Libs[IndexOf(name)].settings.Distance <= Dist) then
    Libs[IndexOf(name)].functions.onDistance(Dist, blockpos, playerpos)
  else if (on = 'Inside') and (Libs[IndexOf(name)].settings.onInside) then
    Libs[IndexOf(name)].functions.onInside(blockpos, playerpos)
  else if (on = 'Above') and (Libs[IndexOf(name)].settings.onAbove) then
    Libs[IndexOf(name)].functions.onAbove(side, blockpos, playerpos)
  else if (on = 'Below') and (Libs[IndexOf(name)].settings.onBelow) then
    Libs[IndexOf(name)].functions.onBelow(side, blockpos, playerpos)
  else result := false;
end;

function TDLLManager.LoadALL(name: string; ListBox: TListBox=nil; myobj: TObj=nil): boolean;
var
  sr: TSearchRec;
  SL: TStringList;
Begin
  if FindFirst(name + '\*.dll',faAnyFile,sr) = 0 then
    repeat
      SL := TStringList.Create;
      SL.Delimiter := '.';
      SL.DelimitedText := sr.Name;
      if Load(name + '\' + sr.Name, ListBox) and (myobj <> nil) then
      Begin
        myobj.Add(LoadJPEG(Libs[High(Libs)].Handle), SL[0], Libs[High(Libs)].Settings, LoadGIF(Libs[High(Libs)].Handle));
      End;
    until FindNext(sr) <> 0;
  FindClose(sr);
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
