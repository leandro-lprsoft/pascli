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
    procedure TestRegistryForCommandUsage;
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
  FApplication.CommandBuilder.Output := MockOutput;
  FExeName := ChangeFileExt(ExtractFileName(FApplication.ExeName), '');
  CapturedOutput := '';
end;

procedure TTestCommandUsage.TestWriteUsage;
begin
  // act
  WriteUsage(FApplication.CommandBuilder, '[app_title]', '[create]', '[-options]', '<file_name>');

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
    .CommandBuilder
      .AddCommand('help', 'display help for given command', MockCommand, [ccDefault])
      .SetCommandSelected(FApplication.CommandBuilder.Commands[0])
      .AddCommand('sample', 'execute sample action', MockCommand, [ccNoParameters])
      .SetCommandAsArgument(nil);

  // act
  UsageCommand(FApplication.CommandBuilder);

  // assert
  AssertTrue('should have "Commands:" text', ContainsText(CapturedOutput, 'Commands:'));
  AssertTrue('should have "for more information on a command" text', 
    ContainsText(CapturedOutput, 'for more information on a command'));
end;

procedure TTestCommandUsage.TestUsageCommandPathSpecificCommand;
begin
  // arrange
  FApplication
    .CommandBuilder
      .AddCommand('help', 'display help for given command', MockCommand, [ccDefault, ccNoArgumentsButCommands])
      .SetCommandSelected(FApplication.CommandBuilder.Commands[0])
      .AddCommand('sample', 'execute sample action', MockCommand, [ccNoParameters])
        .AddOption('a', 'a-option', 'first option')
      .SetCommandAsArgument(FApplication.CommandBuilder.Commands[1]);

  // act
  UsageCommand(FApplication.CommandBuilder);

  // assert
  AssertFalse('should have "Commands:" text', ContainsText(CapturedOutput, 'Commands:'));
  AssertTrue('should have "Options:" text', ContainsText(CapturedOutput, 'Options:'));
end;

procedure TTestCommandUsage.TestGetArgumentList;
var
  LArguments: string;
begin
  // arrange
  FApplication.CommandBuilder.AddArgument('project file name', acOptional);
  FApplication.CommandBuilder.AddArgument('run mode', acRequired);

  // act
  LArguments := GetArgumentList(FApplication.CommandBuilder);

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
    .CommandBuilder
      .AddCommand('help', 'display help for given command', MockCommand, [ccDefault])
      .SetCommandSelected(FApplication.CommandBuilder.Commands[0])
      .AddCommand('sample', 'execute sample action', MockCommand, [ccNoParameters])
      .SetCommandAsArgument(FApplication.CommandBuilder.Commands[1]);

  // act
  WriteCommandUsage(FApplication.CommandBuilder);

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
    .CommandBuilder
      .AddCommand('help', 'display help for given command', MockCommand, [ccDefault])
      .SetCommandSelected(FApplication.CommandBuilder.Commands[0])
      .AddCommand('sample', 'execute sample action', MockCommand, [ccNoParameters])
      .AddCommand('cmd_with_arg', 'command that requires an argument', MockCommand, [ccRequiresOneArgument])
      .SetCommandAsArgument(FApplication.CommandBuilder.Commands[2])
      .AddArgument('arg1', acOptional);

  // act
  WriteCommandUsage(FApplication.CommandBuilder);

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
    .CommandBuilder
      .AddCommand('help', 'display help for given command', MockCommand, [ccDefault])
      .SetCommandSelected(FApplication.CommandBuilder.Commands[0])
      .AddCommand('sample', 'execute sample action', MockCommand, [ccNoParameters])
      .AddCommand('cmd_with_opt', 'command that requires options', MockCommand, [ccRequiresOneOption])
        .AddOption('a', 'a-option', 'option A is nice', [])
        .AddOption('b', 'b-option', 'option B is better', [])
      .SetCommandAsArgument(FApplication.CommandBuilder.Commands[2]);

  // act
  WriteCommandUsage(FApplication.CommandBuilder);

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
    .CommandBuilder
      .AddCommand('help', 'display help for given command', MockCommand, [ccDefault])
      .SetCommandSelected(FApplication.CommandBuilder.Commands[0])
      .AddCommand('sample', 'execute sample action', MockCommand, [ccNoParameters])
      .AddCommand('cmd_with_opt', 'command that requires options', MockCommand, [ccRequiresOneOption])
        .AddOption('a', 'a-option', 'option A is nice', [])
        .AddOption('b', 'b-option', 'option B is better', [])
      .SetCommandAsArgument(FApplication.CommandBuilder.Commands[2])
      .AddArgument('arg1', acOptional);

  // act
  WriteCommandUsage(FApplication.CommandBuilder);

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
    .CommandBuilder
      .AddCommand('help', 'display help for given command', MockCommand, [ccDefault])
      .SetCommandSelected(FApplication.CommandBuilder.Commands[0])
      .AddCommand('sample_cmd', 'execute sample action', MockCommand, [ccNoParameters])
      .SetCommandAsArgument(nil);

  // act
  UsageCommand(FApplication.CommandBuilder);

  // assert
  AssertTrue('should have "Commands:" text', ContainsText(CapturedOutput, 'Commands:'));
  AssertTrue('should have "display help for given command" text ', 
    ContainsText(CapturedOutput, 'display help for given command'));
  AssertTrue('should have "sample_cmd" command text ', ContainsText(CapturedOutput, 'sample_cmd'));    
  AssertTrue('should have "for more information on a command" text', 
    ContainsText(CapturedOutput, 'for more information on a command'));  
end;

procedure TTestCommandUsage.TestRegistryForCommandUsage;
begin
  Command.Usage.Registry(FApplication.CommandBuilder);
  AssertEquals('Should have one registered command.', 1, Length(FApplication.CommandBuilder.Commands));
  AssertEquals('First builder command should be "help"', 'help', FApplication.CommandBuilder.Commands[0].Name);
end;

initialization
  RegisterTest(TTestCommandUsage);

end.