unit Utils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Math;

function MaxCurrency(a, b: currency): currency;
function MinCurrency(a, b: currency): currency;
function RoundDown(Value: currency; Dights: Math.TRoundToRange = -2): currency;
function RoundUp(Value: currency; Dights: Math.TRoundToRange = -2): currency;
function RoundArithmetic(Value: currency; Dights: Math.TRoundToRange = -2): currency;
function RoundRange(Cost, MinCost, MaxCost: currency): currency;
function RoundCeilInt(Value: currency): currency;

implementation

type
  TRoundType = (rtDefault, rtArithmetic);

function MaxCurrency(a, b: currency): currency;
begin
  if a <= b then
    Exit(b)
  else
    Exit(a);
end;

function MinCurrency(a, b: currency): currency;
begin
  if a >= b then
    Exit(b)
  else
    Exit(a);
end;

function RoundCurrencyTo(Value: currency; Dights: Math.TRoundToRange;
  roundMode: TFPURoundingMode; roundType: TRoundType): currency;
var
  ret, tmp: currency;
  oldRoundMode: TFPURoundingMode;
  newDigits: Math.TRoundToRange;
begin
  tmp := StrToCurr('10000');

  ret := Value * tmp;
  newDigits := Dights + 4;

  if roundType = TRoundType.rtDefault then
  begin
    oldRoundMode := Math.SetRoundMode(roundMode);
    ret := Math.RoundTo(ret, newDigits);
    Math.SetRoundMode(oldRoundMode);
  end
  else
    ret := Math.SimpleRoundTo(ret, newDigits);


  ret := ret / tmp;
  Exit(ret);
end;

function RoundDown(Value: currency; Dights: Math.TRoundToRange = -2): currency;
begin
  Exit(RoundCurrencyTo(Value, Dights, TFPURoundingMode.rmDown, TRoundType.rtDefault));
end;

function RoundUp(Value: currency; Dights: Math.TRoundToRange = -2): currency;
begin
  Exit(RoundCurrencyTo(Value, Dights, TFPURoundingMode.rmUp, TRoundType.rtDefault));
end;

function RoundArithmetic(Value: currency; Dights: Math.TRoundToRange = -2): currency;
begin
  Exit(RoundCurrencyTo(Value, Dights, TFPURoundingMode.rmNearest,
    TRoundType.rtArithmetic));
end;

function RoundRange(Cost, MinCost, MaxCost: currency): currency;
var
  Tmp: currency;
begin
  if MinCost > MaxCost then
  begin
    Tmp := MinCost;
    MinCost := MaxCost;
    MaxCost := Tmp;
  end;

  Tmp := MaxCurrency(MinCost, Cost);
  Tmp := MinCurrency(MaxCost, Tmp);
  Exit(Tmp);
end;

function RoundCeilInt(Value: currency): currency;
var
  Dights: Math.TRoundToRange = 0;
begin
  Exit(RoundUp(Value, Dights));
end;

end.
