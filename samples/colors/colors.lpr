program colors;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}
  cmem, cthreads,
  {$ENDIF}
  Math,
  Command.Interfaces,
  Command.App,
  Command.Usage,
  Command.Version,
  Command.Colors;

var
  Application: TCommandApp;

{$R *.res}

procedure HelloCommand(ABuilder: ICommandBuilder);
var 
  LColor: Byte = White;
begin
  if ABuilder.CheckOption('r') then
    LColor := Red;
  if ABuilder.CheckOption('g') then
    LColor := IfThen(LColor = Red, Yellow, Green);
  ChangeConsoleColor(LColor);
  WriteLn('Hello world!');
end;

begin
  Application := TCommandApp.Create(nil);
  Application.Title := 'Basic CLI tool with colors.';

  Application.CommandBuilder.ColorTheme := DarkColorTheme;

  Command.Usage.Registry(Application.CommandBuilder);
  Command.Version.Registry(Application.CommandBuilder);
  
  Application
    .CommandBuilder
      .AddCommand(
        'hello',
        'Show a hello world message.'#13#10 +
        'Ex: colors hello --green',
        @HelloCommand,
        [])
        .AddOption('r', 'red', 'shows hello world in red.', [])
        .AddOption('g', 'green', 'shows hello world in green.', [])
      .AddCommand(
        'palette',
        'Outputs a color palette with options that can be used on ChangeConsoleColor procedure'#13#10 +
        'Ex: colors palette',
        @OutputPalleteColor,
        [ccNoParameters]
      );

  Application.Run;
  Application.Free;
end.