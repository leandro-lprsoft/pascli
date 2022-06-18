unit TestCommandVersion;

{$MODE DELPHI}{$H+}

interface

uses
  fpcunit, 
  testutils, 
  testregistry,
  Command.App,
  Command.Interfaces,
  Command.Version;

type

  TTestCommandVersion = class(TTestCase)
  private
    FApplication: TCommandApp;
    FBuilder: ICommandBuilder;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestVersionCommand;
  end;

implementation

uses
  Classes, 
  SysUtils,
  StrUtils;

var
  CapturedOutput: string;

procedure MockOutput(const AMessage: string);
begin
  CapturedOutput := CapturedOutput + AMessage + #13#10;
end;

procedure TTestCommandVersion.SetUp;
begin
  FApplication := TCommandApp.Create(nil);
  FApplication.Title := 'version app';
  FBuilder := FApplication.CommandBuilder;
  FApplication.CommandBuilder.Output := MockOutput;
  CapturedOutput := '';
end;

procedure TTestCommandVersion.TearDown;
begin
  FApplication.Free;
end;

procedure TTestCommandVersion.TestVersionCommand;
begin
  // arrange
  Command.Version.Registry(FBuilder);

  // act
  VersionCommand(FBuilder);

  // assert
  AssertTrue('should have "Commands:" text', ContainsText(CapturedOutput, 'version'));
end;

initialization
  RegisterTest(TTestCommandVersion);

end.