unit Command.Version;

{$MODE DELPHI}{$H+}

interface

uses
  Command.Interfaces;

  /// outputs version information incorporated into the binary through use of project version info
  procedure VersionCommand(ABuilder: ICommandBuilder);

  /// register this command with basic parameters
  procedure Registry(ABuilder: ICommandBuilder);

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

procedure Registry(ABuilder: ICommandBuilder);
begin
  ABuilder
    .AddCommand(
      'version', 
      'Shows the ' + ABuilder.ExeName + ' version information'#13#10 +
      'Ex: ' + ABuilder.ExeName + ' version', 
      @VersionCommand,
      [ccNoParameters]);
end;

end.