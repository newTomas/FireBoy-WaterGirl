unit TFNW;

interface

uses Vcl.Imaging.Jpeg, Vcl.Graphics, Windows, Vcl.ExtCtrls, Vcl.Imaging.GIFImg, Classes, Math, Vcl.Controls, Vcl.Dialogs, SysUtils, IdContext,
IdHashMessageDigest, idHash;

type
  PMapObject = ^TMapObject;
  TMapObject = record
    img: TImage;
    width, height: Word;
    name: string[32];
    activate: Word; // Какой объект активирует
  end;
  PGetActivatedObject = ^TGetActivatedObject;
  TGetActivatedObject = function(id: Byte): PMapObject;
  PWin = ^TWin;
  TWin = procedure;
  PPlayerKill = ^TPlayerKill;
  TPlayerKill = procedure(playertype: Byte);
  TMapsList = array of record
    name, hash: string;
  end;
  TPing = record
    name: string;
    map: string;
    hash: string;
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
    collision, gravity, animation: boolean;
    AnimPos: TPoint;
  end;
  TSettingsMap = record
    width, height: Word;
    background: record
      width, height: Word;
    end;
    players: Byte;
    start: array[0..255] of Tpos;
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
    public          
      frame: Word;
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
function MD5(const fileName : string) : string;

implementation

function MD5(const fileName : string) : string;
 var
   idmd5 : TIdHashMessageDigest5;
   fs : TFileStream;
   hash : T4x4LongWordRecord;
 begin
   idmd5 := TIdHashMessageDigest5.Create;
   fs := TFileStream.Create(fileName, fmOpenRead OR fmShareDenyWrite) ;
   try
     //result := idmd5.AsHex(idmd5.HashValue(fs));
     result := idmd5.HashStreamAsHex(fs);
   finally
     fs.Free;
     idmd5.Free;
   end;
 end;

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
