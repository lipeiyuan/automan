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
  dataArray: array of array of
  string = (('386.8', '600', '341.99'), ('413.2', '600', '363.41'),
    ('417.8', '600', '367.52'), ('413.8', '600', '364.55'));
  trade: array of string;
  price, Count, cost: currency;
begin
  for trade in dataArray do
  begin
    price := StrToCurr(trade[0]);
    Count := StrToCurr(trade[1]);
    cost := StrToCurr(trade[2]);
    AssertEquals(format('test trade: price: %s count:%s cost:%s',
      [trade[0], trade[1], trade[2]]), Cost, Stock.GetCost(price, Count));
  end;
end;

procedure TTestCaseUtils.TestRound;
var
  tmp: currency;
  a, b: currency;
begin
  tmp := StrToCurr('0.0001');
  tmp := Utils.RoundDown(tmp, 2);
  AssertEquals(tmp, StrToCurr('0'));

  tmp := StrToCurr('0.01');
  tmp := Utils.RoundDown(tmp, -2);
  AssertEquals(tmp, StrToCurr('0.01'));

  tmp := StrToCurr('123456.01');
  tmp := Utils.RoundDown(tmp, -2);
  AssertEquals(tmp, StrToCurr('123456.01'));

  tmp := StrToCurr('123456.015');
  tmp := Utils.RoundDown(tmp, -2);
  AssertEquals(tmp, StrToCurr('123456.01'));

  tmp := StrToCurr('123456.0145');
  tmp := Utils.RoundDown(tmp, -2);
  AssertEquals(tmp, StrToCurr('123456.01'));

  tmp := StrToCurr('123456.0155');
  tmp := Utils.RoundDown(tmp, -2);
  AssertEquals(tmp, StrToCurr('123456.01'));

  tmp := StrToCurr('123456.0');
  tmp := Utils.RoundDown(tmp, -2);
  AssertEquals(tmp, StrToCurr('123456.0'));

  tmp := StrToCurr('123456.0001');
  tmp := Utils.RoundDown(tmp, -2);
  AssertEquals(tmp, StrToCurr('123456.0'));

  tmp := StrToCurr('123456.011');
  tmp := Utils.RoundUp(tmp, -2);
  AssertEquals(tmp, StrToCurr('123456.02'));

  tmp := StrToCurr('2.5');
  tmp := Math.RoundTo(tmp, 0);
  AssertEquals(tmp, StrToCurr('2'));

  tmp := StrToCurr('2.5');
  tmp := Utils.RoundArithmetic(tmp, 0);
  AssertEquals(tmp, StrToCurr('3'));

  tmp := StrToCurr('2.4');
  tmp := Utils.RoundArithmetic(tmp, 0);
  AssertEquals(tmp, StrToCurr('2'));

  tmp := StrToCurr('-2.4');
  tmp := Utils.RoundArithmetic(tmp, 0);
  AssertEquals(tmp, StrToCurr('-2'));

  tmp := StrToCurr('-2.5');
  tmp := Utils.RoundArithmetic(tmp, 0);
  AssertEquals(tmp, StrToCurr('-3'));

  tmp := StrToCurr('-2.445');
  tmp := Utils.RoundArithmetic(tmp, -2);
  AssertEquals(tmp, StrToCurr('-2.45'));

  tmp := StrToCurr('-2124.545');
  tmp := Utils.RoundArithmetic(tmp, 0);
  AssertEquals(tmp, StrToCurr('-2125'));

  a := StrToCurr('1.0001');
  b := StrToCurr('2.0009');
  tmp := StrToCurr('1.0005');
  AssertEquals(Utils.RoundRange(tmp, a, b), tmp);

  a := StrToCurr('1.0001');
  b := StrToCurr('2.0009');
  tmp := StrToCurr('1.0005');
  AssertEquals(Utils.RoundRange(tmp, b, a), tmp);

  a := StrToCurr('1.0001');
  b := StrToCurr('2.0009');
  tmp := StrToCurr('3.0005');
  AssertEquals(Utils.RoundRange(tmp, b, a), b);

  a := StrToCurr('1.0001');
  b := StrToCurr('2.0009');
  tmp := StrToCurr('-0.124');
  AssertEquals(Utils.RoundRange(tmp, b, a), a);

end;

initialization

  RegisterTest(TTestCaseUtils);
end.
