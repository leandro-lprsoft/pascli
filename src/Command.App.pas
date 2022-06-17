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
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    property CommandBuilder: ICommandBuilder read FCommandBuilder write FCommandBuilder;
  end;

implementation

{ TCommandApp }

procedure TCommandApp.DoRun;
begin
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

end.