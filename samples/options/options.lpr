program options;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}
  cmem, cthreads,
  {$ENDIF}
  StrUtils,
  Command.Interfaces,
  Command.App,
  Command.Usage;

var
  Application: TCommandApp;

{$R *.res}

procedure HelloCommand(ABuilder: ICommandBuilder);
var
  LOutput: string = 'Hello World!';
  LValue: string;

  function GetFirstArgumentValue: string;
  begin
    Result := 'no arguments';
    if Length(ABuilder.GetParsedArguments) > 0 then
      Result := ABuilder.GetParsedArguments[0].Value;
  end;

begin
  if ABuilder.CheckOption('alternative') then
    LOutPut := LOutput + #13#10'Hi world!';

  if ABuilder.CheckOption('s') then
    LOutPut := LOutput + #13#10'Hi ' + GetFirstArgumentValue;

  if ABuilder.CheckOption('n', LValue) then
    LOutPut := LOutput + #13#10'Hi ' + LValue;

  WriteLn(LOutput);
end;

begin
  Application := TCommandApp.Create(nil);
  Application.Title := 'CLI tool using pascli with commands and options.';
  Application.CommandBuilder.UseShortDescriptions := True;
  Application
    .CommandBuilder
      .AddCommand(
        'help', 
        'Shows information about how to use this tool or about a specific command.'#13#10 +
        'Ex: basic help', 
        @UsageCommand, 
        [ccDefault, ccNoArgumentsButCommands])
      .AddCommand(
        'hello',
        'Show a hello world message.'#13#10 +
        'Ex: basic hello',
        @HelloCommand,
        [ccRequiresOneArgument, ccRequiresOneOption])
          .AddOption('a', 'alternative', 'display an alternative Hello World', [])
          .AddOption('s', 'show-arg', 'display Hello World and argument parameter value', [])
          .AddOption('n', 'show-name', 'display Hello World with the value of the option', [], ocRequiresValue)
      .AddArgument('argument parameter', acOptional);

  Application.Run;
  Application.Free;
end.