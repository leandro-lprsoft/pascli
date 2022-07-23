program TestPascli;

{$MODE DELPHI}{$H+}

uses
  Classes, 
  SysUtils,
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
  HeapFileName: string;

{$R *.res}

begin
  {$IF DECLARED(UseHeapTrace)}
  HeapFileName := ConcatPaths([ExtractFilePath(ParamStr(0)), 'heap.trc']);
  if FileExists(HeapFileName) then
    DeleteFile(HeapFileName);
  SetHeapTraceOutput(HeapFileName);
  {$ENDIF}
  Application := TTestPascli.Create(nil);
  Application.Initialize;
  Application.Title := 'TestPascli console test runner';
  Application.Run;
  Application.Free;
end.