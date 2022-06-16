unit Command.Helpers;

{$MODE DELPHI}{$H+}

interface

  /// appends a string to an array of string increasing its size
  procedure AppendToArray(var AArray: TArray<string>; const AText: string);

  /// remove starting dashes from shot option or long option
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