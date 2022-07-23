/// <summary>This unit contains a set of simple functions that help to perform repetitive 
/// actions related to parsing the arguments passed by the command line. </summary>
unit Command.Helpers;

{$MODE DELPHI}{$H+}

interface

  /// <summary>Appends a string to an array of string automatically increasing its size </summary>
  /// <param name="AArray">Variable of type TArray<string> to which an item will be added.</param>
  /// <param name="AText">String to be added to the array.</param>
  procedure AppendToArray(var AArray: TArray<string>; const AText: string);

  /// <summary>Removes the first "-" and second "-" characters if found from the string passed
  /// as a parameter. Returns a new string without these characters.</summary>
  /// <param name="LOption">String option passed as an argument via the command line that will 
  /// be processed to remove the leading "-".</param>
  function RemoveStartingDashes(const LOption: string): string;
  
implementation

uses
  StrUtils;

procedure AppendToArray(var AArray: TArray<string>; const AText: string);
begin
  SetLength(AArray, Length(AArray) + 1);
  AArray[Length(AArray) - 1] := AText;
end;

function RemoveStartingDashes(const LOption: string): string;
begin
  Result := Copy(LOption, 2, 30);
  if StartsText('-', Result) then
    Result := Copy(Result, 2, 30);
end;

end.