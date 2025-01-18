unit TestCaseUtils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry;

type

  TTestCaseUtils = class(TTestCase)
  published
    procedure TestUtils;
    procedure TestFee;
    procedure TestRound;
  end;

implementation

uses
  Utils, Stock, Math;

procedure TTestCaseUtils.TestUtils;
var
  a, b: currency;
begin
  a := StrToCurr('0.1');
  b := StrToCurr('0.1');
  AssertEquals(Utils.MaxCurrency(a, b), a);

  a := StrToCurr('0.1');
  b := StrToCurr('0.1');
  AssertEquals(Utils.MaxCurrency(a, b), b);

  a := StrToCurr('0.1');
  b := StrToCurr('0.01');
  AssertEquals(Utils.MaxCurrency(a, b), a);

  a := StrToCurr('0.0001');
  b := StrToCurr('0.0002');
  AssertEquals(Utils.MaxCurrency(a, b), b);

  a := StrToCurr('0.1');
  b := StrToCurr('0.1');
  AssertEquals(Utils.MinCurrency(a, b), a);

  a := StrToCurr('0.1');
  b := StrToCurr('0.1');
  AssertEquals(Utils.MinCurrency(a, b), b);

  a := StrToCurr('0.1');
  b := StrToCurr('0.01');
  AssertEquals(Utils.MinCurrency(a, b), b);

  a := StrToCurr('0.0001');
  b := StrToCurr('0.0002');
  AssertEquals(Utils.MinCurrency(a, b), a);
end;

procedure TTestCaseUtils.TestFee;
var
  DataArray: array of array of
  string = (('386.8', '600', '341.99'), ('413.2', '600', '363.41'),
    ('417.8', '600', '367.52'), ('413.8', '600', '364.55'));
  Trade: array of string;
  Price, Count, Cost: currency;
begin
  for Trade in DataArray do
  begin
    Price := StrToCurr(Trade[0]);
    Count := StrToCurr(Trade[1]);
    Cost := StrToCurr(Trade[2]);
    AssertEquals(format('test trade: price: %s count:%s cost:%s',
      [Trade[0], Trade[1], Trade[2]]), Cost, Stock.GetCost(Price, Count));
  end;
end;

procedure TTestCaseUtils.TestRound;
var
  Tmp: currency;
  a, b: currency;
begin
  Tmp := StrToCurr('0.0001');
  Tmp := Utils.RoundDown(Tmp, 2);
  AssertEquals(Tmp, StrToCurr('0'));

  Tmp := StrToCurr('0.01');
  Tmp := Utils.RoundDown(Tmp, -2);
  AssertEquals(Tmp, StrToCurr('0.01'));

  Tmp := StrToCurr('123456.01');
  Tmp := Utils.RoundDown(Tmp, -2);
  AssertEquals(Tmp, StrToCurr('123456.01'));

  Tmp := StrToCurr('123456.015');
  Tmp := Utils.RoundDown(Tmp, -2);
  AssertEquals(Tmp, StrToCurr('123456.01'));

  Tmp := StrToCurr('123456.0145');
  Tmp := Utils.RoundDown(Tmp, -2);
  AssertEquals(Tmp, StrToCurr('123456.01'));

  Tmp := StrToCurr('123456.0155');
  Tmp := Utils.RoundDown(Tmp, -2);
  AssertEquals(Tmp, StrToCurr('123456.01'));

  Tmp := StrToCurr('123456.0');
  Tmp := Utils.RoundDown(Tmp, -2);
  AssertEquals(Tmp, StrToCurr('123456.0'));

  Tmp := StrToCurr('123456.0001');
  Tmp := Utils.RoundDown(Tmp, -2);
  AssertEquals(Tmp, StrToCurr('123456.0'));

  Tmp := StrToCurr('123456.011');
  Tmp := Utils.RoundUp(Tmp, -2);
  AssertEquals(Tmp, StrToCurr('123456.02'));

  Tmp := StrToCurr('2.5');
  Tmp := Math.RoundTo(Tmp, 0);
  AssertEquals(Tmp, StrToCurr('2'));

  Tmp := StrToCurr('2.5');
  Tmp := Utils.RoundArithmetic(Tmp, 0);
  AssertEquals(Tmp, StrToCurr('3'));

  Tmp := StrToCurr('2.4');
  Tmp := Utils.RoundArithmetic(Tmp, 0);
  AssertEquals(Tmp, StrToCurr('2'));

  Tmp := StrToCurr('-2.4');
  Tmp := Utils.RoundArithmetic(Tmp, 0);
  AssertEquals(Tmp, StrToCurr('-2'));

  Tmp := StrToCurr('-2.5');
  Tmp := Utils.RoundArithmetic(Tmp, 0);
  AssertEquals(Tmp, StrToCurr('-3'));

  Tmp := StrToCurr('-2.445');
  Tmp := Utils.RoundArithmetic(Tmp, -2);
  AssertEquals(Tmp, StrToCurr('-2.45'));

  Tmp := StrToCurr('-2124.545');
  Tmp := Utils.RoundArithmetic(Tmp, 0);
  AssertEquals(Tmp, StrToCurr('-2125'));

  a := StrToCurr('1.0001');
  b := StrToCurr('2.0009');
  Tmp := StrToCurr('1.0005');
  AssertEquals(Utils.RoundRange(Tmp, a, b), Tmp);

  a := StrToCurr('1.0001');
  b := StrToCurr('2.0009');
  Tmp := StrToCurr('1.0005');
  AssertEquals(Utils.RoundRange(Tmp, b, a), Tmp);

  a := StrToCurr('1.0001');
  b := StrToCurr('2.0009');
  Tmp := StrToCurr('3.0005');
  AssertEquals(Utils.RoundRange(Tmp, b, a), b);

  a := StrToCurr('1.0001');
  b := StrToCurr('2.0009');
  Tmp := StrToCurr('-0.124');
  AssertEquals(Utils.RoundRange(Tmp, b, a), a);

end;

initialization
  RegisterTest(TTestCaseUtils);
end.
