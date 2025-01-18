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
    Left: currency;
    Right: currency;
    Step: currency;
  end;

  TTrade = class
  private
    FPrice: currency;
    FCount: currency;
    FAmount: currency;
    FCost: currency;
    FCompany: TCompany;

  public
    constructor Create(Price, Count: currency; Company: TCompany);
  public
    property Price: currency read FPrice;
    property Count: currency read FCount;
    property Amount: currency read FAmount;
    property Cost: currency read FCost;
    property Company: TCompany read FCompany;
  end;

const
  UnitPriceOfStock: array of TUnitPriceStep = ();

function GetUnitPrice(Price: currency): currency;
function GetCost(Price, Count: currency): currency;


implementation

uses
  {$ifdef _AUTOMAN_DEBUG}
  Windows,
  {$endif}
  Utils;

constructor TTrade.Create(Price, Count: currency; Company: TCompany);
begin
  Self.FPrice := Price;
  Self.FCount := Count;
  Self.FAmount := Price * Count;
  Self.FCost := GetCost(Price, Count);
  Self.FCompany := Company;
end;

// 佣金，最低3
function GetComissionFee(Amount: currency): currency;
var
  Cost: currency;
  MinCost: currency;
begin
  MinCost := StrToCurr('3');

  // 0.03%
  Cost := Amount * StrToCurr('0.0003');
  Cost := Utils.MaxCurrency(Cost, MinCost);
  Exit(Cost);
end;

// 平台使用费
function GetPlatformFee(Cost: currency): currency;
begin
  Exit(StrToCurr('15'));
end;

// 交收费（香港结算所），最低2，最高100
function GetCCASSFee(Amount: currency): currency;
var
  Cost: currency;
  MinCost, MaxCost: currency;
begin
  MinCost := StrToCurr('2');
  MaxCost := StrToCurr('100');

  // 0.002%
  Cost := Amount * StrToCurr('0.002') * StrToCurr('0.01');
  Cost := Utils.RoundRange(Cost, MinCost, MaxCost);
  Exit(Cost);
end;

// 印花税，不足1按1
function GetStampDuty(Amount: currency): currency;
var
  Cost: currency;
begin
  // 0.1%
  Cost := Amount * StrToCurr('0.001');
  Cost := Utils.RoundCeilInt(Cost);
  Exit(Cost);
end;

// 交易费（相关交易所），最低0.01
function GetHKEXTradingFee(Amount: currency): currency;
var
  Cost: currency;
  MinCost: currency;
begin
  MinCost := StrToCurr('0.01');

  // 0.00565%
  Cost := Amount * StrToCurr('0.0565') * StrToCurr('0.001');
  Cost := Utils.MaxCurrency(Cost, MinCost);
  Exit(Cost);
end;

// 证监会征费，最低0.01
function GetSFCTransactionLevy(Amount: currency): currency;
var
  Cost: currency;
  MinCost: currency;
begin
  MinCost := StrToCurr('0.01');

  // 0.0027%
  Cost := Amount * StrToCurr('0.0027') * StrToCurr('0.01');
  Cost := Utils.MaxCurrency(Cost, MinCost);
  Exit(Cost);
end;

// 财汇局征费
function GetFRCTransactionLevy(Amount: currency): currency;
var
  Cost: currency;
begin
  // 0.00015%
  Cost := Amount * StrToCurr('0.0015') * StrToCurr('0.001');
  Exit(Cost);
end;

// 获取交易手续费
function GetCost(Price, Count: currency): currency;
var
  cost: currency = 0;
begin
  cost += Utils.RoundArithmetic(GetComissionFee(Price * Count));
  cost += Utils.RoundArithmetic(GetPlatformFee(Price * Count));
  cost += Utils.RoundArithmetic(GetCCASSFee(Price * Count));
  cost += Utils.RoundArithmetic(GetStampDuty(Price * Count));
  cost += Utils.RoundArithmetic(GetHKEXTradingFee(Price * Count));
  cost += Utils.RoundArithmetic(GetSFCTransactionLevy(Price * Count));
  cost += Utils.RoundArithmetic(GetFRCTransactionLevy(Price * Count));

  // for console output
  {$ifdef _AUTOMAN_DEBUG}
  AllocConsole;      // in Windows unit
  IsConsole := True; // in System unit
  SysInitStdIO;      // in System unit
  Writeln(format(
    'get cost, price:%s count:%s ComissionFee:%s PlatformFee:%s CCASSFee:%s StampDuty:%s HKEXTradingFee:%s SFCTransactionLevy:%s FRCTransactionLevy:%s',
    [CurrToStr(price), CurrToStr(Count),
    CurrToStr(GetComissionFee(price * Count)),
    CurrToStr(GetPlatformFee(price * Count)),
    CurrToStr(GetCCASSFee(price * Count)),
    CurrToStr(GetStampDuty(price * Count)),
    CurrToStr(GetHKEXTradingFee(price * Count)),
    CurrToStr(GetSFCTransactionLevy(price * Count)),
    CurrToStr(GetFRCTransactionLevy(price * Count))]));
  {$endif}

  cost := Utils.RoundArithmetic(cost);
  Exit(cost);
end;

procedure Init;
var
  UnitArray: array of array of
  string = (('0.01', '0.25', '0.001'), ('0.25', '0.5', '0.005'),
    ('0.5', '10', '0.01'), ('10', '20', '0.02'), ('20', '100', '0.05'),
    ('100', '200', '0.1'), ('200', '500', '0.2'), ('500', '1000', '0.5'),
    ('1000', '2000', '1'), ('2000', '5000', '2'), ('5000', '9995', '5'));
  StrArray: array of string;
  Step: TUnitPriceStep;
begin
  for StrArray in UnitArray do
  begin
    Step.Left := StrToCurr(StrArray[0]);
    Step.Right := StrToCurr(StrArray[1]);
    Step.Step := StrToCurr(StrArray[2]);
    UnitPriceOfStock += [Step];
  end;
end;

function GetUnitPrice(Price: currency): currency;
var
  Step: TUnitPriceStep;
begin
  for Step in UnitPriceOfStock do
  begin
    if (Price > Step.Left) and (Price <= Step.Right) then
      Exit(Step.Step);
  end;

  Assert(False, format('wrong price! %s', [CurrToStr(Price)]));
end;

initialization
  Init;

end.
