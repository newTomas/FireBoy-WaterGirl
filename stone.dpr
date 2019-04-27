library stone;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }



{$R *.dres}

uses
  System.SysUtils,
  System.Classes,
  VCL.Dialogs,
  TFNW;

var
  Settings: TInit;


function Init: TInit;
Begin
  Settings.Distance := 3;
  Settings.onDistance := false;
  Settings.onInside := false;
  Settings.onAbove := false;
  Settings.onBelow := false;
  result := Settings;
End;

procedure onAbove(side: byte; blockpos: Tpos; playerpos: Tpos);
Begin

End;

procedure onBelow(side: byte; blockpos: Tpos; playerpos: Tpos);
Begin

End;

procedure onDistance(Dist: Word; blockpos: Tpos; playerpos: Tpos);
Begin

End;

procedure onInside(blockpos: Tpos; playerpos: Tpos);
Begin

End;

exports Init,onAbove,onBelow,onInside,onDistance;

begin
end.
