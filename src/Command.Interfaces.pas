unit Command.Interfaces;

{$MODE DELPHI}{$H+}

interface

uses
  CustApp,
  Classes;

type
  {$M+}
  /// foward declarations
  IOption = interface;
  ICommand = interface;
  IArgument = interface;
  ICommandBuilder = interface;
  IValidatorContext = interface;
  IValidatorBase = interface;

  /// Command constraints enum
  TCommandConstraint = (ccDefault, ccRequiresOneArgument, ccRequiresOneOption, ccNoArgumentsButCommands,
    ccNoParameters);
  TCommandConstraints = set of TCommandConstraint;

  /// Arguments constraints enum
  TArgumentConstraint = (acRequired, acOptional);

  /// callback that will be called if a combination of commands and options is satisfied.
  TCommandCallback = procedure (ABuilder: ICommandBuilder);

  /// callback that will be used to print out any info like command usage or message validations
  TOutputCallback = procedure (const AMessage: string);

  /// option
  IOption = interface
    ['{C24CC7B9-946E-44AA-BF92-CE89592F0940}']  

    /// letter option that will bu used as a option flag for a given command or a direct option
    function GetFlag: string;
    procedure SetFlag(const AValue: string);
    property Flag: string read GetFlag write SetFlag;

    /// option name that will bu used as a option argument for a given command.
    function GetName: string;
    procedure SetName(const AValue: string);
    property Name: string read GetName write SetName;

    /// command description that will be displayed on usage examples
    function GetDescription: string;
    procedure SetDescription(const AValue: string);
    property Description: string read GetDescription write SetDescription;     

    /// not allowed flags to use with this option
    procedure SetNotAllowedFlags(const Value: TArray<string>);
    function GetNotAllowedFlags: TArray<string>;
    property NotAllowedFlags: TArray<string> read GetNotAllowedFlags write SetNotAllowedFlags;

  end;

  /// command
  ICommand = interface
    ['{AD920381-6441-48B1-B035-19694D0417A2}']

    /// command name that will bu used as a command line argument
    function GetName: string;
    procedure SetName(const AValue: string);
    property Name: string read GetName write SetName;

    /// command description that will be displayed on usage examples
    function GetDescription: string;
    procedure SetDescription(const AValue: string);
    property Description: string read GetDescription write SetDescription;    

    /// callback procedure that will be called if this command was provided
    function GetCallback: TCommandCallback;
    procedure SetCallback(AValue: TCommandCallback);
    property Callback: TCommandCallback read GetCallback write SetCallback;

    /// command constraints what will be checked before execute the callback procedure
    function GetConstraints: TCommandConstraints;
    procedure SetConstraints(const AValue: TCommandConstraints);
    property Constraints: TCommandConstraints read GetConstraints write SetConstraints;

    /// options related to this command
    function GetOption(const AIndex: string): IOption;
    property Option[const AIndex: string]: IOption read GetOption;

    function GetOptions: TArray<IOption>;    
    property Options: TArray<IOption> read GetOptions;

    // returns true if command accept options
    function HasOptions: Boolean;
    
    /// allow to add na option to this command
    function AddOption(const AFlag, AName, ADescription: string; ANotAllowedFlags: TArray<string> = nil
      ): IOption;

  end;

  /// argument
  IArgument = interface
    ['{930DA68E-6B31-4A05-A20E-C0056BFDE1AA}']

    /// argument description that will be displayed on usage examples
    function GetDescription: string;
    procedure SetDescription(const AValue: string);
    property Description: string read GetDescription write SetDescription;    

    /// argument constraints what will be checked before execute the callback procedure
    function GetConstraint: TArgumentConstraint;
    procedure SetConstraint(const AValue: TArgumentConstraint);
    property Constraint: TArgumentConstraint read GetConstraint write SetConstraint;

    /// returns the value of argument provided via parameter, this value should assigned after parse
    function GetValue: string;
    procedure SetValue(const AValue: string);
    property Value: string read GetValue write SetValue;

  end;

  /// command and options builder
  ICommandBuilder = interface
    ['{5CD580B0-B965-4467-B665-CDFDF61651F1}']

    /// adds a command to the console application
    function AddCommand(const ACommand, ADescription: string; ACallback: TCommandCallback; 
      AConstraints: TCommandConstraints): ICommandBuilder;

    /// returns a list of commands configured on builder
    function GetCommands: TArray<ICommand>;    
    /// returns a list of commands configured on builder
    property Commands: TArray<ICommand> read GetCommands;

    /// returns the number of commands matched against passed arguments
    function GetCommandsFound: Integer;

    /// returns the default command if one was set
    function GetDefaultCommand: ICommand;

    /// adds an argument parameter that can be required or optional
    function AddArgument(const ADescription: string; AConstraint: TArgumentConstraint): ICommandBuilder;    

    /// returns a list of argumetns configured on builder
    function GetArguments: TArray<IArgument>;
    /// allow access to the arguments list
    property Arguments: TArray<IArgument> read GetArguments;

    /// adds an option to the application or to the last command that was added.
    /// specifies a short flag, an option name and the description of this option
    function AddOption(const AFlag, AName, ADescription: string; ANotAllowedFlags: TArray<string> = nil
      ): ICommandBuilder;

    /// parse supplied commands and arguments
    procedure Parse;

    /// validate supplied command and arguments
    procedure Validate;

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

    /// build a list of IOptions related to selected command
    function GetParsedOptions: TArray<IOption>;    

    /// returns a list of IOptions related to selected command
    property ParsedOptions: TArray<IOption> read GetParsedOptions;

    /// checks if a specific option was provided as a parameter
    function CheckOption(const AOption: string): Boolean;

    /// build a list of IArguments related to selected command, if there are more than one argument
    /// provided the list will match one argument parameter by order of the command builder construction
    function GetParsedArguments: TArray<IArgument>;    

    /// returns a list of IArgument related to selected command
    property ParsedArguments: TArray<IArgument> read GetParsedArguments;

    /// returns a list of raw arguments passed as parameters
    function GetRawArguments: TArray<string>;

    /// returns a list of raw options passed as parameters
    function GetRawOptions: TArray<string>;

    /// returns exe name that will be used as command line shell name to start the application
    function ExeName: string;

    /// returns if builder has at least one command defined
    function HasCommands: Boolean;

    /// returns if builder has at least one argument defined
    function HasArguments: Boolean;

    /// returns if builder has any option set on root or in any command
    function HasOptions: Boolean;

    /// output callback procedure that will be called to print command usage and messages validation
    function GetOutput: TOutputCallback;
    procedure SetOutput(AValue: TOutputCallback);
    property Output: TOutputCallback read GetOutput write SetOutput;

    /// allows to inject external arguments instead of reading from ParamStr()
    function UseArguments(AArguments: TArray<string>): ICommandBuilder;

  end;

  /// IValidatorContext
  IValidatorContext = interface
    ['{72A67B7E-E243-447D-9AB1-D1A6883FE425}']

    /// adds an IValidatorBase and sets it as a Sucessor validator for previous one added
    function Add(AValidator: IValidatorBase): IValidatorContext;

    /// Handle validation from first added IValidatorBase
    function HandleValidation(ACommand: ICommandBuilder): TArray<string>;

    /// function validates all instances of IValidatorBase and returns an array of erros
    function Validate(ACommand: ICommandBuilder): TArray<string>;

  end;

  /// IValidatorBase
  IValidatorBase = interface
    ['{223310E5-CDB9-4BCF-B87B-599384ADF983}']

    /// returns the value of argument provided via parameter, this value should assigned after parse
    function GetSucessor: IValidatorBase;
    procedure SetSucessor(const AValue: IValidatorBase);
    property Sucessor: IValidatorBase read GetSucessor write SetSucessor;

    /// function validate a single case and if a sucessor was supplied call its validate method
    function Validate(ACommand: ICommandBuilder): TArray<string>;

  end;


implementation

end.