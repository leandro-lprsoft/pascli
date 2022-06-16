unit TestCommandHelper;

{$MODE DELPHI}{$H+}

interface

uses
  Classes, 
  SysUtils, 
  fpcunit, 
  testutils, 
  testregistry,
  Command.Helpers;

type

  TTestCommandHelper = class(TTestCase)
  published
    procedure TestAppendToArray;
    procedure TestRemoveStartingDashes;
  end;

implementation

procedure TTestCommandHelper.TestAppendToArray;
var
  LArray: TArray<string> = [];
begin
  SetLength(LArray, 0);
  AppendToArray(LArray, 'new string');
  AssertEquals('String not added to array variable', 'new string', LArray[0]);
  AssertEquals('Array length should be 1', 1, Length(LArray));
end;

procedure TTestCommandHelper.TestRemoveStartingDashes;
begin
  AssertEquals('Remove first one dash not work.', 'd', RemoveStartingDashes('-d'));
  AssertEquals('Remove first two dashes not work.', 'debug', RemoveStartingDashes('--debug'));
  AssertEquals('Remove third dash.', '-d', RemoveStartingDashes('---d'));
  AssertEquals('Remove middle dashes.', 'debug-no-compile', RemoveStartingDashes('--debug-no-compile'));
end;

initialization
  RegisterTest(TTestCommandHelper);

end.

