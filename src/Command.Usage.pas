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
  ABuilder.Output(
    Format(#13#10'Usage: %s %s%s%s'#13#10, [
      ATitle, 
      ACommand, 
      AOptions, 
      AArgument]
  ));
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

  ABuilder.Output('Commands: ');
  
  for LCommand in ABuilder.Commands do
    ABuilder.Output(Format('  %s%s', [
      PadRight(LCommand.Name, 15),
      StringReplace(LCommand.Description, #13#10, #13#10 + PadLeft('', 17), [rfReplaceAll])
    ]));

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

  ABuilder.Output(ABuilder.CommandAsArgument.Description);
  ABuilder.Output('');

  if ABuilder.CommandAsArgument.HasOptions then
  begin
    ABuilder.Output('Options: ');

    for LOption in ABuilder.CommandAsArgument.Options do
      ABuilder.Output(Format('  %s%s%s', [
        PadRight('-' + LOption.Flag + ',', 4),
        PadRight('--' + LOption.Name, 20),
        StringReplace(LOption.Description, #13#10, #13#10 + PadLeft('', 30), [rfReplaceAll])
      ]));  

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