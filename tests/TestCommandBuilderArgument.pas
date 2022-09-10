unit TestCommandBuilderArgument;

{$MODE DELPHI}{$H+}

interface

uses
  Classes, 
  SysUtils, 
  fpcunit, 
  testregistry,
  Command.Interfaces,
  Command.Builder;

type

  TTestCommandBuilderArgument = class(TTestCase)
  published
    procedure TestNewArgumentBasic;
  end;

implementation

procedure TTestCommandBuilderArgument.TestNewArgumentBasic;
var
  LArgument: IArgument;
begin
  LArgument := TArgument.New('file name', acRequired);

  AssertEquals('file name', LArgument.Description);
  AssertTrue('Argument constrain shoud be acRequired', LArgument.Constraint = acRequired);
end;

initialization
  RegisterTest(TTestCommandBuilderArgument);

end.