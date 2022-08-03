unit Command.Builder;

{$MODE DELPHI}{$H+}

interface

uses
  Classes,
  SysUtils,
  Command.Interfaces;

type
  TOption = class(TInterfacedObject, IOption)
  private 
    FFlag: string;
    FName: string;
    FDescription: string;
    FNotAllowedFlags: TArray<string>;

    function GetFlag: string;
    procedure SetFlag(const AValue: string);
    function GetName: string;
    procedure SetName(const AValue: string);
    function GetDescription: string;
    procedure SetDescription(const AValue: string);
    procedure SetNotAllowedFlags(const Value: TArray<string>);
    function GetNotAllowedFlags: TArray<string>;
  public 

    /// letter option that will bu used as a option flag for a given command or a direct option
    property Flag: string read GetFlag write SetFlag;

    /// option name that will bu used as a option argument for a given command.
    property Name: string read GetName write SetName;

    /// command description that will be displayed on usage examples
    property Description: string read GetDescription write SetDescription;     

    /// not allowed flags to use with this option
    property NotAllowedFlags: TArray<string> read GetNotAllowedFlags write SetNotAllowedFlags;

    /// creates an IOption instance
    class function New(const AFlag, AName, ADescription: string; ANotAllowedFlags: TArray<string>): IOption;

  end;

  TCommand = class(TInterfacedObject, ICommand)
  private
    FName: string;
    FDescription: string;
    FCallback: TCommandCallback;
    FConstraints: TCommandConstraints;
    FOptions: TArray<IOption>;

    function GetName: string;
    procedure SetName(const AValue: string);
    function GetDescription: string;
    procedure SetDescription(const AValue: string);
    function GetCallback: TCommandCallback;
    procedure SetCallback(AValue: TCommandCallback);
    function GetConstraints: TCommandConstraints;
    procedure SetConstraints(const AValue: TCommandConstraints); 
    function GetOption(const AIndex: string): IOption;   
    function GetOptions: TArray<IOption>;

  public
    constructor Create;

    /// command name that will bu used as a command line argument
    property Name: string read GetName write SetName;

    /// command description that will be displayed on usage examples
    property Description: string read GetDescription write SetDescription;    

    /// callback procedure that will be called if this command was provided
    property Callback: TCommandCallback read GetCallback write SetCallback;

    /// command constraints what will be checked before execute the callback procedure
    property Constraints: TCommandConstraints read GetConstraints write SetConstraints;

    /// options related to this command
    property Option[const AIndex: string]: IOption read GetOption;

    property Options: TArray<IOption> read GetOptions;

    // returns true if command accept options
    function HasOptions: Boolean;    

    /// allow to add na option to this command
    function AddOption(const AFlag, AName, ADescription: string; ANotAllowedFlags: TArray<string> = nil
      ): IOption;

    /// creates an IOption instance
    class function New(const AName, ADescription: string; ACallback: TCommandCallback; 
      AConstraints: TCommandConstraints): ICommand;

  end;

  TArgument = class(TInterfacedObject, IArgument)
  private
    FDescription: string;
    FConstraint: TArgumentConstraint;
    FValue: string;

    function GetDescription: string;
    procedure SetDescription(const AValue: string);
    function GetConstraint: TArgumentConstraint;
    procedure SetConstraint(const AValue: TArgumentConstraint); 
    function GetValue: string;
    procedure SetValue(const AValue: string);
    
  public

    /// command description that will be displayed on usage examples
    property Description: string read GetDescription write SetDescription;    

    /// command constraints what will be checked before execute the callback procedure
    property Constraint: TArgumentConstraint read GetConstraint write SetConstraint;

    /// returns the value of argument provided via parameter, this value should assigned after parse
    property Value: string read GetValue write SetValue;    

    /// creates an IArgument instance
    class function New(const ADescription: string; AConstraint: TArgumentConstraint): IArgument;

  end;  

  TCommandBuilder = class(TInterfacedObject, ICommandBuilder)
  private
    FExeName: string;
    FInputLn: TInputLnCallback;
    FOutput: TOutputCallback;
    FOutputColor: TOutputColorCallback;
    FColorTheme: TColorTheme;
    FCommands: TArray<ICommand>;
    FArguments: TArray<IArgument>;
    FUseExternalArguments: Boolean;
    FExternalArguments: TArray<string>;
    FProvidedArgs: TArray<string>;
    FProvidedOptions: TArray<string>;
    FParsedErrors: TArray<string>;
    FCommandSelected: ICommand;
    FCommandAsArgument: ICommand;
    FParsedOptions: TArray<IOption>;
    FCommandsFound: Integer;
    FTitle: String;
    FUseShortDescriptions: Boolean;
    FState: string;

    procedure AppendProvidedOptions(const AParam: string);

    function GetCommand(const AName: string): ICommand;

    /// returns a list of commands configured on builder
    function GetCommands: TArray<ICommand>;

    /// returns a list of argumetns configured on builder
    function GetArguments: TArray<IArgument>;

    function GetArgument(const AName: string): IArgument;

    function GetInputLn: TInputLnCallback;
    procedure SetInputLn(AValue: TInputLnCallback);

    function GetOutput: TOutputCallback;
    procedure SetOutput(AValue: TOutputCallback);

    /// output callback procedure that will be called to print command usage and messages validation
    /// with color
    function GetOutputColor: TOutputColorCallback;
    procedure SetOutputColor(AValue: TOutputColorCallback);

    /// Color theme that should be used to output colors of commands, its use is optional
    function GetColorTheme: TColorTheme;
    procedure SetColorTheme(AValue: TColorTheme);

    /// Application title
    function GetTitle: string;
    procedure SetTitle(AValue: string);

    /// display only the first line usage description for command usage, the user needs
    /// to use help command to see full command description. Default value is false to
    /// preserve original function.
    function GetUseShortDescriptions: boolean;
    procedure SetUseShortDescriptions(AValue: boolean);

    procedure ParseArguments;
    procedure ParseCommands;
    procedure ParseOptions;

    function ParsedErrorsShow: Boolean;
    function GetParsedOptions: TArray<IOption>;

    /// build a list of IArguments related to selected command, if there are more than one argument
    /// provided the list will match one argument parameter by order of the command builder construction
    function GetParsedArguments: TArray<IArgument>;

    /// <summary> State that can be set by user commands allowing better communication 
    /// between commands and the application. </summary>
    function GetState: string;
    procedure SetState(AValue: string);

  public

    /// creates an instance with a exe name that will be used as command line shell name to start the application
    constructor Create(AExeName: String);

    /// adds a command to the console application
    function AddCommand(const ACommand, ADescription: string; ACallback: TCommandCallback; 
      AConstraints: TCommandConstraints): ICommandBuilder;

    /// returns a list of commands configured on builder
    property Commands: TArray<ICommand> read GetCommands;

    /// adds an argument parameter that can be required or optional
    function AddArgument(const ADescription: string; AConstraint: TArgumentConstraint): ICommandBuilder;

    /// allow access to the arguments list
    property Arguments: TArray<IArgument> read GetArguments;

    /// adds an option to the application or to the last command that was added.
    /// specifies a short flag, an option name and the description of this option
    function AddOption(const AFlag, AName, ADescription: string; ANotAllowedFlags: TArray<string> = nil
      ): ICommandBuilder;

    /// parse supplied commands and arguments
    procedure Parse;

    /// validate supplied command and arguments
    function Validate: TArray<string>;   

    /// executes the command
    procedure Execute;

    /// returns the selected command after parameters parse
    function CommandSelected: ICommand;

    /// manually sets the selected command 
    function SetCommandSelected(ACommand: ICommand): ICommandBuilder;

    /// returns a option command as an argument for the selected command
    function CommandAsArgument: ICommand;

    /// manually sets the a command as an argument
    function SetCommandAsArgument(ACommand: ICommand): ICommandBuilder;

    /// returns the number of commands matched against passed arguments
    function GetCommandsFound: Integer;

    /// returns the default command if one was set
    function GetDefaultCommand: ICommand;

    /// returns parsed options list
    property ParsedOptions: TArray<IOption> read GetParsedOptions;    

    /// checks if a specific option was provided as a parameter
    function CheckOption(const AOption: string): Boolean;

    /// returns a list of IArgument related to selected command
    property ParsedArguments: TArray<IArgument> read GetParsedArguments;

    /// returns a list of raw arguments passed as parameters
    function GetRawArguments: TArray<string>;

    /// returns a list of raw options passed as parameters
    function GetRawOptions: TArray<string>;

    /// returns a reference to the TCustomApplication
    function ExeName: string;

    /// returns if builder has at least one command defined
    function HasCommands: Boolean;

    /// returns if builder has at least one argument defined
    function HasArguments: Boolean;

    /// returns if builder has any option set on root or in any command
    function HasOptions: Boolean;

    /// callback function that will be used to read user input from console and returns a key
    property InputLn: TInputLnCallback read GetInputLn write SetInputLn;

    /// output callback procedure that will be called to print command usage and messages validation
    property Output: TOutputCallback read GetOutput write SetOutput;

    /// output callback procedure that will be called to print command usage and messages validation
    /// with color
    property OutputColor: TOutputColorCallback read GetOutputColor write SetOutputColor;        

    /// allows to inject external arguments instead of reading from ParamStr()
    function UseArguments(AArguments: TArray<string>): ICommandBuilder;

    /// Color theme that should be used to output colors of commands, its use is optional
    property ColorTheme: TColorTheme read GetColorTheme write SetColorTheme;      

    /// Application title
    property Title: string read GetTitle write SetTitle;  

    /// display only the first line usage description for command usage, the user needs
    /// to use help command to see full command description. Default value is false to
    /// preserve original function.
    property UseShortDescriptions: boolean read GetUseShortDescriptions write SetUseShortDescriptions;

    /// <summary> State that can be set by user commands allowing better communication 
    /// between commands and the application. </summary>
    property State: string read GetState write SetState;

  end;

  function StandardConsoleInputLn: string;

  procedure StandardConsoleOutput(const AMessage: string);
  procedure ColorConsoleOutput(const AMessage: string; const AColor: byte);

implementation

uses
  StrUtils,
  Command.Helpers,
  Command.Validator,
  Command.Colors;

class function TOption.New(const AFlag, AName, ADescription: string; ANotAllowedFlags: TArray<string>): IOption;
var
  LFlag: string;
begin
  if AFlag = '' then
    raise Exception.CreateFmt(
      'A valid flag parameter for Command "--%s" should be provided.', [AName]);

  if (Copy(AFlag, 1, 1) = '-') or (Copy(AName, 1, 1) = '-')  then      
    raise Exception.CreateFmt(
      'A valid flag or name option should not start with a "-"', [AFlag]);

  for LFlag in ANotAllowedFlags do
    if Length(LFlag) <> 1 then
      raise Exception.CreateFmt(
          'Not allowed option "%s" invalid for Command "--%s". Only flags should be used.',
          [LFlag, AName]);

  Result := TOption.Create as IOption;
  Result.Flag := AFlag;
  Result.Name := AName;
  Result.Description := ADescription;
  Result.NotAllowedFlags := ANotAllowedFlags;
end;

function TOption.GetFlag: string;
begin
  Result := FFlag;
end;

procedure TOption.SetFlag(const AValue: string);
begin
  FFlag := AValue;
end;

function TOption.GetName: string;
begin
  Result := FName;
end;

procedure TOption.SetName(const AValue: string);
begin
  FName := AValue;
end;

function TOption.GetDescription: string;
begin
  Result := FDescription;
end;

procedure TOption.SetDescription(const AValue: string);
begin
  FDescription := AValue;
end;

procedure TOption.SetNotAllowedFlags(const Value: TArray<string>);
begin
  FNotAllowedFlags := Value;
end;

function TOption.GetNotAllowedFlags: TArray<string>;
begin
  Result := FNotAllowedFlags;
end;

constructor TCommand.Create;
begin
  SetLength(FOptions, 0);
end;

class function TCommand.New(const AName, ADescription: string; ACallback: TCommandCallback; 
  AConstraints: TCommandConstraints): ICommand;
begin
  Result := TCommand.Create as ICommand;
  Result.Name := AName;
  Result.Description := ADescription;
  Result.Callback := ACallback;
  Result.Constraints := AConstraints;
end;

function TCommand.GetName: string;
begin
  Result := FName;
end;

procedure TCommand.SetName(const AValue: string);
begin
  FName := AValue;
end;

function TCommand.GetDescription: string;
begin
  Result := FDescription;
end;

procedure TCommand.SetDescription(const AValue: string);
begin
  FDescription := AValue;
end;

function TCommand.GetCallback: TCommandCallback;
begin
  Result := FCallback;
end;

procedure TCommand.SetCallback(AValue: TCommandCallback);
begin
  FCallback := AValue;
end;

function TCommand.GetConstraints: TCommandConstraints;
begin
  Result := FConstraints;
end;

procedure TCommand.SetConstraints(const AValue: TCommandConstraints); 
begin
  FConstraints := AValue;
end;

function TCommand.GetOption(const AIndex: string): IOption;   
var 
  I: integer;
begin
  Result := nil;
  for I := 0 to Length(FOptions) - 1 do
    if SameText(FOptions[I].Name, AIndex) or SameText(FOptions[I].Flag, AIndex) then
      Exit(FOptions[I]);
end;

function TCommand.GetOptions: TArray<IOption>;
begin
  Result := FOptions;
end;

function TCommand.AddOption(const AFlag, AName, ADescription: string; 
  ANotAllowedFlags: TArray<string> = nil): IOption;
var 
  LOption: IOption;
begin
  LOption := TOption.New(AFlag, AName, ADescription, ANotAllowedFlags);
  SetLength(FOptions, Length(FOptions) + 1);
  FOptions[Length(FOptions) - 1] := LOption;
  Result := FOptions[Length(FOptions) - 1];
end;

function TCommand.HasOptions: Boolean;
begin
  Result := Length(FOptions) > 0;
end;

class function TArgument.New(const ADescription: string; AConstraint: TArgumentConstraint): IArgument;
begin
  Result := TArgument.Create as IArgument;
  Result.Description := ADescription;
  Result.Constraint := AConstraint;  
end;

function TArgument.GetDescription: string;
begin
  Result := FDescription;
end;

procedure TArgument.SetDescription(const AValue: string);
begin
  FDescription := AValue;
end;

function TArgument.GetConstraint: TArgumentConstraint;
begin
  Result := FConstraint;
end;

procedure TArgument.SetConstraint(const AValue: TArgumentConstraint); 
begin
  FConstraint := AValue;
end;

function TArgument.GetValue: string;
begin
  Result := FVAlue;
end;

procedure TArgument.SetValue(const AValue: string);
begin
  FValue := AValue;
end;

constructor TCommandBuilder.Create(AExeName: String);
begin
  if AExeName = '' then
    raise Exception.Create('AExeName cannot be empty.');

  FExeName := AExeName;
  FCommandSelected := nil;
  FCommandAsArgument := nil;
  FUseExternalArguments := False;
  FUseShortDescriptions := False;
  FState := '';
  FColorTheme := StartColorTheme;
  SetLength(FExternalArguments, 0);
  FInputLn := StandardConsoleInputLn;
  FOutput := StandardConsoleOutput;
  FOutputColor := ColorConsoleOutput;
end;

function TCommandBuilder.AddCommand(const ACommand, ADescription: string; ACallback: TCommandCallback; 
  AConstraints: TCommandConstraints): ICommandBuilder;
begin
  SetLength(FCommands, Length(FCommands) + 1);
  FCommands[Length(FCommands) - 1] := TCommand.New(ACommand, ADescription, ACallback, AConstraints);
  Result := Self;
end;

function TCommandBuilder.AddArgument(const ADescription: string; AConstraint: TArgumentConstraint): ICommandBuilder;
begin
  SetLength(FArguments, Length(FArguments) + 1);
  FArguments[Length(FArguments) - 1] := TArgument.New(ADescription, AConstraint);
  Result := Self;
end;

function TCommandBuilder.GetCommand(const AName: string): ICommand;
var 
  I: integer;
begin
  Result := nil;
  for I := 0 to Length(FCommands) - 1 do
    if FCommands[I].Name = AName then
      Exit(FCommands[I]);
end;

function TCommandBuilder.GetCommands: TArray<ICommand>;
begin
  Result := FCommands;
end;

function TCommandBuilder.GetArgument(const AName: string): IArgument;
var 
  I: integer;
begin
  Result := nil;
  for I := 0 to Length(FArguments) - 1 do
    if FArguments[I].Description = AName then
      Exit(FArguments[I]);
end;

function TCommandBuilder.AddOption(const AFlag, AName, ADescription: string; ANotAllowedFlags: TArray<string> = nil
  ): ICommandBuilder;
begin
  if Length(FCommands) = 0 then
    raise Exception.Create('Must add a command to add an option.');

  FCommands[Length(FCommands) - 1].AddOption(AFlag, AName, ADescription, ANotAllowedFlags);
  Result := Self;
end;

function TCommandBuilder.ParsedErrorsShow: Boolean;
var
  I: Integer;
  LTitle: string;
begin
  if Length(FParsedErrors) <= 0 then Exit(False);

  LTitle := FExeName + ': ';
  for I := 0 to Length(FParsedErrors) - 1 do
  begin
    Output(LTitle + FParsedErrors[I]);
    LTitle := '';
  end;

  Result := True;
end;

function TCommandBuilder.GetDefaultCommand: ICommand;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Length(FCommands) - 1 do
    if ccDefault in FCommands[I].Constraints then
      Exit(FCommands[I]);
end;

procedure TCommandBuilder.ParseArguments;
var
  I: Integer;
begin
  FCommandSelected := nil;
  FCommandAsArgument := nil;
  SetLength(FProvidedArgs, 0); 
  SetLength(FParsedErrors, 0);
  FCommandsFound := 0;
  FState := '';

  for I := 0 to Length(FArguments) - 1 do
    FArguments[I].Value := '';

  if FUseExternalArguments then
  begin
    for I := 0 to Length(FExternalArguments) - 1 do
      if Copy(FExternalArguments[I], 1, 1) <> '-' then
        AppendToArray(FProvidedArgs, FExternalArguments[I])
      else
        AppendProvidedOptions(FExternalArguments[I]);
  end
  else
  begin
    for I := 1 to ParamCount do
      if Copy(ParamStr(I), 1, 1) <> '-' then
        AppendToArray(FProvidedArgs, ParamStr(I))
      else
        AppendProvidedOptions(ParamStr(I));
  end;
end;

procedure TCommandBuilder.ParseCommands;
var
  I, J: Integer;
begin
  for I := 0 to Length(FProvidedArgs) - 1 do
    for J := 0 to Length(FCommands) - 1 do
      if SameText(FCommands[J].Name, FProvidedArgs[I]) then
      begin
        if not Assigned(FCommandSelected) then 
          FCommandSelected := FCommands[J]
        else
          FCommandAsArgument := FCommands[J];
        Inc(FCommandsFound);
      end;
  
  if not Assigned(FCommandSelected) then
    FCommandSelected := GetDefaultCommand;

end;

procedure TCommandBuilder.ParseOptions;
var
  LOption: IOption;
  LRawOption, LOptionCleaned: string;
begin
  SetLength(FParsedOptions, 0);
  if not Assigned(CommandSelected) then 
    Exit;

  for LOption in CommandSelected.Options do
    for LRawOption in FProvidedOptions do
    begin
      LOptionCleaned := RemoveStartingDashes(LRawOption);
      if AnsiMatchText(LOptionCleaned, [LOption.Flag, LOption.Name]) then
      begin
        SetLength(FParsedOptions, Length(FParsedOptions) + 1);
        FParsedOptions[Length(FParsedOptions) - 1] := LOption;
      end;
    end;
end;

procedure TCommandBuilder.Parse; 
begin
  ParseArguments;
  ParseCommands;
  ParseOptions;  
end;

function TCommandBuilder.Validate: TArray<string>;  
var
  LValidatorContext: IValidatorContext;
begin
  LValidatorContext := TValidatorContext.Create;
  FParsedErrors := LValidatorContext.Validate(Self);
  Result := FParsedErrors;
   
  if ParsedErrorsShow then
    Exit;
end;

procedure TCommandBuilder.Execute;
begin
  if Length(FParsedErrors) = 0 then
    CommandSelected.Callback(Self);
end;

function TCommandBuilder.CommandSelected: ICommand;
begin
  Result := FCommandSelected;
end;

function TCommandBuilder.SetCommandSelected(ACommand: ICommand): ICommandBuilder;
begin
  FCommandSelected := ACommand;
  Result := Self;
end;

function TCommandBuilder.CommandAsArgument: ICommand;    
begin
  Result := FCommandAsArgument;
end;

function TCommandBuilder.SetCommandAsArgument(ACommand: ICommand): ICommandBuilder;
begin
  FCommandAsArgument := ACommand;
  Result := Self;
end;

function TCommandBuilder.GetParsedOptions: TArray<IOption>;
begin
  Result := FParsedOptions;
end;

procedure TCommandBuilder.AppendProvidedOptions(const AParam: string);
var
  I: Integer;
begin
  if StartsText('--', AParam) then
    AppendToArray(FProvidedOptions, AParam)
  else
    for I := 2 to Length(AParam) do
      AppendToArray(FProvidedOptions, '-' + Copy(AParam, I, 1));
end;

function TCommandBuilder.CheckOption(const AOption: string): Boolean;
var
  LOption: IOption;
begin
  Result := False;
  for LOption in FParsedOptions do
    if AnsiMatchText(AOption, [LOption.Flag, LOption.Name]) then
      Exit(True);
end;

function TCommandBuilder.GetParsedArguments: TArray<IArgument>;
var
  LArray: TArray<IArgument> = [];
  I, J, LStart: Integer;
  LCmdSel: String = '';
  LCmdArg: String = '';
begin
  if Assigned(CommandSelected) then
    LCmdSel := CommandSelected.Name;
  if Assigned(CommandAsArgument) then
    LCmdArg := CommandAsArgument.Name;

  LStart := 0;
  for I := 0 to Length(FArguments) - 1 do
  begin
    // busca pelo primeiro argumento que não é um comando
    for J := LStart to Length(FProvidedArgs) - 1 do
      if (not SameText(FProvidedArgs[J], LCmdSel)) and (not SameText(FProvidedArgs[J], LCmdArg)) then
      begin
        SetLength(LArray, Length(LArray) + 1);
        LArray[Length(LArray) - 1] := FArguments[I];
        FArguments[I].Value := FProvidedArgs[J];
        LStart := J + 1;
      end;
  end;

  Result := LArray;
end;

function TCommandBuilder.GetRawArguments: TArray<string>;
begin
  Result := FProvidedArgs;
end;

function TCommandBuilder.GetRawOptions: TArray<string>;
begin
  Result := FProvidedOptions;
end;

function TCommandBuilder.GetCommandsFound: Integer;
begin
  Result := FCommandsFound;
end;

function TCommandBuilder.GetArguments: TArray<IArgument>;
begin
  Result := FArguments;
end;

function TCommandBuilder.ExeName: string;
begin
  Result := ChangeFileExt(FExeName, '');
end;

function TCommandBuilder.HasCommands: Boolean;
begin
  Result := Length(FCommands) > 0;
end;

function TCommandBuilder.HasArguments: Boolean;
begin
  Result := Length(FArguments) > 0;
end;

function TCommandBuilder.HasOptions: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(FCommands) - 1 do
    if (Length(FCommands[I].Options) > 0) then
      Exit(True);
end;

procedure TCommandBuilder.SetInputLn(AValue: TInputLnCallback);
begin
  FInputLn := AValue; 
end;

function TCommandBuilder.GetInputLn: TInputLnCallback;
begin
  Result := FInputLn;
end;

function TCommandBuilder.GetOutput: TOutputCallback;
begin
  Result := FOutput;
end;

procedure TCommandBuilder.SetOutput(AValue: TOutputCallback);
begin
  FOutput := AValue;
end;

function TCommandBuilder.GetOutputColor: TOutputColorCallback;
begin
  Result := FOutputColor;
end;

procedure TCommandBuilder.SetOutputColor(AValue: TOutputColorCallback);
begin
  FOutputColor := AValue;
end;

function TCommandBuilder.GetColorTheme: TColorTheme;
begin
  Result := FColorTheme;
end;

procedure TCommandBuilder.SetColorTheme(AValue: TColorTheme);
begin
  FColorTheme := AValue;
end;

function TCommandBuilder.UseArguments(AArguments: TArray<string>): ICommandBuilder;
begin
  FExternalArguments := AArguments;
  FUseExternalArguments := True;
  Result := Self;
end;

function TCommandBuilder.GetTitle: string;
begin
  Result := FTitle;
end;

procedure TCommandBuilder.SetTitle(AValue: string);
begin
  FTitle := AValue;
end;

function TCommandBuilder.GetUseShortDescriptions: boolean;
begin
  Result := FUseShortDescriptions;
end;

procedure TCommandBuilder.SetUseShortDescriptions(AValue: boolean);
begin
  FUseShortDescriptions := AValue;
end;

function TCommandBuilder.GetState: string;
begin
  Result := FState;
end;

procedure TCommandBuilder.SetState(AValue: string);
begin
  FState := AValue;
end;

function StandardConsoleInputLn: string;
var
  LResult: string = '';
begin
  ReadLn(LResult);
  Result := LResult;
end;

procedure StandardConsoleOutput(const AMessage: string);
begin
  WriteLn(AMessage);
end;

procedure ColorConsoleOutput(const AMessage: string; const AColor: byte);
begin
  ChangeConsoleColor(AColor);
  Write(AMessage);
end;

end.