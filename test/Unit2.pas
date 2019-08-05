unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, JSON, IOUtils,
  Vcl.ComCtrls, Vcl.Grids, Vcl.Imaging.GIFImg, Vcl.ExtCtrls, Vcl.Buttons;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ListView1: TListView;
    Button3: TButton;
    Image1: TImage;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TActions = (ObjectMove, PlayerMove);

  TData = record
    id: Word;
    action: TActions;
    time: LongWord;
  end;

  TMap = record
    name: string[32];
    data: array of TData;
  end;

var
  Form2: TForm2;
  arr: array[1..65535] of TMap;
  json: TJSONArray;

implementation

{$R *.dfm}

procedure load;
var
  i,j: Word;
Begin
  json := TJSONObject.ParseJSONValue(TFile.ReadAllText('test.txt')) as TJSONArray;
  ShowMessage((json.Items[0].FindValue('data') as TJSONArray).Items[0].FindValue('time').Value);
  for i := 0 to pred(json.Count) do
  Begin
    arr[i+1].name := json.Items[i].FindValue('name').Value;
    SetLength(arr[i+1].data, (json.Items[i].FindValue('data') as TJSONArray).Count);
    for j := 0 to high(arr[i+1].data) do
    Begin
      arr[i+1].data[j].id := StrToInt((json.Items[i].FindValue('data') as TJSONArray).Items[j].FindValue('id').Value);
      arr[i+1].data[j].action := TActions(StrToInt((json.Items[i].FindValue('data') as TJSONArray).Items[j].FindValue('action').Value));
      arr[i+1].data[j].time := StrToInt((json.Items[i].FindValue('data') as TJSONArray).Items[j].FindValue('time').Value);
    End;
  End;
  ShowMessage(arr[1].name);
End;

procedure save;
Begin
  TFile.WriteAllText('test.txt', json.Format(2));
End;

procedure TForm2.Button1Click(Sender: TObject);
begin
  Save;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  Load;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  ListView1.Items.Add;
  ListView1.Items[ListView1.Items.Count - 1].Caption := 'Перемещение игрока';
  ListView1.Items[ListView1.Items.Count - 1].SubItems.Add('0');
  ListView1.Items[ListView1.Items.Count - 1].SubItems.Add('5');
  ListView1.Items[ListView1.Items.Count - 1].SubItems.Add('12');
end;

procedure TForm2.FormCreate(Sender: TObject);
var
  jsonarray: TJSONArray;
  jsonarrobj: TJSONObject;
  jsonobj: TJSONObject;
begin
  canvas.Font := BitBtn1.Font;
  while Canvas.TextWidth(BitBtn1.Caption) > 65 do
    canvas.Font.Height := canvas.Font.Height - 1;
  //BitBtn1.Width := Canvas.TextWidth(BitBtn1.Caption);
  ShowMessage(IntToStr(canvas.Font.Height));
  BitBtn1.Font.Height := canvas.Font.Height;

  json := TJSONArray.Create;
  json.AddElement(TJSONObject.Create);
  jsonobj:=json.Items[pred(json.Count)] as TJSONObject;
  jsonobj.AddPair('name', 'test1');

  JSONArray := TJSONArray.Create;
  JSONArray.AddElement(TJSONObject.Create);
  jsonarrobj:=JSONArray.Items[pred(JSONArray.Count)] as TJSONObject;
  jsonarrobj.AddPair('id',TJSONNumber.Create(5))
    .AddPair('action',TJSONNumber.Create(Word(ObjectMove)))
    .AddPair('time',TJSONNumber.Create(1968941));

  JSONArray.AddElement(TJSONObject.Create);
  jsonarrobj:=JSONArray.Items[pred(JSONArray.Count)] as TJSONObject;
  jsonarrobj.AddPair('id',TJSONNumber.Create(7))
    .AddPair('action',TJSONNumber.Create(Word(ObjectMove)))
    .AddPair('time',TJSONNumber.Create(1968421));
  jsonobj.AddPair('data', JSONArray);


  json.AddElement(TJSONObject.Create);
  jsonobj:=json.Items[pred(json.Count)] as TJSONObject;
  jsonobj.AddPair('name', 'test2');

  JSONArray := TJSONArray.Create;
  JSONArray.AddElement(TJSONObject.Create);
  jsonarrobj:=JSONArray.Items[pred(JSONArray.Count)] as TJSONObject;
  jsonarrobj.AddPair('id',TJSONNumber.Create(1))
    .AddPair('action',TJSONNumber.Create(Word(PlayerMove)))
    .AddPair('time',TJSONNumber.Create(1897));
  jsonobj.AddPair('data', JSONArray);
end;

procedure TForm2.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  ShowMessage(BoolToStr(Selected));
end;

end.


