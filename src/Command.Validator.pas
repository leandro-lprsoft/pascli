unit Command.Validator;

{$MODE DELPHI}{$H+}

interface

uses
  Classes,
  SysUtils,
  Command.Interfaces,
  Command.Helpers;

type
  TValidatorContext = class(TInterfacedObject, IValidatorContext)
  private
    FStartValidator: IValidatorBase;
    FPreviousValidator: IValidatorBase;
  public
    /// creates an instance of TValidatorContext and initiliaze some variables
    constructor Create;

    /// adds an IValidatorBase and sets it as a Sucessor validator for previous one added
    function Add(AValidator: IValidatorBase): IValidatorContext;

    /// Handle validation from first added IValidatorBase
    function HandleValidation(ACommand: ICommandBuilder): TArray<string>;    

    /// Build validation context and runs validation
    function Validate(ACommand: ICommandBuilder): TArray<string>;
  end;

  TValidatorBase = class(TInterfacedObject, IValidatorBase)
  private
    FSucessor: IValidatorBase;
    FResult: TArray<string>;

    function GetSucessor: IValidatorBase;
    procedure SetSucessor(const AValue: IValidatorBase);

  public

    constructor Create;

    /// returns the value of argument provided via parameter, this value should assigned after parse
    property Sucessor: IValidatorBase read GetSucessor write SetSucessor;

    /// function validate a single case and if a sucessor was supplied call its validate method
    function Validate(ACommand: ICommandBuilder): TArray<string>; virtual; 

  end;

  TDuplicateArgumentValidator = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override; 
  end;

  TDuplicateOptionValidator = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override; 
  end;

  TProvidedArgumentsAreNotValid = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override; 
  end;

  TProvidedArgumentsAreNotRequired = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override; 
  end;

  TProvidedArgumentsExceedsAcceptedLimit = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override; 
  end;

  TSelectedCommandDoesNotAcceptCommandAsArgument = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;

  TSelectedCommandRequiresValidCommandOrNothing = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;

  TSelectedCommandRequiresOneArguments = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;

  TSelectedCommandRequiresNoArguments = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;

  TSelectedCommandValidateIfOptionsExists = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;

  TSelectedCommandValidateRejectedOption = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;

implementation

uses
  StrUtils;

constructor TValidatorContext.Create;
begin
  FStartValidator := nil;
  FPreviousValidator := nil;
end;

function TValidatorContext.Add(AValidator: IValidatorBase): IValidatorContext;
begin
  if not Assigned(FStartValidator) then
    FStartValidator := AValidator;

  if Assigned(FPreviousValidator) then
    FPreviousValidator.SetSucessor(AValidator);

  FPreviousValidator := AValidator;
  
  Result := Self; 
end;

function TValidatorContext.HandleValidation(ACommand: ICommandBuilder): TArray<string>;    
begin
  Result := FStartValidator.Validate(ACommand);
end;

function TValidatorContext.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  Result := Self
    .Add(TDuplicateArgumentValidator.Create)
    .Add(TDuplicateOptionValidator.Create)
    .Add(TProvidedArgumentsAreNotValid.Create)
    .Add(TProvidedArgumentsAreNotRequired.Create)
    .Add(TProvidedArgumentsExceedsAcceptedLimit.Create)
    .Add(TSelectedCommandDoesNotAcceptCommandAsArgument.Create)
    .Add(TSelectedCommandRequiresValidCommandOrNothing.Create)
    .Add(TSelectedCommandRequiresOneArguments.Create)
    .Add(TSelectedCommandRequiresNoArguments.Create)
    .Add(TSelectedCommandValidateIfOptionsExists.Create)
    .Add(TSelectedCommandValidateRejectedOption.Create)
    .HandleValidation(ACommand);
end;

constructor TValidatorBase.Create;
begin
  SetLength(FResult, 0);
end;

function TValidatorBase.GetSucessor: IValidatorBase;
begin
  Result := FSucessor;
end;

procedure TValidatorBase.SetSucessor(const AValue: IValidatorBase);
begin
  FSucessor := AValue;
end;

function TValidatorBase.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  Result := FResult;
  if Assigned(FSucessor) then
    Result := FSucessor.Validate(ACommand);
end;

function TDuplicateArgumentValidator.Validate(ACommand: ICommandBuilder): TArray<string>;
var
  LArray: TArray<string>;
  I, J: Integer;
  LAllowedDuplicate: string = '';
begin
  LArray := ACommand.GetRawArguments;

  if (Assigned(ACommand.CommandSelected)) and
     (ccNoArgumentsButCommands in ACommand.CommandSelected.Constraints) and 
     (Assigned(ACommand.CommandAsArgument)) and
     (ACommand.CommandSelected.Name = ACommand.CommandAsArgument.Name) then 
    LAllowedDuplicate := ACommand.CommandSelected.Name;

  for I := 0 to Length(LArray) - 1 do
    for J := 0 to Length(LArray) - 1 do
      if (I <> J) and (SameText(LArray[I], LArray[J])) and (not SameText(LAllowedDuplicate, LArray[J])) then
      begin
        AppendToArray(FResult, Format('Duplicate argument "%s" was provided', [LArray[I]]));
        Exit(FResult);
      end;

  Result := inherited Validate(ACommand);
end;

function TDuplicateOptionValidator.Validate(ACommand: ICommandBuilder): TArray<string>;
var
  LArray: TArray<string>;
  I, J: Integer;
  LCommand: ICommand;
  LOption: IOption;
  LShort, LLong, LMessage, LRawOption: string;
begin
  LCommand := ACommand.CommandSelected;
  if not Assigned(LCommand) then
    LCommand := ACommand.GetDefaultCommand;

  LArray := ACommand.GetRawOptions;
  for I := 0 to Length(LArray) - 1 do
  begin
    LOption := LCommand.Option[RemoveStartingDashes(LArray[I])];

    if Assigned(LOption) then
    begin
      LShort := LOption.Flag;
      LLong := LOption.Name;
    end
    else
    begin
      LShort := RemoveStartingDashes(LArray[I]);
      LLong := RemoveStartingDashes(LArray[I]);
    end;

    for J := 0 to Length(LArray) - 1 do
    begin
      LRawOption := RemoveStartingDashes(LArray[J]);
      if (I <> J) and (SameText(LShort, LRawOption) or SameText(LLong, LRawOption)) then
      begin
        LMessage := Format('Duplicate options "%s", "%s" provided', [LArray[I], LArray[J]]);
        if (LShort <> LLong) and (LArray[I] <> LArray[J]) then
          LMessage := LMessage +
            Format('. Option -%s is equivalent to --%s', [LShort, LLong]);
          
        AppendToArray(FResult, LMessage);
        Exit(FResult);
      end;
    end;
  end;

  Result := inherited Validate(ACommand);
end;

function TProvidedArgumentsAreNotValid.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  if (Length(ACommand.Commands) > 0) and 
     (ACommand.GetCommandsFound = 0) and 
     (Length(ACommand.GetRawArguments) > 0) then
  begin
    AppendToArray(FResult, 'Provided arguments are not valid.');
    Exit(FResult);
  end;

  Result := inherited Validate(ACommand);
end;

function TProvidedArgumentsAreNotRequired.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  if (Length(ACommand.Commands) > 0) and
     (Assigned(ACommand.CommandSelected)) and
     (ccNoArgumentsButCommands in ACommand.CommandSelected.Constraints) and
     ( (Length(ACommand.GetRawArguments)  
        - ACommand.GetCommandsFound 
        - Length(ACommand.Arguments)) > 0) then
  begin
    AppendToArray(FResult, 'Provided arguments are not required.');
    Exit(FResult);
  end;

  Result := inherited Validate(ACommand);
end;

function TProvidedArgumentsExceedsAcceptedLimit.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  if (Length(ACommand.Commands) > 0) and 
     (ACommand.GetCommandsFound = 1) and 
     ((Length(ACommand.GetRawArguments) - 1) > Length(ACommand.Arguments)) then
  begin
    AppendToArray(FResult, 
        Format('Provided arguments for "%s" is greater thant accepted number',
        [ACommand.CommandSelected.Name]));
    Exit(FResult);
  end;

  Result := inherited Validate(ACommand);
end;

function TSelectedCommandDoesNotAcceptCommandAsArgument.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  if (Length(ACommand.Commands) > 0) and 
     (ACommand.GetCommandsFound > 1) and 
     (not (ccNoArgumentsButCommands in ACommand.CommandSelected.Constraints)) then
  begin
    AppendToArray(FResult, 
        Format('Command "%s" does not accept another command as argument',
        [ACommand.CommandSelected.Name]));
    Exit(FResult);
  end;

  Result := inherited Validate(ACommand);
end;

function TSelectedCommandRequiresValidCommandOrNothing.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  if (Assigned(ACommand.CommandSelected)) and 
     (ccNoArgumentsButCommands in ACommand.CommandSelected.Constraints) and
     ((not Assigned(ACommand.CommandAsArgument)) or (Length(ACommand.GetRawArguments) > 2)) and 
     (Length(ACommand.GetRawArguments) > 1) then
  begin
    AppendToArray(FResult, 
        Format('Command "%s" requires one valid command as an argument or nothing',
        [ACommand.CommandSelected.Name]));
    Exit(FResult);
  end;

  Result := inherited Validate(ACommand);
end;

function TSelectedCommandRequiresOneArguments.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  if (Assigned(ACommand.CommandSelected)) and 
     (ccRequiresOneArgument in ACommand.CommandSelected.Constraints) and
     (
       ((Assigned(ACommand.CommandAsArgument)) and (Length(ACommand.GetRawArguments) < 3)) or
       ((not Assigned(ACommand.CommandAsArgument)) and (Length(ACommand.GetRawArguments) < 2))
     ) then
  begin
    AppendToArray(FResult, 
        Format('Command "%s" requires an argument as parameter',
        [ACommand.CommandSelected.Name]));
    Exit(FResult);
  end;

  Result := inherited Validate(ACommand);
end;

function TSelectedCommandRequiresNoArguments.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  if Assigned(ACommand.CommandSelected) and 
     (ccNoParameters in ACommand.CommandSelected.Constraints) and 
     (Length(ACommand.GetRawArguments) > 1) then
  begin
    AppendToArray(FResult, 
        Format('Command "%s" requires no arguments.',
        [ACommand.CommandSelected.Name]));
    Exit(FResult);
  end;
  Result := inherited Validate(ACommand);
end;

function TSelectedCommandValidateIfOptionsExists.Validate(ACommand: ICommandBuilder): TArray<string>;
var
  I: Integer;
  LParsedOptions: TArray<string>;
  LOptionCleaned: string;
  LOptionFound: Boolean;
  LOption: IOption;
  LCommand: ICommand;
begin
  LCommand := ACommand.CommandSelected;
  if not Assigned(LCommand) then
    LCommand := ACommand.GetDefaultCommand;

  if Assigned(LCommand) then
  begin
    LParsedOptions := ACommand.GetRawOptions;
    
    for I := 0 to Length(LParsedOptions) - 1 do
    begin
      LOptionCleaned := Copy(LParsedOptions[I], 2, 30);
      if StartsText('-', LOptionCleaned) then
        LOptionCleaned := Copy(LOptionCleaned, 2, 30);

      LOptionFound := False;
      for LOption in LCommand.Options do
      begin
        if SameText(LOptionCleaned, LOption.Flag) or SameText(LOptionCleaned, LOption.Name) then
        begin
          LOptionFound := True;
          Break;
        end;
      end;

      if not LOptionFound then
      begin
        AppendToArray(FResult, 
          Format('Command "%s" invalid. Option not found: %s',
          [LCommand.Name, LParsedOptions[I]])
        );
        Exit(FResult); 
      end;
    end;
  end;

  Result := inherited Validate(ACommand);
end;

function TSelectedCommandValidateRejectedOption.Validate(ACommand: ICommandBuilder): TArray<string>;
var
  I: Integer;
  LParsedOptions: TArray<string>;
  LOptionCleaned: string;
  LOption: IOption;
  LCommand: ICommand;
  LReject: string;
begin
  LCommand := ACommand.CommandSelected;
  if not Assigned(LCommand) then
    LCommand := ACommand.GetDefaultCommand;

  if Assigned(LCommand) then
  begin
    LParsedOptions := ACommand.GetRawOptions;
    
    for I := 0 to Length(LParsedOptions) - 1 do
    begin
      LOptionCleaned := Copy(LParsedOptions[I], 2, 30);
      if StartsText('-', LOptionCleaned) then
        LOptionCleaned := Copy(LOptionCleaned, 2, 30);

      for LOption in LCommand.Options do
      begin
        if AnsiMatchText(LOptionCleaned, [LOption.Flag, LOption.Name]) then
        begin
          for LReject in LOption.NotAllowedFlags do
          begin
            if AnsiMatchText('-' + LReject, LParsedOptions) then
            begin
              AppendToArray(FResult, 
                Format('Command "%s" invalid. Option "-%s" cannot be used with "-%s"',
                [LCommand.Name, LOption.Flag, LReject])
              );
              Exit(FResult); 
            end;
          end;
        end;
      end;
    end;
  end;
  Result := inherited Validate(ACommand);
end;

end.