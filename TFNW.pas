unit TFNW;

interface

uses Jpeg, Graphics, Windows, ExtCtrls, GIFImg, Classes, Math, Controls, Dialogs, SysUtils, IdContext,
IdHashMessageDigest, idHash;

type
  TObjectActions = (MoveObject, MovePlayer, KillPlayer, ChangeSpawn);
  TObjectData = record
    ActionType: TObjectActions;
    id: Word;
    coords: TPoint;
  end;
  TMessageActions = (Ping, NeedsDownload, PlayerMove, ObjectMove, PlayerConnected, PlayerDisconnected, ChangePlayerType, TextMessage, ChangeMap, ChangeNick, PlayerReady, GameStart, GameEnd);
  TMove = record
    id: Word;
    x,y: Word;
  end;
  TPlayerConnectedChangeNick = record
    id: Byte;
    nick: string[32];
  end;
  TPlayerDisconnected = record
    id: Byte;
  end;
  TPlayerChangeType = record
    id: Byte;
    PlayerType: Byte;
  end;
  TPlayerReady = record
    id: Byte;
    ready: boolean;
  end;
  TChangeMap = record
    name: string[32];
    hash: string[32];
  end;
  TMessage = record
    id: Byte;
    Text: ShortString;
  end;
  TAnimType = (Obj, player);
  TTAnimType = (move, action);
  PMapSettings = ^TMapSettings;
  TMoveType = (collision, ending);
  PMapObject = ^TMapObject;
  TMapObject = record
    img: TImage;
    width, height: Word;
    name: string[32];
    data: array of TObjectData; // Действия при активации
  end;
  PGetMapSettings = ^TGetMapSettings;
  TGetMapSettings = function: PMapSettings;
  PGetActivatedObject = ^TGetActivatedObject;
  TGetActivatedObject = function(id: Byte): PMapObject;
  PAddAnim = ^TAddAnim;
  TAddAnim = procedure(TType: TTAnimType; AType: TAnimType; Id, ms: Word; var start, stop);
  PWin = ^TWin;
  TWin = procedure;
  PPlayerKill = ^TPlayerKill;
  TPlayerKill = procedure(playertype: Byte);
  PChangeSpawn = ^TChangeSpawn;
  TChangeSpawn = procedure(coords: Tpoint; playertype: SmallInt=-1);
  PAddMove = ^TAddMove;
  TAddMove = procedure(AType: TMoveType; id: Word; coords: Tpoint);
  PMovePlayer = ^TMovePlayer;
  TMovePlayer = function(id: Byte; coords: TPoint): boolean;
  TMapsList = array of record
    name, hash: string;
  end;
  TPing = record
    name: string[32];
    map: string[32];
    hash: string[32];
    maxplayers: byte;
    players: byte;
  end;
  Tpos = record
    x, y: Word;
  end;
  TMapSettings = record
    start: TPos;
    points: record
      global: Word;
      players: array of Word;
    end;
  end;
  PSettings = ^TSettings;
  TSettings = record
    isPlayer: boolean;
    PlayerSpeedSettings: record
      up, down: Currency;
      left: record
        normal, fast: Currency;
      end;
      right: record
        normal, fast: Currency;
      end;
    end;
    Distance: Word;
    activate: Byte;
    Transparent: TColor;
    onDistance, onInside, onAbove, onBelow, onActivate: Boolean;
    collision, gravity: boolean;
  end;
  TSettingsMap = record
    width, height: Word;
    players: Byte;
  end;
  TMap = record
    x, y: Word;
    width, height: Word;
    name: string[32];
    data: TObjectData;
  end;
  TPlayerAnimations = record
    up, down, left, right, stand, sit, rightfast, leftfast: TGIFImage;
  end;
  TAnim = class
    private
      gif: TGIFImage;
    public
      frame: Word;
      Image: TImage;
      Transparent: TColor;
      procedure Change(Percent: Byte);
      procedure SetPos(Left, Top: Integer);
      constructor Create(AOwner: TComponent; GifImg: TGIFImage; ATransparent: TColor=clNone);
  end;
  PPlayer = ^TPlayers;
  TPlayers = class
    private
      arr: array of record
        PlayerName: string;
        Settings: PSettings;
        {Settings: record
          Left: Currency;
          Top: Currency;
          img: TImage;
          anim: TAnim;
          jump: Byte;
          gravity: record
            left, right, down, up: Byte;
          end;
        end;  }
        GIF: TPlayerAnimations;
      end;
      function GetAnim(Index: Word): TPlayerAnimations;
      function GetName(Index: Word): string;
      function GetCount: Word;
      function GetSettings(Index: Word): Pointer;
    public

      property Count: Word read GetCount;
      property Settings[Index: Word]: Pointer read GetSettings;
      property Name[Index: Word]: string read GetName;
      property Anim[Index: Word]: TPlayerAnimations read GetAnim;
      procedure Add(PlayerName: string; Settings: Pointer; GIF: TPlayerAnimations);
  end;
  TObj = class
    private
      arr: array of record
        ObjName: string;
        Settings: PSettings;
        GIF: TGIFImage;
      end;
      //function GetPic(Index: Word): TJPEGImage;
      function GetGIF(Index: Word): TGIFImage;
      function GetName(Index: Word): string;
      function GetCount: Word;
      function GetSettings(Index: Word): Pointer;

    public
      //property Pic[Index: Word]: TJPEGImage read GetPic;
      property GIF[Index: Word]: TGIFImage read GetGIF;
      property Name[Index: Word]: string read GetName;
      property Count: Word read GetCount;
      property Settings[Index: Word]: Pointer read GetSettings;
      procedure Add(ObjName: string; Settings: Pointer; GIF: TGIFImage);

      constructor Create;
  end;

procedure LoadDFMtoComponent(filepath: string; component: TComponent);
function Distance(ax,ay,bx,by: Word): Word;
function RoundUp(Value, N: Integer): Integer;
function MD5(const fileName : string) : string;

implementation

procedure LoadDFMtoComponent(filepath: string; component: TComponent);
var
  BinStream: TMemoryStream;
  StrStream: TStringStream;
  SL: TStringList;
Begin
  BinStream := TMemoryStream.Create;
  Sl:=TStringList.Create;
  Sl.LoadFromFile(filepath);
  StrStream := TStringStream.Create(SL.Text);
  try
    StrStream.Position:=0;
    ObjectTextToBinary(StrStream, BinStream);
    BinStream.Seek(0, soFromBeginning);
    BinStream.ReadComponent(component);
  finally
    BinStream.Free;
    StrStream.Free;
  end;
End;

function Distance(ax,ay,bx,by: Word): Word;
Begin
  result := Round(sqrt(sqr(bx-ax)+sqr(by-ay)));
End;

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

procedure TObj.Add(ObjName: string; Settings: Pointer; GIF: TGIFImage);
begin
  SetLength(arr,length(arr)+1);
  arr[High(arr)].gif := TGifImage.Create;
  arr[High(arr)].gif.Assign(GIF);
  arr[High(arr)].gif.Bitmap.PixelFormat := pf32bit;
  arr[High(arr)].ObjName := ObjName;
  arr[High(arr)].Settings := Settings;
end;

{function TObj.GetPic(Index: Word): TJPEGImage;
Begin
  result := arr[Index].ObjPic;
End; }

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

{ TPlayer }

function TPlayers.GetAnim(Index: Word): TPlayerAnimations;
begin
  result := arr[Index].GIF;
end;

function TPlayers.GetName(Index: Word): string;
Begin
  result := arr[Index].PlayerName;
End;

function TPlayers.GetCount: Word;
Begin
  result := Length(arr);
End;

function TPlayers.GetSettings(Index: Word): Pointer;
begin
  result := arr[Index].Settings;
end;

procedure TPlayers.Add(PlayerName: string; Settings: Pointer; GIF: TPlayerAnimations);
begin
  SetLength(arr,length(arr)+1);
  arr[High(arr)].gif := GIF;
  //arr[High(arr)].gif.Bitmap.PixelFormat := pf32bit;
  arr[High(arr)].PlayerName := PlayerName;
  arr[High(arr)].Settings := Settings;
end;

{ TAnim }

procedure TAnim.Change(Percent: Byte);
begin
  frame := Floor((gif.Images.Count-1) * Percent/100);
  Image.Picture.Bitmap := gif.Images.Frames[frame].Bitmap;
  Image.Picture.Bitmap.TransparentMode := tmFixed;
  Image.Picture.Bitmap.TransparentColor := Transparent;
  Image.Parent.Repaint;
end;

constructor TAnim.Create(AOwner: TComponent;  GifImg: TGIFImage; ATransparent: TColor);
begin
  Image := TImage.Create(AOwner);
  Image.Parent := AOwner as TWinControl;
  Image.Left := 0;
  Image.Top := 0;
  Image.AutoSize := true;
  Image.Transparent := true;
  Transparent := ATransparent;
  Image.Visible := false;
  gif := GifImg;
  frame := 0;
  Change(0);
end;

procedure TAnim.SetPos(Left, Top: Integer);
begin
  Image.Left := Left;
  Image.Top := Top;
end;

end.
