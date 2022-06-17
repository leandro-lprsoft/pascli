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
  Command.Usage;
```

* **Basic implementation**

```pascal
var
  Application: TCommandApp;

procedure HelloCommand(ABuilder: ICommandBuilder);
begin
  WriteLn('Hello world!');
end;

begin
  Application := TCommandApp.Create(nil);
  Application.Title := 'Basic CLI tool.';
  Application
    .CommandBuilder
      .AddCommand(
          'help', 
          'Shows information about how to use this tool or about a specific command.'#13#10 +
          'Ex: basic help', 
          @UsageCommand, // built in usage command
          [ccDefault, ccNoArgumentsButCommands])
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
* Easy to fast setup a robust CLI tool using the AddCommand method. Just create your handler like the following example: 
```pascal
procedure MyCommand(ABuilder: ICommandBuilder);
begin
  // my code
end;
```
* Built-in constraints to validate allowed commands, allowed options, not allowed options, and arguments.
* Command usage out of the box, outputs command information for a given command or general usage of the tool. Just add Command.Usage unit to the uses clause and setup a command for UsageCommand procedure using AddCommand method.
* This library is unit tested.


## License

`pascli` is free and open-source software licensed under the [MIT License](https://github.com/leandro-lprsoft/pascli/blob/master/LICENSE). 