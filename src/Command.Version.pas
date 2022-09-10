/// <summary> This unit contains functions to expose a command that displays version information 
/// about the application. </summary>
unit Command.Version;

{$MODE DELPHI}{$H+}

interface

uses
  Command.Interfaces;

  /// <summary> Outputs application version information that was incorporated after the 
  /// application was built.</summary>
  ///
  /// @note(Requires version information to be defined in the Lazarus project @bold(.lpi) file. 
  /// Also the main program must include the @bold({$R *.res}) directive.)
  /// If a different color theme is specified for the @link(TCommandBuilder.ColorTheme), the
  /// output will be properly done.
  /// 
  /// To use this command add the Command.Version unit to the uses clause and run the 
  /// following command:
  /// @longCode(
  /// Command.Version.Registry(MyApp.CommandBuilder);)
  /// or you can use the overloaded version of AddCommand to add the command to the builder using fluent interface:
  /// @longCode(
  ///   MyBuilder
  ///     .AddCommand(Command.Version.Registry);
  /// )
  /// <param name="ABuilder">CommandBuilder that will be used to output the version 
  /// information. </param>  
  procedure VersionCommand(ABuilder: ICommandBuilder);

  /// <summary> Configure VersionCommand with standard parameters. </summary>
  ///
  /// Ex:
  /// @longCode(
  /// Command.Version.Registry(MyApp.CommandBuilder);
  /// )
  /// Ex with fluent interface:
  /// @longCode(
  ///   Builder.AddCommand(Command.Version.Registry);
  /// )
  /// <param name="ABuilder"> CommandBuilder instance that will be used to register the 
  /// VersionCommand.</param>  
  function Registry(ABuilder: ICommandBuilder): Boolean;

implementation

uses
  Classes,
  SysUtils,
  resource,
  versiontypes,
  versionresource;

function ResourceVersionInfo: string;
var     
  LStream: TResourceStream = nil;
  LResource: TVersionResource = nil;
  LFixedInfo: TVersionFixedInfo = nil;
begin
  Result := '';
  try
    LStream := TResourceStream.CreateFromID(HINSTANCE, 1, PChar(RT_VERSION));
    LResource := TVersionResource.Create;
    LResource.SetCustomRawDataStream(LStream);
    LFixedInfo := LResource.FixedInfo;
    Result := 'version ' + 
                IntToStr(LFixedInfo.FileVersion[0]) + '.' + 
                IntToStr(LFixedInfo.FileVersion[1]) + '.' + 
                IntToStr(LFixedInfo.FileVersion[2]); // + ' build ' + IntToStr(LFixedInfo.FileVersion[3]) + eol;
    LResource.SetCustomRawDataStream(nil)
  except
    on E: Exception do
    begin
      Result := 
        'Error trying to retrieve version info from binary: ' + E.Message + #13#10 +
        'Project file .lpi should have version info.'#13#10 +
        'Projet source .lpr should include resource info {$R *.res}';
    end;
  end;
  FreeAndNil(LResource);
  FreeAndNil(LStream);
 end;

procedure VersionCommand(ABuilder: ICommandBuilder);
begin
  ABuilder.OutputColor(ABuilder.ExeName + ' ', ABuilder.ColorTheme.Value);
  ABuilder.OutputColor(ResourceVersionInfo + #13#10, ABuilder.ColorTheme.Other);
end;

function Registry(ABuilder: ICommandBuilder): Boolean;
begin
  ABuilder
    .AddCommand('version')
      .Description( 
        'Shows the ' + ABuilder.ExeName + ' version information'#13#10 +
        'Ex: ' + ABuilder.ExeName + ' version')
      .CheckConstraints([ccNoParameters])
      .OnExecute(VersionCommand);
  Result := True;
end;

end.