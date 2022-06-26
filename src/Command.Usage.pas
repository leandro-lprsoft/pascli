unit Command.Usage;

{$MODE DELPHI}{$H+}

interface

uses
  SysUtils,
  StrUtils,
  Command.Interfaces;

  /// prints text describing command usage according to commands, options and arguments defined
  /// using application command builder
  procedure UsageCommand(ABuilder: ICommandBuilder);

  /// returns a argument list using command builder definition
  function GetArgumentList(ABuilder: ICommandBuilder): string;

  /// prints simple usage command using provided parameters
  procedure WriteUsage(ABuilder: ICommandBuilder; const ATitle, ACommand, AOptions, AArgument: string);

  // prints help information for a specific command set on property Command Builder.CommandAsArgument 
  procedure WriteCommandUsage(ABuilder: ICommandBuilder);

  /// prints general help information for the application, including command usage syntax, command list
  /// and arguments.
  procedure WriteGeneralUsage(ABuilder: ICommandBuilder);

  /// configure UsageCommand with standard parameters
  procedure Registry(ABuilder: ICommandBuilder);

implementation

uses
  Command.Builder,
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
begin
  LArguments := GetArgumentList(ABuilder);

  WriteUsage(
    ABuilder,
    ABuilder.ExeName, 
    IfThen(ABuilder.HasCommands, '[command] ', ''), 
    IfThen(ABuilder.HasOptions, '[options] ', ''), 
    LArguments);

  ABuilder.Output('');
  ABuilder.OutputColor('Commands: '#13#10, ABuilder.ColorTheme.Title);
  
  for LCommand in ABuilder.Commands do
  begin
    ABuilder.OutputColor('  ' + PadRight(LCommand.Name, 15), ABuilder.ColorTheme.Value);
    ABuilder.OutputColor(
      StringReplace(LCommand.Description, #13#10, #13#10 + PadLeft('', 17), [rfReplaceAll]), 
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
  LOption: IOption;
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
      ABuilder.OutputColor(
        Format('  %s%s', [
          PadRight('-' + LOption.Flag + ',', 4),
          PadRight('--' + LOption.Name, 20)
          ]), 
        ABuilder.ColorTheme.Value);  

      ABuilder.OutputColor(
        StringReplace(LOption.Description, #13#10, #13#10 + PadLeft('', 30), [rfReplaceAll]) + #13#10,
        ABuilder.ColorTheme.Other);

    end;

    ABuilder.Output('');
  end;
  
end;

procedure UsageCommand(ABuilder: ICommandBuilder);
begin
  if Assigned(ABuilder.CommandAsArgument) then 
    WriteCommandUsage(ABuilder)
  else  
    WriteGeneralUsage(ABuilder);
end;

procedure Registry(ABuilder: ICommandBuilder);
begin
  ABuilder
  .AddCommand(
    'help', 
    'Shows information about how to use this tool or about a specific command.'#13#10 +
    'Ex: ' + ABuilder.ExeName + ' help', 
    @UsageCommand,
    [ccDefault, ccNoArgumentsButCommands]);
end;

end.