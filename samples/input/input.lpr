program input;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}
  cmem, cthreads,
  {$ENDIF}
  StrUtils,
  Command.Interfaces,
  Command.App,
  Command.Colors,
  Command.Usage,
  Command.Version;

var
  Application: TCommandApp;

{$R *.res}

procedure AskConfirmationCommand(ABuilder: ICommandBuilder);
var
  LInvalidKey: Boolean = True;
  LInput: string;
begin
  ABuilder.OutputColor('Are you sure? [y]es or [n]o ', ABuilder.ColorTheme.Other);
  while LInvalidKey do
  begin
    LInput := ABuilder.InputLn;
    LInvalidKey := not AnsiMatchText(LInput, ['y', 'n']);
    if LInvalidKey then
      ABuilder.OutputColor(
        'Invalid input. Are you sure? [y]es or [n]o ', ABuilder.ColorTheme.Other);
  end;

  case AnsiIndexText(LInput, ['y', 'n']) of 
    0:
      ABuilder.OutputColor('Your answer: yes ', ABuilder.ColorTheme.Value);
    1:
      ABuilder.OutputColor('Your answer: no ', ABuilder.ColorTheme.Text);
    else
      ABuilder.OutputColor('aborted.', ABuilder.ColorTheme.Value);
  end;
end;

procedure HelloCommand(ABuilder: ICommandBuilder);
var
  LInput: string;
begin
  ABuilder.OutputColor('Please, input yor name: ', ABuilder.ColorTheme.Other);
  LInput := ABuilder.InputLn;
  ABuilder.OutputColor('Hello, ', ABuilder.ColorTheme.Title);
  ABuilder.OutputColor(LInput, ABuilder.ColorTheme.Value);
end;

begin
  Application := TCommandApp.Create(nil);
  Application.Title := 'Input CLI tool. Test basic input read from ICommandBuilder';

  Application.CommandBuilder.ColorTheme := DarkColorTheme;

  Command.Usage.Registry(Application.CommandBuilder);
  Command.Version.Registry(Application.CommandBuilder);

  Application
    .CommandBuilder
      .AddCommand(
        'ask',
        'Ask for user confirmation.'#13#10 +
        'Ex: input ask',
        @AskConfirmationCommand,
        [ccNoParameters])
      .AddCommand(
        'hello',
        'Ask for user name and says hello.'#13#10 +
        'Ex: input hello',
        @HelloCommand,
        [ccNoParameters]);

  Application.Run;
  Application.Free;
end.