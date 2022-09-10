program fluent;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}
  cmem, cthreads,
  {$ENDIF}
  Command.Interfaces,
  Command.Builder,
  Command.Colors,
  Command.Usage,
  Command.Version;

{$R *.res}

procedure HelloCommand(ABuilder: ICommandBuilder);
begin
  WriteLn('Hello world!');
  if ABuilder.CheckOption('c') then
    WriteLn('You have used the -c option');
end;

begin
  TCommandBuilder
    .New('a sample project using fluent calls to build the commands')
    //.UseColorTheme(DarkColorTheme)
    .AddCommand('hello')
      .Description('Prints hello world')
      .CheckConstraints([ccRequiresOneOption])
        .AddOption('c', 'custom', 'custom option to change command behavior', [], ocNoValue)
      .OnExecute(HelloCommand)
    .AddCommand(Command.Usage.Registry)
    .AddCommand(Command.Version.Registry)
    .Run;
end.