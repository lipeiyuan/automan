unit Stock;

{$mode ObjFPC}{$H+}
{$ModeSwitch ArrayOperators}

interface

uses
  Classes, SysUtils;

type
  TCompany = record
    Code: string;
    LotCount: currency;
  end;

  TUnitPriceStep = record
    left: currency;
    right: currency;
    step: currency;
  end;

  TTrade = class
  private
    FPrice: currency;
    FCount: currency;
    FAmount: currency;
    FCost: currency;
    FCompany: TCompany;
  end;

const
  UnitPriceOfStock: array of TUnitPriceStep = ();

function GetUnitPrice(price: currency): currency;
function GetCost(price, Count: currency): currency;


implementation

uses Utils, Windows;

// 佣金，最低3
function GetComissionFee(amount: currency): currency;
var
  cost: currency;
  minCost: currency;
begin
  minCost := StrToCurr('3');

  // 0.03%
  cost := amount * StrToCurr('0.0003');
  cost := Utils.MaxCurrency(cost, minCost);
  Exit(cost);
end;

// 平台使用费
function GetPlatformFee(cost: currency): currency;
begin
  Exit(StrToCurr('15'));
end;

// 交收费（香港结算所），最低2，最高100
function GetCCASSFee(amount: currency): currency;
var
  cost: currency;
  minCost, maxCost: currency;
begin
  minCost := StrToCurr('2');
  maxCost := StrToCurr('100');

  // 0.002%
  cost := amount * StrToCurr('0.002') * StrToCurr('0.01');
  cost := Utils.RoundRange(cost, minCost, maxCost);
  Exit(cost);
end;

// 印花税，不足1按1
function GetStampDuty(amount: currency): currency;
var
  cost: currency;
begin
  // 0.1%
  cost := amount * StrToCurr('0.001');
  cost := Utils.RoundCeilInt(cost);
  Exit(cost);
end;

// 交易费（相关交易所），最低0.01
function GetHKEXTradingFee(amount: currency): currency;
var
  cost: currency;
  minCost: currency;
begin
  minCost := StrToCurr('0.01');

  // 0.00565%
  cost := amount * StrToCurr('0.0565') * StrToCurr('0.001');
  cost := Utils.MaxCurrency(cost, minCost);
  Exit(cost);
end;

// 证监会征费，最低0.01
function GetSFCTransactionLevy(amount: currency): currency;
var
  cost: currency;
  minCost: currency;
begin
  minCost := StrToCurr('0.01');

  // 0.0027%
  cost := amount * StrToCurr('0.0027') * StrToCurr('0.01');
  cost := Utils.MaxCurrency(cost, minCost);
  Exit(cost);
end;

// 财汇局征费
function GetFRCTransactionLevy(amount: currency): currency;
var
  cost: currency;
begin
  // 0.00015%
  cost := amount * StrToCurr('0.0015') * StrToCurr('0.001');
  Exit(cost);
end;

// 获取交易手续费
function GetCost(price, Count: currency): currency;
var
  cost: currency = 0;
begin
  cost += Utils.RoundArithmetic(GetComissionFee(price * Count));
  cost += Utils.RoundArithmetic(GetPlatformFee(price * Count));
  cost += Utils.RoundArithmetic(GetCCASSFee(price * Count));
  cost += Utils.RoundArithmetic(GetStampDuty(price * Count));
  cost += Utils.RoundArithmetic(GetHKEXTradingFee(price * Count));
  cost += Utils.RoundArithmetic(GetSFCTransactionLevy(price * Count));
  cost += Utils.RoundArithmetic(GetFRCTransactionLevy(price * Count));

  {$ifdef _AUTOMAN_DEBUG}
  AllocConsole;      // in Windows unit
  IsConsole := True; // in System unit
  SysInitStdIO;      // in System unit
  Writeln(format(
    'get cost, price:%s count:%s ComissionFee:%s PlatformFee:%s CCASSFee:%s StampDuty:%s HKEXTradingFee:%s SFCTransactionLevy:%s FRCTransactionLevy:%s', [CurrToStr(price), CurrToStr(Count), CurrToStr(GetComissionFee(price * Count)), CurrToStr(GetPlatformFee(price * Count)), CurrToStr(GetCCASSFee(price * Count)), CurrToStr(GetStampDuty(price * Count)), CurrToStr(GetHKEXTradingFee(price * Count)), CurrToStr(GetSFCTransactionLevy(price * Count)), CurrToStr(GetFRCTransactionLevy(price * Count))]));
  {$endif}

  cost := Utils.RoundArithmetic(cost);
  Exit(cost);
end;

procedure Init();
var
  unitArr: array of array of string = (('0.01', '0.25', '0.001'),
    ('0.25', '0.5', '0.005'), ('0.5', '10', '0.01'), ('10', '20', '0.02'),
    ('20', '100', '0.05'), ('100', '200', '0.1'), ('200', '500', '0.2'),
    ('500', '1000', '0.5'), ('1000', '2000', '1'), ('2000', '5000', '2'),
    ('5000', '9995', '5'));
  strArr: array of string;
  step: TUnitPriceStep;
begin
  for strArr in unitArr do
  begin
    step.left := StrToCurr(strArr[0]);
    step.right := StrToCurr(strArr[1]);
    step.step := StrToCurr(strArr[2]);
    UnitPriceOfStock += [step];
  end;
end;

function GetUnitPrice(price: currency): currency;
var
  step: TUnitPriceStep;
begin
  for step in UnitPriceOfStock do
  begin
    if (price > step.left) and (price <= step.right) then
      Exit(step.step);
  end;

  Assert(False, format('wrong price! %s', [CurrToStr(price)]));
end;

initialization
  Init;

end.
