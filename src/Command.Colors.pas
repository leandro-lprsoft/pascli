/// <summary> This unit allows using colors when generating the application's output. It has 
/// configuration of Dark, Light and standard color themes.
/// Check the CommandBuilder.OutputColor method that allows writing text using a certain color.
/// </summary>
///
/// To use it, just add it to the program's uses clause, choose a theme from @link(LightColorTheme)
/// or @link(DarkColorTheme), you can also define your own theme using the record @link(TColorTheme) 
/// and assigning it to the @link(TCommandBuilder.ColorTheme). See the example:
///
/// @longCode(
/// Application.CommandBuilder.ColorTheme := DarkColorTheme;
/// Application.CommandBuilder.OutputColor('Hello world', Application.CommandBuilder.Title);)
///
/// See @link(TCommandBuilder.OutputColor) on how to use it. Color constants can be used directly 
/// as parameters for functions, in the example above we only used the theme for convention purposes. 
/// Library commands like @link(UsageCommand), @link(VersionCommand) are directly affected by the 
/// chosen theme.
///
/// @note(This unit has an intilization section that tries to figure out the console color before
/// any color change. This color will be restored before application terminates via the code in
/// finalzation section.)
unit Command.Colors;

{$MODE DELPHI}{$H+}

interface

uses
  {$IF DEFINED(WINDOWS)}
  Windows,
  {$ELSE}
  Crt,
  {$ENDIF}
  SysUtils,
  Command.Interfaces;

const 
  Black         = 0;
  Blue          = 1;
  Green         = 2;
  Cyan          = 3;
  Red           = 4;
  Magenta       = 5;
  Brown         = 6;
  LightGray     = 7;
  DarkGray      = 8;
  LightBlue     = 9;
  LightGreen    = 10;
  LightCyan     = 11;
  LightRed      = 12;
  LightMagenta  = 13;
  Yellow        = 14;
  White         = 15;

  /// <summary> Changes default console color for text output.</summary>
  /// Ex: change text output color to LightGreen color constant:
  ///
  /// @code(ChangeConsoleColor(LightGreen));
  procedure ChangeConsoleColor(const AColor: Integer);

  /// <summary> This command outputs text for each color represented by the constant colors in this unit.
  /// You may add this command to the application using @link(TCommandBuilder.AddCommand), so you can check
  /// how a given color is displayed on console. There is sample app called colors on the source code repository
  /// that shows how this command works.
  /// </summary>
  procedure OutputPalleteColor(ABuilder: ICommandBuilder);

var
  /// <summary>Contains the initial color detected by the application before any color change.
  /// </summary>
  StartupColor: byte;

  
  /// <summary>Initial color themes available from the library. Can be assigned to 
  /// CommandBuilder's ColorTheme property. </summary>
  StartColorTheme: TColorTheme; 

  /// <summary>Suggested light color theme. Good to use with a console that has a white background. 
  /// Can be assigned to CommandBuilder's ColorTheme property. </summary>
  LightColorTheme: TColorTheme; 

  /// <summary>Suggested dark color theme. Good to use with a console that has a dark background. 
  /// Can be assigned to CommandBuilder's ColorTheme property. </summary>
  DarkColorTheme: TColorTheme;

implementation

procedure ChangeConsoleColor(const AColor: Integer);
begin
  {$IF DEFINED(WINDOWS)}
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), AColor);
  {$ELSE}
  TextColor(AColor);
  {$ENDIF}
end;

procedure OutputPalleteColor(ABuilder: ICommandBuilder);
begin
  ChangeConsoleColor(Black);
  ABuilder.Output('Black = 0');
  ChangeConsoleColor(Blue);
  ABuilder.Output('Blue = 1');
  ChangeConsoleColor(Green);
  ABuilder.Output('Green = 2');
  ChangeConsoleColor(Cyan);
  ABuilder.Output('Cyan = 3');
  ChangeConsoleColor(Red);
  ABuilder.Output('Red = 4');
  ChangeConsoleColor(Magenta);
  ABuilder.Output('Magenta = 5');
  ChangeConsoleColor(Brown);
  ABuilder.Output('Brown = 6');
  ChangeConsoleColor(LightGray);
  ABuilder.Output('LightGray = 7');
  ChangeConsoleColor(DarkGray);
  ABuilder.Output('DarkGray = 8');
  ChangeConsoleColor(LightBlue);
  ABuilder.Output('LightBlue = 9');
  ChangeConsoleColor(LightGreen);
  ABuilder.Output('LightGreen = 10');
  ChangeConsoleColor(LightCyan);
  ABuilder.Output('LightCyan = 11');
  ChangeConsoleColor(LightRed);
  ABuilder.Output('LightRed = 12');
  ChangeConsoleColor(LightMagenta);
  ABuilder.Output('LightMagenta = 13');
  ChangeConsoleColor(Yellow);
  ABuilder.Output('Yellow = 14');
  ChangeConsoleColor(White);
  ABuilder.Output('White = 15');
end;

{$IF DEFINED(WINDOWS)}
function GetColors: Byte;
var
  LHandle: THandle;
  LScreenBufInfo: TConsoleScreenBufferInfo;
begin
  LHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  if LHandle = INVALID_HANDLE_VALUE then 
    RaiseLastOSError;
  GetConsoleScreenBufferInfo(LHandle, LScreenBufInfo);
  GetColors := LScreenBufInfo.wAttributes;
end;

function GetTextColor: Byte;
begin
  GetTextColor := GetColors and $0F;
end;
{$ENDIF}

procedure InitalizeColorThemes;
begin
  StartColorTheme.Title := StartupColor;
  StartColorTheme.Value := StartupColor;
  StartColorTheme.Text := StartupColor;
  StartColorTheme.Other := StartupColor;
  StartColorTheme.Error := StartupColor;
  LightColorTheme.Title := Blue;
  LightColorTheme.Value := Magenta;
  LightColorTheme.Text := DarkGray;
  LightColorTheme.Other := DarkGray;
  LightColorTheme.Error := LightRed;
  DarkColorTheme.Title := Yellow;
  DarkColorTheme.Value := LightGreen;
  DarkColorTheme.Text := LightBlue;
  DarkColorTheme.Other := White;
  DarkColorTheme.Error := LightRed;
end;

initialization
  {$IF DEFINED(WINDOWS)}
  StartupColor := GetTextColor;
  {$ELSE}
  StartupColor := 7;
  {$ENDIF}
  InitalizeColorThemes;

finalization
  ChangeConsoleColor(StartupColor);

end.