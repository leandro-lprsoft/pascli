program TestPascli;

{$MODE DELPHI}{$H+}

uses
  Classes, 
  ConsoleTestRunner, 
  TestCommandHelper,
  TestCommandApp,
  TestCommandUsage,
  TestCommandVersion,
  TestCommandValidator,
  TestCommandBuilderOption,
  TestCommandBuilderArgument,
  TestCommandBuilderCommand,
  TestCommandBuilder, 
  TestMockCommandBuilder;

type
  TTestPascli = class(TTestRunner)
  end;

var
  Application: TTestPascli;

{$R *.res}

begin
  Application := TTestPascli.Create(nil);
  Application.Initialize;
  Application.Title := 'TestPascli console test runner';
  Application.Run;
  Application.Free;
end.