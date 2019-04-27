unit DLLManager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Dialogs, Vcl.Imaging.pngimage, StdCtrls,
  TFNW;

type
  TDLLManager = class
    function IndexOf(name: string):Word;
    function Load(name: string; ListBox: TListBox=nil): boolean;
    function LoadPNG(Handle: THandle):TPngImage;
    function LoadALL(name: string; ListBox: TListBox=nil; list: TList=nil): boolean;
    function UnLoad(name: string; ListBox: TListBox=nil): boolean;
    procedure UnLoadAll(ListBox: TListBox=nil);
    function GetHandle(Index: Word):THandle;
  private

  public

  end;

var
  Libs: array of record
    name: string;
    Handle: THandle;
    functions: record
      Init: function: TInit;
      onAbove: procedure(side: byte; blockpos: Tpos; playerpos: Tpos);
      onBelow: procedure(side: byte; blockpos: Tpos; playerpos: Tpos);
      onDistance: procedure(Dist: Word; blockpos: Tpos; playerpos: Tpos);
      onInside: procedure(blockpos: Tpos; playerpos: Tpos);
    end;
    settings: TInit;
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
  //��������� ������ ���������
  SetLength(Libs,Length(Libs)+1);
  //������ ��������� � ������� �� ������
  @Libs[High(Libs)].functions.Init:=nil;
  {�������� ��������� ����������}
  wideChars := PWideChar(WideString(name));
  Libs[High(Libs)].Handle := LoadLibrary(wideChars);
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
    @Libs[High(Libs)].functions.Init:=GetProcAddress(Libs[High(Libs)].Handle,'Init');

    if @Libs[High(Libs)].functions.Init <> nil then
      Libs[High(Libs)].settings := Libs[High(Libs)].functions.Init;

    if (Libs[High(Libs)].settings.onDistance) and (@Libs[High(Libs)].functions.onDistance <> nil) then
      @Libs[High(Libs)].functions.onDistance := GetProcAddress(Libs[High(Libs)].Handle,'onDistance');

    if (Libs[High(Libs)].settings.onInside) and (@Libs[High(Libs)].functions.onInside <> nil) then
      @Libs[High(Libs)].functions.onInside:=GetProcAddress(Libs[High(Libs)].Handle,'onInside');

    if (Libs[High(Libs)].settings.onAbove) and (@Libs[High(Libs)].functions.onAbove <> nil) then
      @Libs[High(Libs)].functions.onAbove := GetProcAddress(Libs[High(Libs)].Handle,'onAbove');

    if (Libs[High(Libs)].settings.onBelow) and (@Libs[High(Libs)].functions.onBelow <> nil) then
      @Libs[High(Libs)].functions.onBelow := GetProcAddress(Libs[High(Libs)].Handle,'onBelow');
  end;
End;

function TDLLManager.LoadPNG(Handle: THandle):TPngImage;
Begin
  result := TPngImage.Create;
  result.LoadFromResourceName(Handle, 'pic');
End;

function TDLLManager.LoadALL(name: string; ListBox: TListBox=nil; list: TList=nil): boolean;
var
  sr: TSearchRec;
  SL: TStringList;
Begin
  if FindFirst(name + '\*.dll',faAnyFile,sr) = 0 then
    repeat
      SL := TStringList.Create;
      SL.Delimiter := '.';
      SL.DelimitedText := sr.Name;
      if Load(name + '\' + sr.Name, ListBox) and (list <> nil) then list.Add(LoadPNG(Libs[High(Libs)].Handle));
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
