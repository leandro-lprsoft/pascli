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
    procedure Setup; override;
    procedure TearDown; override;
  published
    procedure TestAppHasValidCommandBuilderInstance;
    procedure TestAppBasicUsage;
    procedure TestAppTitle;
  end;

implementation

uses
  TestMockCommandBuilder;

procedure TTestCommandApp.TestAppBasicUsage;
var
  LCommand: ICommandBuilder = nil;
  LInvokedMethods: TStringList = nil;
begin
  {$IFDEF WINDOWS}
  LInvokedMethods := TStringList.Create;
  try
    LCommand := TCommandBuildMock.New<ICommandBuilder>(LInvokedMethods);
    FApplication.CommandBuilder := LCommand;
    FApplication.Initialize;
    FApplication.Run;
    AssertTrue('Should have at least one invoked method.', LInvokedMethods.Count > 0);
    AssertEquals('Parse method should be invoked', 'Parse', LInvokedMethods[1]);
    AssertTrue('Should have at least two invoked methods.', LInvokedMethods.Count > 1);
    AssertEquals('Validate method should be invoked', 'Validate', LInvokedMethods[2]);
    AssertTrue('Should have at least three invoked methods.', LInvokedMethods.Count > 2);
    AssertEquals('Execute method should be invoked', 'Execute', LInvokedMethods[3]);
  finally
    LInvokedMethods.Free;
  end;
  {$ENDIF}
end;

procedure TTestCommandApp.TestAppHasValidCommandBuilderInstance;
begin
  AssertTrue(
    'Application should have valid ICommandBuilder instance. Check create method.', 
    Assigned(FApplication.CommandBuilder));
end;

procedure TTestCommandApp.Setup;
begin
  FApplication := TCommandApp.Create(nil);
  FApplication.Title := 'basic app';  
end;

procedure TTestCommandApp.TearDown;
begin
  FApplication.Free;  
end;

procedure TTestCommandApp.TestAppTitle;
begin
  FApplication.Run;
  AssertEquals(FApplication.Title, FApplication.CommandBuilder.Title);
end;

initialization
  RegisterTest(TTestCommandApp);

end.