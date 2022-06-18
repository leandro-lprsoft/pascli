program basic;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}
  cmem, cthreads,
  {$ENDIF}
  Command.Interfaces,
  Command.App,
  Command.Usage,
  Command.Version;

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

  Command.Usage.Registry(Application.CommandBuilder);
  Command.Version.Registry(Application.CommandBuilder);

  Application
    .CommandBuilder
      .AddCommand(
        'hello',
        'Show a hello world message.'#13#10 +
        'Ex: basic hello',
        @HelloCommand,
        [ccNoParameters]);

  Application.Run;
  Application.Free;
end.