unit fMain;

{
  Delphi: How to get data from API

  This demo show you, How to get the data from API
  and show you how to work with New VCL Control ,TControlList

  API Link:
  https://static.easysunday.com/covid-19/getTodayCases.json

}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.BaseImageCollection,
  Vcl.ImageCollection, Vcl.ControlList, Vcl.VirtualImage, Vcl.StdCtrls,
  REST.Types, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope;

type
  TCovidData = record
    Key: string;
    Value: string;
  end;

  TForm1 = class(TForm)
    ControlList1: TControlList;
    Label1: TLabel;
    VirtualImage1: TVirtualImage;
    Label2: TLabel;
    ControlListButton1: TControlListButton;
    ControlListButton2: TControlListButton;
    ImageCollection1: TImageCollection;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    procedure FormActivate(Sender: TObject);
    procedure ControlList1BeforeDrawItem(AIndex: Integer; ACanvas: TCanvas;
      ARect: TRect; AState: TOwnerDrawState);
  private
    { Private declarations }
    CovidData: TArray<TCovidData>;
    procedure GetCovid19DataFromAPI;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses System.JSON;
{ TForm1 }

procedure TForm1.ControlList1BeforeDrawItem(AIndex: Integer; ACanvas: TCanvas;
  ARect: TRect; AState: TOwnerDrawState);
begin
  Label2.Caption := CovidData[AIndex].Key;
  Label1.Caption := CovidData[AIndex].Value;
  VirtualImage1.ImageIndex := 0;
  if CovidData[AIndex].Value = 'Thailand' then
    VirtualImage1.ImageIndex := 1
  else if Pos('DEATHS', UpperCase(CovidData[AIndex].Key)) > 0 then
    VirtualImage1.ImageIndex := 2;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  GetCovid19DataFromAPI;
end;

procedure TForm1.GetCovid19DataFromAPI;
var
  jsv: TJSONValue;
  jsPair: TJSONPair;
  jso: TJSONObject;
  i: Integer;
begin
  try
    RESTRequest1.Execute;
    if RESTResponse1.StatusCode = 200 then
    begin
      jsv := TJSONObject.ParseJSONValue(RESTResponse1.Content);
      try
        jso := jsv as TJSONObject;
        SetLength(CovidData, jso.Count);
        i := 0;
        for jsPair in jso do
        begin
          CovidData[i].Key := jsPair.JsonString.Value;
          CovidData[i].Value := jsPair.JsonValue.Value;
          Inc(i);
        end;
        ControlList1.Enabled := False;
        ControlList1.ItemCount := jso.Count;
        ControlList1.Enabled := True;
      finally
        jsv.free;
      end;
    end;
  except
    on E: exception do
    begin
      Showmessage(format('', [E.ClassName, E.Message]));
    end;
  end;

end;

end.
