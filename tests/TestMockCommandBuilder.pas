unit TestMockCommandBuilder;

{$MODE DELPHI}{$H+}

interface

uses
  SysUtils, 
  Classes,
  rtti, 
  typinfo,
  Command.Interfaces;

type
  TCommandBuildMock = class(TVirtualInterface)
  private
    class var aID : Integer;
  private
    FName: String;
    FData: TStringList;
    procedure HandleInvoke(aMethod: TRttiMethod; const aArgs: TValueArray; out aResult: TValue);
  public
    constructor Create(aTypeInfo: PTypeInfo; AData: TStringList);

    class function New<T: IInterface>(AData: TStringList): T;
  end;

  procedure MockCommand(ABuilder: ICommandBuilder);
  function MockInputLn: string;

var
  MockCommandCapture, MockInputLnResult: string;

implementation

uses
  StrUtils;

procedure MockCommand(ABuilder: ICommandBuilder);
begin  
  MockCommandCapture := 'executed';
end;

function MockInputLn: string;
begin
  Result := MockInputLnResult;
end;

procedure TCommandBuildMock.HandleInvoke(aMethod: TRttiMethod; const aArgs: TValueArray; 
  out aResult: TValue);
var
  LResult: TArray<string>;
begin
  FData.Add(aMethod.Name);
  if SameText(aMethod.Name, 'validate') then
  begin
    SetLength(LResult, 0);
    aResult := TValue.From<TStringArray>(LResult);
  end;
end;

constructor TCommandBuildMock.Create(aTypeInfo: PTypeInfo; AData: TStringList);
begin
  inherited Create(aTypeInfo, HandleInvoke);
  FName := aTypeInfo^.Name;
  FData := AData;
end;

class function TCommandBuildMock.New<T>(AData: TStringList): T;
var
  LResult: TCommandBuildMock;
  td: PTypeData;
begin
  LResult := TCommandBuildMock.Create(PTypeInfo(TypeInfo(T)), AData);
  td := GetTypeData(PTypeInfo(TypeInfo(T)));
  LResult.QueryInterface(td^.GUID, Result);
end;

end.