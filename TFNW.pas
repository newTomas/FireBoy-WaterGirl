unit TFNW;

interface

type
  Tpos = record
    x, y: Word;
  end;
  TInit = record
    Distance: Word;
    onDistance, onInside, onAbove, onBelow: Boolean;
  end;
  TMap = record
    x, y: Word;
    name: string[32];
    rotate: Single;
  end;

implementation

end.
