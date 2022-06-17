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
  LOptions: TArray<IOption>;
  LOption: IOption;

  function GetFirstArgumentValue(AArguments: TArray<IArgument>): string;
  var
    LArgument: IArgument;
  begin
    Result := 'no arguments';
    for LArgument in AArguments do
      Exit(LArgument.Value);
  end;

begin
  LOptions := ABuilder.GetParsedOptions;
  for LOption in LOptions do
  begin
    if AnsiMatchText(LOption.Flag, ['a', 'alternative']) then
      LOutPut := LOutput + #13#10'Hi world!';
    if AnsiMatchText(LOption.Flag, ['s', 'show-arg']) then
      LOutPut := LOutput + #13#10'Hi ' + GetFirstArgumentValue(ABuilder.GetParsedArguments);
  end;
  WriteLn(LOutput);
end;

begin
  Application := TCommandApp.Create(nil);
  Application.Title := 'CLI tool using pascli with commands and options.';
  Application
    .Command
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
      .AddArgument('argument parameter', acOptional);

  Application.Run;
  Application.Free;
end.