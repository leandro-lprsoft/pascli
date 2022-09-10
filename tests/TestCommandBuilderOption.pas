unit TestCommandBuilderOption;

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

  TTestCommandBuilderOption = class(TTestCase)
  private
    procedure NewOptionWithInvalidNotAllowedFlag;
  published
    procedure TestNewOptionBasic;
    procedure TestNewOptionWithConstraint;
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
  AssertEquals(Ord(LOption.Constraint), Ord(ocNoValue));
end;

procedure TTestCommandBuilderOption.TestNewOptionWithConstraint;
var
  LOption: IOption;
begin
  LOption := TOption.New('a', 'activate', 'start the application', ['b'], ocRequiresValue);
  AssertEquals(Ord(LOption.Constraint), Ord(ocRequiresValue));
end;

procedure TTestCommandBuilderOption.NewOptionWithInvalidNotAllowedFlag;
begin
  TOption.New('a', 'activate', 'start the application', ['not_a_flag']);
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