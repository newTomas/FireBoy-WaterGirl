unit TFNW;

interface

uses Jpeg, Graphics, Windows, ExtCtrls, GIFImg,
 Classes, Math, Controls, Dialogs, SysUtils, IdContext;

type
  TPing = record
    name: string;
    map: string;
    maxplayers: byte;
    players: byte;
    work: boolean;
  end;
  Tpos = record
    x, y: Word;
  end;
  TSettings = record
    Distance: Word;
    activate: Byte;
    Transparent: TColor;
    onDistance, onInside, onAbove, onBelow, onActivate: Boolean;
    collision, gravity, driven, animation: boolean;
    AnimPos: TPoint;
  end;
  TSettingsMap = record
    width, height: Word;
  end;
  TMap = record
    x, y: Word;
    width, height: Word;
    name: string[32];
    activate: Word; //Какой объект активирует
  end;
  TAnim = class
    private
      gif: TGIFImage;
      frame: Word;
    public
      Image: TImage;
      procedure Change(Percent: Byte);
      procedure SetPos(Left, Top: Integer);
      procedure FromTo(PercentFrom: Byte=0; PercentTo: Byte=128);
      constructor Create(AOwner: TComponent; GifImg: TGIFImage);
  end;
  TObj = class
    private
      arr: array of record
        ObjPic: TJPEGImage;
        ObjName: string;
        Settings: ^TSettings;
        GIF: TGIFImage;
      end;
      function GetPic(Index: Word): TJPEGImage;
      function GetGIF(Index: Word): TGIFImage;
      function GetName(Index: Word): string;
      function GetCount: Word;
      function GetSettings(Index: Word): Pointer;

    public
      property Pic[Index: Word]: TJPEGImage read GetPic;
      property GIF[Index: Word]: TGIFImage read GetGIF;
      property Name[Index: Word]: string read GetName;
      property Count: Word read GetCount;
      property Settings[Index: Word]: Pointer read GetSettings;
      procedure Add(const ObjPic: TJPEGImage; const ObjName: string; const Settings: Pointer; GIF: TGIFImage=nil);

      constructor Create;
  end;

function RoundUp(Value, N: Integer): Integer;

implementation

function RoundUp(Value, N: Integer): Integer;
asm
   push ebx
   mov ebx, eax
   mov ecx, edx
   cdq
   idiv ecx
   imul ecx

   add ecx, eax
   mov edx, ebx
   sub ebx, eax
   jg @@10
   neg ebx
@@10:
   sub edx, ecx
   jg @@20
   neg edx
@@20:
   cmp ebx, edx
   jl @@30
   mov eax, ecx
@@30:
   pop ebx
end;

constructor TObj.Create;
Begin
  SetLength(arr, 0);
End;

procedure TObj.Add(const ObjPic: TJPEGImage; const ObjName: string; const Settings: Pointer; GIF: TGIFImage=nil);
begin
  SetLength(self.arr,length(self.arr)+1);
  arr[High(arr)].ObjPic := ObjPic;
  if GIF <> nil then arr[High(arr)].gif := gif;
  arr[High(arr)].ObjName := ObjName;
  arr[High(arr)].Settings := Settings;
end;

function TObj.GetPic(Index: Word): TJPEGImage;
Begin
  result := arr[Index].ObjPic;
End;

function TObj.GetSettings(Index: Word): Pointer;
begin
  result := arr[Index].Settings;
end;

function TObj.GetName(Index: Word): string;
Begin
  result := arr[Index].ObjName;
End;

function TObj.GetCount: Word;
Begin
  result := Length(arr);
End;

function TObj.GetGIF(Index: Word): TGIFImage;
begin
  result := arr[Index].gif;
end;

{ TAnim }

procedure TAnim.Change(Percent: Byte);
begin
  frame := Floor((gif.Images.Count-1) * Percent/100);
  Image.Picture.Bitmap := gif.Images.Frames[frame].Bitmap;
  Image.Parent.Repaint;
end;

constructor TAnim.Create(AOwner: TComponent;  GifImg: TGIFImage);
begin
  Image := TImage.Create(AOwner);
  Image.Parent := AOwner as TWinControl;
  Image.Left := 0;
  Image.Top := 0;
  Image.AutoSize := true;
  gif := GifImg;
  frame := 0;
  Change(0);
end;

procedure TAnim.FromTo(PercentFrom: Byte=0; PercentTo: Byte=128);
var
  i: Byte;
begin
  ShowMessage(IntToStr(PercentFrom));
  if PercentTo > 100 then
  Begin
    PercentFrom := frame div (gif.Images.Count-1);
  End;
  ShowMessage(IntToStr(PercentFrom));
  for i := PercentFrom to PercentTo do
  Begin
    Change(i);
    Sleep(500);
  End;
end;

procedure TAnim.SetPos(Left, Top: Integer);
begin
  Image.Left := Left;
  Image.Top := Top;
end;

end.
