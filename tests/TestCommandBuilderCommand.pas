unit TestCommandBuilderCommand;

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

  TTestCommandBuilderCommand = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure AddOptionWithEmptyFlag;
  published
    procedure TestNewCommandBasic;
    procedure TestNewCommandWithOptions;
    procedure TestNewCommandAddOptionWithEmptyFlag;    
  end;

implementation

uses
  TestMockCommandBuilder;

procedure TTestCommandBuilderCommand.SetUp;
begin
end;

procedure TTestCommandBuilderCommand.TearDown;
begin
end;

procedure TTestCommandBuilderCommand.TestNewCommandBasic;
var
  LCommand: ICommand;
begin
  // arrange
  LCommand := TCommand.New('default', 'default command description', @MockCommand, [ccNoParameters]);

  // assert
  AssertEquals('Command should have name "default"', 'default', LCommand.Name);
  AssertEquals(
      'Command should have description <default command description>', 
      'default command description', 
      LCommand.Description);
  AssertTrue('Command should have constraint ccNoParameters', ccNoParameters in LCommand.Constraints);
  AssertEquals('Command should not have options', 0, Length(LCommand.Options));
end;

procedure TTestCommandBuilderCommand.TestNewCommandWithOptions;
var
  LCommand: ICommand;
  LFirstOption, LSecondOption: IOption;
begin
  // arrange
  LCommand := TCommand.New('default', 'default command description', @MockCommand, [ccNoParameters]);
  LFirstOption := LCommand.AddOption('f', 'first', 'first option', []);
  LSecondOption := LCommand.AddOption('s', 'second', 'second option', ['f']);
  
  // assert command
  AssertEquals('Command should return True from HasOptions function', True, LCommand.HasOptions);
  AssertEquals('Command should have 2 options', 2, Length(LCommand.Options));
  AssertTrue('Shoud not return an assigned option', not Assigned(LCommand.Option['not_exists']));
  AssertTrue('Shoud return assigned option', Assigned(LCommand.Option['first']));

  // assert first option
  AssertEquals(
    'First option must match first index on options command array', 
    LFirstOption.Name,
    LCommand.Options[0].Name);
  AssertEquals('First option shoud have flag "f"', 'f', LFirstOption.Flag);
  AssertEquals('First option shoud have long parameter "first"', 'first', LFirstOption.Name);

  // assert second option
  AssertEquals('Second option description should be "second option"', 'second option', LSecondOption.Description);
  AssertEquals(
    'Second option not allowed flags should have an item', 
    1, 
    Length(LSecondOption.NotAllowedFlags));
  AssertEquals(
    'Second option not allowed flags first item should be "f"',
    'f', 
    LSecondOption.NotAllowedFlags[0]);    
end;

procedure TTestCommandBuilderCommand.AddOptionWithEmptyFlag;
var
  LCommand: ICommand;
begin
  LCommand := TCommand.New('default', 'default command description', @MockCommand, [ccNoParameters]);
  LCommand.AddOption('', 'first', 'first option', []);
end;

procedure TTestCommandBuilderCommand.TestNewCommandAddOptionWithEmptyFlag;
begin
  // assert
  AssertException(
    'Should raise error preventing empty flag', 
    Exception,
    AddOptionWithEmptyFlag);
end;

initialization
  RegisterTest(TTestCommandBuilderCommand);

end.