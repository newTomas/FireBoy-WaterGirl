library WaterDoor;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

{$R 'WaterDoor.res' 'WaterDoor.rc'}

uses
  SysUtils,
  Classes,
  Dialogs,
  Graphics,
  TFNW;

var
  Settings: TSettings;
  GetActivatedObject: function(id: Byte): TMapObject;
  PlayerKill: TPlayerKill;
  Win: TWin;


function Init(TGetActivatedObject, TPlayerKill, TWin: Pointer): pointer;
Begin
  Settings.Distance := 0;
  Settings.onDistance := false;
  Settings.onActivate := false;
  Settings.onInside := false;
  Settings.onAbove := false;
  Settings.onBelow := false;

  Settings.collision := true;
  Settings.gravity := false;
  Settings.Transparent := clWhite;
  Settings.animation := false;
  Settings.AnimPos.X := 0;
  Settings.AnimPos.Y := 0;

  Settings.activate := 100;
  result := @Settings;
End;

exports Init;

begin
end.
