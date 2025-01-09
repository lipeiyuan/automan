unit Utils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Math;

function MaxCurrency(a, b: currency): currency;
function MinCurrency(a, b: currency): currency;
function RoundDown(Value: currency; digits: Math.TRoundToRange = -2): currency;
function RoundUp(Value: currency; digits: Math.TRoundToRange = -2): currency;
function RoundArithmetic(Value: currency; digits: Math.TRoundToRange = -2): currency;
function RoundRange(cost, minCost, maxCost: currency): currency;
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

function RoundCurrencyTo(Value: currency; digits: Math.TRoundToRange;
  roundMode: TFPURoundingMode; roundType: TRoundType): currency;
var
  ret, tmp: currency;
  oldRoundMode: TFPURoundingMode;
  newDigits: Math.TRoundToRange;
begin
  tmp := StrToCurr('10000');

  ret := Value * tmp;
  newDigits := digits + 4;

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

function RoundDown(Value: currency; digits: Math.TRoundToRange = -2): currency;
begin
  Exit(RoundCurrencyTo(Value, digits, TFPURoundingMode.rmDown, TRoundType.rtDefault));
end;

function RoundUp(Value: currency; digits: Math.TRoundToRange = -2): currency;
begin
  Exit(RoundCurrencyTo(Value, digits, TFPURoundingMode.rmUp, TRoundType.rtDefault));
end;

function RoundArithmetic(Value: currency; digits: Math.TRoundToRange = -2): currency;
begin
  Exit(RoundCurrencyTo(Value, digits, TFPURoundingMode.rmNearest,
    TRoundType.rtArithmetic));
end;

function RoundRange(cost, minCost, maxCost: currency): currency;
var
  tmp: currency;
begin
  if minCost > maxCost then
  begin
    tmp := minCost;
    minCost := maxCost;
    maxCost := tmp;
  end;

  tmp := MaxCurrency(minCost, cost);
  tmp := MinCurrency(maxCost, tmp);
  Exit(tmp);
end;

function RoundCeilInt(Value: currency): currency;
var
  digits: Math.TRoundToRange = 0;
begin
  Exit(RoundUp(Value, digits));
end;

end.
