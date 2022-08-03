unit Command.App;

{$MODE DELPHI}{$H+}

interface

uses
  Classes,
  SysUtils,
  CustApp,
  Command.Interfaces,
  Command.Builder;

type
  { TCommandApp }
  TCommandApp = class(TCustomApplication)
  private
    FCommandBuilder: ICommandBuilder;

    /// <summary> Read an environment variable named COLORFGBG that should be filled with the following
    /// pattern "foreground color;background color". If the background color is white (15), default 
    /// color theme will be changed to LightColorTheme. 
    /// To change this variable on windows powershell you may use $ENV:COLORFGBG="0;15" and to change
    /// on linux you may use COLORFGBG="0;15" directly on bash terminal.
    /// </summary>
    procedure SetDefaultThemeColor;

  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    property CommandBuilder: ICommandBuilder read FCommandBuilder write FCommandBuilder;
  end;

implementation

uses
  StrUtils,
  Types,
  Command.Colors;

{ TCommandApp }

procedure TCommandApp.DoRun;
begin
  SetDefaultThemeColor;
  CommandBuilder.Title := Title;
  CommandBuilder.Parse;
  CommandBuilder.Validate;
  CommandBuilder.Execute;
  Terminate;
end;

constructor TCommandApp.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException := True;
  FCommandBuilder := TCommandBuilder.Create(ExtractFileName(Self.ExeName));
end;

procedure TCommandApp.SetDefaultThemeColor;
var
  LColor: string;
  LColors: TStringDynArray ;
begin
  LColor := GetEnvironmentVariable('COLORFGBG');
  if LColor = '' then 
    exit;
  LColors := SplitString(LColor, ';');
  if (Length(LColors) > 0) and (LColors[1] = '15') then
  begin
    FCommandBuilder.ColorTheme := LightColorTheme;
    StartupColor := 0;
  end;
end;

end.