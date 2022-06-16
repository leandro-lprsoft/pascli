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

var
  MockCommandCapture: string;

implementation

procedure MockCommand(ABuilder: ICommandBuilder);
begin  
  MockCommandCapture := 'executed';
end;

procedure TCommandBuildMock.HandleInvoke(aMethod: TRttiMethod; const aArgs: TValueArray; 
  out aResult: TValue);
begin
  FData.Add(aMethod.Name);
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