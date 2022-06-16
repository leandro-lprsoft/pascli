unit TestCommandApp;

{$MODE DELPHI}{$H+}

interface

uses
  Classes, 
  SysUtils, 
  fpcunit, 
  testutils, 
  testregistry,
  Command.App,
  Command.Interfaces,
  Command.Usage;

type

  TTestCommandApp = class(TTestCase)
  private
    FApplication: TCommandApp;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAppHasValidCommandBuilderInstance;
    procedure TestAppBasicUsage;
  end;

implementation

uses
  TestMockCommandBuilder;

procedure TTestCommandApp.TestAppBasicUsage;
var
  LCommand: ICommandBuilder;
  LInvokedMethods: TStringList;
begin
  LInvokedMethods := TStringList.Create;
  try
    LCommand := TCommandBuildMock.New<ICommandBuilder>(LInvokedMethods);
    FApplication.Command := LCommand;
    FApplication.Initialize;
    FApplication.Run;
    AssertEquals('Parse method should be invoked', 'Parse', LInvokedMethods[0]);
    AssertEquals('Validate method should be invoked', 'Validate', LInvokedMethods[1]);
    AssertEquals('Execute method should be invoked', 'Execute', LInvokedMethods[2]);
  finally
    LInvokedMethods.Free;
  end;
end;

procedure TTestCommandApp.SetUp;
begin
  FApplication := TCommandApp.Create(nil);
  FApplication.Title := 'basic app';
end;

procedure TTestCommandApp.TearDown;
begin
  FApplication.Free;
end;

procedure TTestCommandApp.TestAppHasValidCommandBuilderInstance;
begin
  AssertTrue(
    'Application should have valid ICommandBuilder instance. Check create method.', 
    Assigned(FApplication.Command))  
end;

initialization
  RegisterTest(TTestCommandApp);

end.