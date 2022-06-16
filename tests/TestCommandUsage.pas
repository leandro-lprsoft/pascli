unit TestCommandUsage;

{$MODE DELPHI}{$H+}

interface

uses
  Classes, 
  SysUtils, 
  fpcunit, 
  testutils, 
  testregistry,
  Command.Interfaces,
  Command.App,
  Command.Usage,
  Command.Builder;

type

  TTestCommandUsage = class(TTestCase)
  private
    FApplication: TCommandApp;
    FExeName: string;
  protected
    procedure Setup; override;
  published
    procedure TestWriteUsage;
    procedure TestUsageCommandPathGeneral;
    procedure TestUsageCommandPathSpecificCommand;
    procedure TestGetArgumentList;
    procedure TestWriteCommandUsage;
    procedure TestWriteCommandUsageWithArgument;
    procedure TestWriteCommandUsageWithOption;
    procedure TestWriteCommandUsageWithArgumentAndOption;
    procedure TestWriteGeneralUsage;
  end;

implementation

uses
  TestMockCommandBuilder,
  StrUtils;

var
  CapturedOutput: string;

procedure MockOutput(const AMessage: string);
begin
  CapturedOutput := CapturedOutput + AMessage + #13#10;
end;

procedure TTestCommandUsage.SetUp;
begin
  FApplication := TCommandApp.Create(nil);
  FApplication.Title := 'testcmdapp';
  FApplication.Command.Output := MockOutput;
  FExeName := ExtractFileName(FApplication.ExeName);
  CapturedOutput := '';
end;

procedure TTestCommandUsage.TestWriteUsage;
begin
  // act
  WriteUsage(FApplication.Command, '[app_title]', '[create]', '[-options]', '<file_name>');

  // assert
  AssertTrue('Should print app title', ContainsText(CapturedOutput, 'app_title'));
  AssertTrue('Should print command', ContainsText(CapturedOutput, 'create'));
  AssertTrue('Should print options', ContainsText(CapturedOutput, '-options'));
  AssertTrue('Should print argument', ContainsText(CapturedOutput, 'file_name'));
end;

procedure TTestCommandUsage.TestUsageCommandPathGeneral;
begin
  // arrange
  FApplication
    .Command
      .AddCommand('help', 'display help for given command', MockCommand, [ccDefault])
      .SetCommandSelected(FApplication.Command.Commands[0])
      .AddCommand('sample', 'execute sample action', MockCommand, [ccNoParameters])
      .SetCommandAsArgument(nil);

  // act
  UsageCommand(FApplication.Command);

  // assert
  AssertTrue('should have "Commands:" text', ContainsText(CapturedOutput, 'Commands:'));
  AssertTrue('should have "for more information on a command" text', 
    ContainsText(CapturedOutput, 'for more information on a command'));
end;

procedure TTestCommandUsage.TestUsageCommandPathSpecificCommand;
begin
  // arrange
  FApplication
    .Command
      .AddCommand('help', 'display help for given command', MockCommand, [ccDefault, ccNoArgumentsButCommands])
      .SetCommandSelected(FApplication.Command.Commands[0])
      .AddCommand('sample', 'execute sample action', MockCommand, [ccNoParameters])
        .AddOption('a', 'a-option', 'first option')
      .SetCommandAsArgument(FApplication.Command.Commands[1]);

  // act
  UsageCommand(FApplication.Command);

  // assert
  AssertFalse('should have "Commands:" text', ContainsText(CapturedOutput, 'Commands:'));
  AssertTrue('should have "Options:" text', ContainsText(CapturedOutput, 'Options:'));
end;

procedure TTestCommandUsage.TestGetArgumentList;
var
  LArguments: string;
begin
  // arrange
  FApplication.Command.AddArgument('project file name', acOptional);
  FApplication.Command.AddArgument('run mode', acRequired);

  // act
  LArguments := GetArgumentList(FApplication.Command);

  // assert
  AssertTrue('Should contain project argument', ContainsText(LArguments, 'project file name'));
  AssertTrue('Should contain run mode argument', ContainsText(LArguments, 'run mode'));
end;

procedure TTestCommandUsage.TestWriteCommandUsage;
var
  LExpectUsage, LExpectDesc: string;
begin
  // arrange
  FApplication
    .Command
      .AddCommand('help', 'display help for given command', MockCommand, [ccDefault])
      .SetCommandSelected(FApplication.Command.Commands[0])
      .AddCommand('sample', 'execute sample action', MockCommand, [ccNoParameters])
      .SetCommandAsArgument(FApplication.Command.Commands[1]);

  // act
  WriteCommandUsage(FApplication.Command);

  // asserts
  LExpectUsage := Format('Usage: %s %s', [FExeName, 'sample']);
  LExpectDesc := 'execute sample action';

  AssertTrue('Should have usage instruction for the command', ContainsText(CapturedOutput, LExpectUsage));
  AssertTrue('Should have description for the command', ContainsText(CapturedOutput, LExpectDesc));
end;

procedure TTestCommandUsage.TestWriteCommandUsageWithArgument;
var
  LExpectUsage, LExpectDesc: string;
begin
  // arrange
  FApplication
    .Command
      .AddCommand('help', 'display help for given command', MockCommand, [ccDefault])
      .SetCommandSelected(FApplication.Command.Commands[0])
      .AddCommand('sample', 'execute sample action', MockCommand, [ccNoParameters])
      .AddCommand('cmd_with_arg', 'command that requires an argument', MockCommand, [ccRequiresOneArgument])
      .SetCommandAsArgument(FApplication.Command.Commands[2])
      .AddArgument('arg1', acOptional);

  // act
  WriteCommandUsage(FApplication.Command);

  // asserts
  LExpectUsage := Format('Usage: %s %s <%s>', [FExeName, 'cmd_with_arg', 'arg1']);
  LExpectDesc := 'command that requires an argument';

  AssertTrue('Should have usage instruction for the command with <argument>', 
    ContainsText(CapturedOutput, LExpectUsage));
  AssertTrue('Should have description for the command', ContainsText(CapturedOutput, LExpectDesc));
end;

procedure TTestCommandUsage.TestWriteCommandUsageWithOption;
var
  LExpectUsage, LExpectDesc: string;
begin
  // arrange
  FApplication
    .Command
      .AddCommand('help', 'display help for given command', MockCommand, [ccDefault])
      .SetCommandSelected(FApplication.Command.Commands[0])
      .AddCommand('sample', 'execute sample action', MockCommand, [ccNoParameters])
      .AddCommand('cmd_with_opt', 'command that requires options', MockCommand, [ccRequiresOneOption])
        .AddOption('a', 'a-option', 'option A is nice', [])
        .AddOption('b', 'b-option', 'option B is better', [])
      .SetCommandAsArgument(FApplication.Command.Commands[2]);

  // act
  WriteCommandUsage(FApplication.Command);

  // asserts
  LExpectUsage := Format('Usage: %s %s [%s]', [FExeName, 'cmd_with_opt', 'options']);
  LExpectDesc := 'command that requires options';

  AssertTrue('Should have usage instruction for the command with [options]', 
    ContainsText(CapturedOutput, LExpectUsage));
  AssertTrue('Should text "option A is nice"', ContainsText(CapturedOutput, 'option A is nice'));
  AssertTrue('Should text "--b-option"', ContainsText(CapturedOutput, '--b-option'));
end;

procedure TTestCommandUsage.TestWriteCommandUsageWithArgumentAndOption;
var
  LExpectUsage, LExpectDesc: string;
begin
  // arrange
  FApplication
    .Command
      .AddCommand('help', 'display help for given command', MockCommand, [ccDefault])
      .SetCommandSelected(FApplication.Command.Commands[0])
      .AddCommand('sample', 'execute sample action', MockCommand, [ccNoParameters])
      .AddCommand('cmd_with_opt', 'command that requires options', MockCommand, [ccRequiresOneOption])
        .AddOption('a', 'a-option', 'option A is nice', [])
        .AddOption('b', 'b-option', 'option B is better', [])
      .SetCommandAsArgument(FApplication.Command.Commands[2])
      .AddArgument('arg1', acOptional);

  // act
  WriteCommandUsage(FApplication.Command);

  // asserts
  LExpectUsage := Format('Usage: %s %s [%s] <%s>', [FExeName, 'cmd_with_opt', 'options', 'arg1']);
  LExpectDesc := 'command that requires options';

  AssertTrue('Should have usage instruction for the command with [options]', 
    ContainsText(CapturedOutput, LExpectUsage));
  AssertTrue('Should text "option A is nice"', ContainsText(CapturedOutput, 'option A is nice'));
  AssertTrue('Should text "--b-option"', ContainsText(CapturedOutput, '--b-option'));
  
end;

procedure TTestCommandUsage.TestWriteGeneralUsage;
begin
  // arrange
  FApplication
    .Command
      .AddCommand('help', 'display help for given command', MockCommand, [ccDefault])
      .SetCommandSelected(FApplication.Command.Commands[0])
      .AddCommand('sample_cmd', 'execute sample action', MockCommand, [ccNoParameters])
      .SetCommandAsArgument(nil);

  // act
  UsageCommand(FApplication.Command);

  // assert
  AssertTrue('should have "Commands:" text', ContainsText(CapturedOutput, 'Commands:'));
  AssertTrue('should have "display help for given command" text ', 
    ContainsText(CapturedOutput, 'display help for given command'));
  AssertTrue('should have "sample_cmd" command text ', ContainsText(CapturedOutput, 'sample_cmd'));    
  AssertTrue('should have "for more information on a command" text', 
    ContainsText(CapturedOutput, 'for more information on a command'));  
end;

initialization
  RegisterTest(TTestCommandUsage);

end.