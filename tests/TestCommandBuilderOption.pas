unit TestCommandBuilderOption;

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
  Command.Builder;

type

  TTestCommandBuilderOption = class(TTestCase)
  private
    FApplication: TCommandApp;

    procedure NewOptionWithInvalidNotAllowedFlag;
  published
    procedure TestNewOptionBasic;
    procedure TestNewOptionWithInvalidNotAllowedFlag;
  end;

implementation

procedure TTestCommandBuilderOption.TestNewOptionBasic;
var
  LOption: IOption;
begin
  LOption := TOption.New('a', 'activate', 'start the application', ['b']);

  AssertEquals(LOption.Flag, 'a');
  AssertEquals(LOption.Name, 'activate');
  AssertEquals(LOption.Description, 'start the application');
  AssertEquals(Length(LOption.NotAllowedFlags), 1);
end;


procedure TTestCommandBuilderOption.NewOptionWithInvalidNotAllowedFlag;
var
  LOption: IOption;
begin
  LOption := TOption.New('a', 'activate', 'start the application', ['not_a_flag']);
end;

procedure TTestCommandBuilderOption.TestNewOptionWithInvalidNotAllowedFlag;
begin
  AssertException(
      'Should raise error when not using a flag for NotAllowedFlags param array.', 
      Exception,
      NewOptionWithInvalidNotAllowedFlag,
      'Not allowed option "not_a_flag" invalid for Command "--activate". Only flags should be used.');
end;

initialization
  RegisterTest(TTestCommandBuilderOption);

end.