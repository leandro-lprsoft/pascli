/// <summary> This unit contains functions to display information on how to use the arguments, 
/// commands and options configured in @link(TCommandBuilder). Its main command is the UsageCommand which 
/// is prepared to provide usage information to the user. To use this procedure, just configure it 
/// using @link(TCommandBuilder.AddCommand) method or simply call the @link(Registry) function of this unit
/// to do that. 
/// </summary>
unit Command.Usage;

{$MODE DELPHI}{$H+}

interface

uses
  SysUtils,
  StrUtils,
  Command.Interfaces;

  /// <summary> Outputs text describing command usage according to commands, options and arguments 
  /// configured using application command builder. If a different color theme is specified to the
  /// @link(TCommandBuilder.ColorTheme), this command displays the usage info in different colors.
  /// </summary>
  /// If a given command needs another command as a parameter (for example help command).This command
  /// should be configured using @link(ccNoArgumentsButCommands) constraint allowing another command 
  /// to be passed as parameter to UsageCommand.
  ///
  /// To use this command, just add the Command.Usage to the uses clause:
  /// @longCode(
  /// uses Command.Usage;)
  /// And call @link(Registry) procedure to add this command to the builder:
  /// Ex:
  /// @longCode(
  /// Command.Usage.Registry(MyApp.CommandBuilder);
  /// )
  /// or you can use the overloaded version of AddCommand to add the command to the builder using fluent interface:
  /// @longCode(
  ///   MyBuilder
  ///     .AddCommand(Command.Usage.Registry);
  /// )
  /// or customize your own configuration:
  /// @longCode(
  /// MyApp.CommandBuilder
  ///   .AddCommand(
  ///     'help', 
  ///     'Shows information about how to use this tool or about a specific command.' + #13#10 +
  ///     'Ex: ' + ABuilder.ExeName + ' help', 
  ///     @UsageCommand,
  ///     [ccDefault, ccNoArgumentsButCommands]);
  /// )
  /// <param name="ABuilder"> Instance of CommandBuilder from which the settings will be read to show
  /// usage information via the command line. </param>
  procedure UsageCommand(ABuilder: ICommandBuilder);

  /// <summary> Returns an argument list configured for CommandBuilder as a simple string. It will be
  /// used to display argument usage info to the user. </summary>
  /// <param name="ABuilder"> Instance of CommandBuilder from which data will be read.</param>
  function GetArgumentList(ABuilder: ICommandBuilder): string;

  /// <summary> Outputs simple usage command using provided parameters for the command provided. Display
  /// the usage in the following format 'EXECUTABLE [command] [options]'.
  /// </summary>
  /// <param name="ABuilder"> Instance of CommandBuilder that will be used to output info through
  /// its configured callback procedure. </param>
  /// <param name="ATitle"> Application title </param>
  /// <param name="ACommand"> Command name </param>
  /// <param name="AOptions"> Options list </param>
  /// <param name="AArgument"> Argument description </param>
  procedure WriteUsage(ABuilder: ICommandBuilder; const ATitle, ACommand, AOptions, AArgument: string);

  /// <summary> Outputs full usage information for a specific command. It´s used when the user
  /// requests help for a specific command.</summary>
  /// <param name="ABuilder"> Instance of CommandBuilder that will be used to output info through
  /// its configured callback procedure. </param>  
  procedure WriteCommandUsage(ABuilder: ICommandBuilder);

  /// <summary> Outputs general help information for the application, including command usage syntax, 
  /// command list, command description, arguments that are acceptable. Also displays application title 
  /// and version information. </summary>
  /// <param name="ABuilder"> Instance of CommandBuilder that will be used to output info through
  /// its configured callback procedure. </param>  
  procedure WriteGeneralUsage(ABuilder: ICommandBuilder);

  /// <summary> Configure UsageCommand with standard parameters.</summary>
  ///
  /// Ex:
  /// @longCode(
  /// Command.Usage.Registry(MyApp.CommandBuilder);
  /// )
  /// Ex with fluent interface:
  /// @longCode(
  ///   Builder.AddCommand(Command.Usage.Registry);
  /// )
  /// <param name="ABuilder"> CommandBuilder instance that will be used to register the UsageCommand.
  /// </param>  
  function Registry(ABuilder: ICommandBuilder): Boolean;

implementation

uses
  Command.Colors,
  Command.Version;

function GetArgumentList(ABuilder: ICommandBuilder): string;
var
  LArgument: IArgument;
begin
  Result := '';
  for LArgument in ABuilder.Arguments do
    Result := IfThen(Result = '', '', Result + ' ') + '<' + LArgument.Description + '>';
end;

procedure WriteUsage(ABuilder: ICommandBuilder; const ATitle, ACommand, AOptions, AArgument: string);
begin
  VersionCommand(ABuilder);

  ABuilder.OutputColor(#13#10'Usage: ', ABuilder.ColorTheme.Title);

  ABuilder.OutputColor(
    Format('%s %s%s', [ATitle, ACommand, AOptions]),
    ABuilder.ColorTheme.Value);

  ABuilder.OutputColor(AArgument + #13#10, ABuilder.ColorTheme.Value);
end;

procedure WriteGeneralUsage(ABuilder: ICommandBuilder);
var
  LCommand: ICommand;
  LArguments: string = '';
  LDescription, LLine: string;
begin
  LArguments := GetArgumentList(ABuilder);

  WriteUsage(
    ABuilder,
    ABuilder.ExeName, 
    IfThen(ABuilder.HasCommands, '[command] ', ''), 
    IfThen(ABuilder.HasOptions, '[options] ', ''), 
    LArguments);

  ABuilder.Output('');
  ABuilder.OutputColor(ABuilder.Title + #13#10, ABuilder.ColorTheme.Other);

  ABuilder.Output('');
  ABuilder.OutputColor('Commands: '#13#10, ABuilder.ColorTheme.Title);
  
  for LCommand in ABuilder.Commands do
  begin
    ABuilder.OutputColor('  ' + PadRight(LCommand.Name, 15), ABuilder.ColorTheme.Value);

    LDescription := LCommand.Description;
    if ABuilder.UseShortDescriptions then
      for LLine in LDescription.Split(#13#10) do
        if LLine <> '' then
        begin
          LDescription := LLine;
          break;
        end;

    ABuilder.OutputColor(
      StringReplace(LDescription, #13#10, #13#10 + PadLeft('', 17), [rfReplaceAll]), 
      ABuilder.ColorTheme.Other);
    ABuilder.Output('');
  end;

  ABuilder.Output('');
  ABuilder.Output(
    Format('Run ''%s help COMMAND'' for more information on a command.', [
    ABuilder.ExeName
    ]));
  ABuilder.Output('');
end;

procedure WriteCommandUsage(ABuilder: ICommandBuilder);
var
  LArguments: string = '';
  LOptionValue: string;
  LOption: IOption;
  LOptionConstraint: boolean = false;
begin
  LArguments := GetArgumentList(ABuilder);

  if not Assigned(ABuilder.CommandAsArgument) then
    Exit;

  if ccNoParameters in ABuilder.CommandAsArgument.Constraints then
    LArguments := '';

  if ccNoArgumentsButCommands in ABuilder.CommandAsArgument.Constraints then
    LArguments := '[COMMAND]';

  WriteUsage(
    ABuilder,
    ABuilder.ExeName, 
    ABuilder.CommandAsArgument.Name + ' ', 
    IfThen(ABuilder.CommandAsArgument.HasOptions, '[options] ', ''), 
    LArguments);

  ABuilder.Output('');
  ABuilder.OutputColor(ABuilder.CommandAsArgument.Description + #13#10, ABuilder.ColorTheme.Other);
  ABuilder.Output('');

  if ABuilder.CommandAsArgument.HasOptions then
  begin
    ABuilder.OutputColor('Options: ' + #13#10, ABuilder.ColorTheme.Title);

    for LOption in ABuilder.CommandAsArgument.Options do
    begin
      LOptionValue := '';
      if LOption.Constraint in [ocRequiresValue, ocOptionalValue] then
      begin
        LOptionValue := IfThen(LOption.Constraint = ocRequiresValue, '=*', '=?') ;
        LOptionConstraint := True;
      end;

      ABuilder.OutputColor(
        Format('  %s%s', [
          PadRight('-' + LOption.Flag + ',', 4),
          PadRight('--' + LOption.Name + LOptionValue, 20)
          ]), 
        ABuilder.ColorTheme.Value);  

      ABuilder.OutputColor(
        StringReplace(LOption.Description, #13#10, #13#10 + PadLeft('', 26), [rfReplaceAll]) + #13#10,
        ABuilder.ColorTheme.Other);
    end;
    ABuilder.Output('');

    if LOptionConstraint then
    begin
      ABuilder.OutputColor('  * Requires a value.'+#13#10, ABuilder.ColorTheme.Value);
      ABuilder.OutputColor('  ? Accepts a value, but it is optional.'+#13#10, ABuilder.ColorTheme.Value);
    end;
  end;
end;

procedure UsageCommand(ABuilder: ICommandBuilder);
begin
  if Assigned(ABuilder.CommandAsArgument) then 
    WriteCommandUsage(ABuilder)
  else  
    WriteGeneralUsage(ABuilder);
end;

function Registry(ABuilder: ICommandBuilder): Boolean;
begin
  ABuilder
    .AddCommand('help')
      .Description(
        'Shows information about how to use this tool or about a specific command.'#13#10 +
        'Ex: ' + ABuilder.ExeName + ' help')
      .CheckConstraints([ccDefault, ccNoArgumentsButCommands])
      .OnExecute(@UsageCommand);
  Result := True;
end;

end.