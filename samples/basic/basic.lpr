program basic;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}
  cmem, cthreads,
  {$ENDIF}
  Command.Interfaces,
  Command.App,
  Command.Usage;

var
  Application: TCommandApp;

{$R *.res}

procedure HelloCommand(ABuilder: ICommandBuilder);
begin
  WriteLn('Hello world!');
end;

begin
  Application := TCommandApp.Create(nil);
  Application.Title := 'Basic CLI tool.';
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
          [ccNoParameters]);

  Application.Run;
  Application.Free;
end.