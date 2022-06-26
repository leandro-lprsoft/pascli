## pascli
Object Pascal CLI library for ease development of command line applications

## Install

* **Manual installation**: Add the following folders to your project search path.

```
../pascli/src
```

* Installation using the [**Boss**](https://github.com/HashLoad/boss):

```
boss install github.com/leandro-lprsoft/pascli
```

## Quickstart

Create a new project on Lazarus and execute "Installation" procedure to update search path and make pascli units visible to the project.

You need to add the following units to the uses clause:

```pascal
uses 
  Command.Interfaces,
  Command.App,
  Command.Usage,
  Command.Version;
```

* **Basic implementation**

```pascal
var
  Application: TCommandApp;

{$R *.res} // important to build version info

procedure HelloCommand(ABuilder: ICommandBuilder);
begin
  WriteLn('Hello world!');
end;

begin
  Application := TCommandApp.Create(nil);
  Application.Title := 'Basic CLI tool.';

  Command.Usage.Registry(Application.CommandBuilder);
  Command.Version.Registry(Application.CommandBuilder);

  Application
    .CommandBuilder
      .AddCommand(
        'hello',
        'Show a hello world message.'#13#10 +
        'Ex: basic hello',
        @HelloCommand,
        [ccNoParameters]);  
  
  Application.Run;
  Application.Free;
end.
``` 

* **Test**

Build the project and try run on console:
```console
./basic help
```

You should see the following output:
```console

Usage: basic.exe [command] 

Commands: 
  help           Shows information about how to use this tool or about a specific command.
                 Ex: basic help
  hello          Show a hello world message.
                 Ex: basic hello

Run 'basic.exe help COMMAND' for more information on a command.

```

## Features

* Works with [command] [short options or long options] [arguments] structure.
* Easy to fast create a CLI tool using the AddCommand method. Just create your handler like the following example: 
```pascal
procedure MyCommand(ABuilder: ICommandBuilder);
begin
  // my code
end;

{...}

Application
  .CommandBuilder
    .AddCommand(
      'mycommand',
      'Excutes MyCommand procedure.'#13#10 +
      'Ex: myapp mycommand',
      @MyCommand,
      [ccNoParameters]);

{...}

```
* Built-in constraints to validate allowed commands, allowed options, not allowed options, and arguments.
* Short flags or long flags using the method add option like the following example:
```pascal
{...}

Application
  .CommandBuilder
    .AddCommand('validate', 'validate file .'#13#10 + 'Ex: myapp validate', @MyCommandValidate, [])
      .AddOption('f', 'full', 'Performs a full validation. Ex: myapp validate --full', ['s'])
      .AddOption('s', 'simple', 'Performs a simple validation. Ex: myapp validate --full', ['f']);

{...}

```
* Command usage out of the box, outputs command information for a given command or general usage of the tool. Just add Command.Usage unit to the uses clause and setup a command for UsageCommand procedure using AddCommand method or use the Registry procedure:
```pascal
Command.Usage.Registry(Application.CommandBuilder);
```
* Command version output procedure (Requires version info of project options). Just add Command.Version unit to the uses clause and setup a command for VersionCommand procedure using AddCommand method or use the Registry procedure:
```pascal
Command.Version.Registry(Application.CommandBuilder);
```
* Console colors output using Command.Colors unit. Check "colors" sample project.
* Full unit test implementation.

## License

`pascli` is free and open-source software licensed under the [MIT License](https://github.com/leandro-lprsoft/pascli/blob/master/LICENSE). 