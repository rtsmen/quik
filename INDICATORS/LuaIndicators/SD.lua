Settings = {
Name = "*SD (Standard Deviation)", 
round = "off",
Period = 20, 
Metod = "SMA", --SMA, EMA, VMA, SMMA, VMA
VType = "Close", --Open, High, Low, Close, Volume, Median, Typical, Weighted, Difference
line = {{
		Name = "SD", 
		Type = TYPE_LINE, 
		Color = RGB(255, 0, 0)
		}
		}
}

function Init() 
	func = SD()
	return #Settings.line
end

function OnCalculate(Index) 
	return func(Index, Settings)
end

function SD() --Standard Deviation ("SD")
	local SD_MA=MA()
return function (I, Fsettings, ds)
local Out = nil
local Fsettings=(Fsettings or {})
local P = (Fsettings.Period or 20)
local M = (Fsettings.Metod or "SMA")
local VT = (Fsettings.VType or "Close")
local R = (Fsettings.round or "off")
local t_ma = SD_MA(I, {Period=P, Metod = M, VType=VT, round=R}, ds)
if I>=P and t_ma then 
	local sum = 0 
		for i = I-P+1, I do
			sum = sum + (Value(i, VT, ds) - t_ma)^2
		end
	Out = math.sqrt(sum / P) 
	return rounding(Out, R) 
else
	return nil
end
end
end

function MA() --Moving Average ("MA")
local t_SMA = F_SMA()
local t_EMA = F_EMA()
local t_VMA = F_VMA()
local t_SMMA = F_SMMA()
local t_WMA = F_WMA()
return function(I, Fsettings, ds)
	local Out = nil
	local Fsettings=(Fsettings or {})
	local P = (Fsettings.Period or 9)
	local M = (Fsettings.Metod or "EMA")
	local VT = (Fsettings.VType or "Close")
	local R = (Fsettings.round or "off")
	if M == "SMA" then
		Out = t_SMA(I, P, VT, ds, R)
	elseif M == "EMA" then
		Out = t_EMA(I, P, VT, ds, R)
	elseif M == "VMA" then
		Out = t_VMA(I, P, VT, ds, R)
	elseif M == "SMMA" then
		Out = t_SMMA(I, P, VT, ds, R)
	elseif M == "WMA" then
		Out = t_WMA(I, P, VT, ds, R)
	else
		Out = nil
	end
	return rounding(Out, R)
end
end
------------------------------------------------------------------
--Moving Average SMA, EMA, VMA, SMMA, VMA
------------------------------------------------------------------
--[[Simple Moving Average (SMA)
SMA = sum(Pi) / n
]]
function F_SMA()
return function (I, Period, VType, ds, round) 
local Out = nil
	if I >= Period then
		local sum = 0
		for i = I-Period+1, I do
			sum = sum +Value(i, VType, ds)
		end
		Out = sum/Period
	end 
	return rounding(Out,round)
end
end

--[[Exponential Moving Average (EMA)
EMAi = (EMAi-1*(n-1)+2*Pi) / (n+1)
]]
function F_EMA() 
local EMA_TMP={}
return function(I, Period, VType, ds, round)
local Out = nil
	if I == 1 then
		EMA_TMP[I]=rounding(Value(I, VType, ds),round)
	else
		EMA_TMP[I]=rounding((EMA_TMP[I-1]*(Period-1)+2*Value(I, VType, ds)) / (Period+1),round)
		EMA_TMP[I-2]=nil
	end
	
	if I >= Period then
		Out = EMA_TMP[I]
	end
	return rounding(Out,round)
end
end

--[[
William Moving Average (WMA)
( Previous WILLMA * ( Period - 1 ) + Data ) / Period
]]
function F_WMA()
	local WMA_TMP={}
return function(I, Period, VType, ds, round)
local Out = nil
   if I == 1 then
      WMA_TMP[I]=rounding(Value(I, VType, ds),round)
   else
      WMA_TMP[I]=rounding((WMA_TMP[I-1]*(Period-1)+Value(I, VType, ds)) / Period,round)
	  WMA_TMP[I-2]=nil
   end
   if I >= Period then
      Out = WMA_TMP[I]
   end
   return rounding(Out,round)
end
end

--[[Volume Adjusted Moving Average (VMA)
VMA = sum(Pi*Vi) / sum(Vi)
]]
function F_VMA()
return function (I, Period, VType, ds, round)
local Out = nil
	if I >= Period then
		local sum = 0
		local sumV = 0
		for i = I-Period+1, I do
			sum = sum +Value(i, VType, ds)*Value(i, "Volume", ds)
			sumV = sumV +Value(i, "Volume", ds)
		end
		Out = sum/sumV
	end
	return rounding(Out,round)
end
end

--[[Smoothed Moving Average (SMMA)
SMMAi = (sum(Pi) - SMMAi-1 + Pi) / n
]]
function F_SMMA()
local SMMA_TMP={}
return function(I, Period, VType, ds, round)
local Out = nil
	if I >= Period then
		local sum = 0
		for i = I-Period+1, I do
			sum = sum +Value(i, VType, ds)
		end
		
		if I == Period then
			SMMA_TMP[I]=rounding((sum-Value(I, VType, ds)+Value(I, VType, ds)) / Period, round)
		else
			SMMA_TMP[I]=rounding((sum-SMMA_TMP[I-1]+Value(I, VType, ds)) / Period, round)
		end
		SMMA_TMP[I-2]=nil
		Out = SMMA_TMP[I]
	end
	return rounding(Out,round)
end
end

function rounding(num, round) 
if round and string.upper(round)== "ON" then round=0 end
if num and tonumber(round) then
	local mult = 10^round
	if num >= 0 then return math.floor(num * mult + 0.5) / mult
	else return math.ceil(num * mult - 0.5) / mult end
else return num end
end

function Value(I,VType,ds) 
local Out = nil
VType=(VType and string.upper(string.sub(VType,1,1))) or "A"
	if VType == "O" then		--Open
		Out = (O and O(I)) or (ds and ds:O(I))
	elseif VType == "H" then 	--High
		Out = (H and H(I)) or (ds and ds:H(I))
	elseif VType == "L" then	--Low
		Out = (L and L(I)) or (ds and ds:L(I))
	elseif VType == "C" then	--Close
		Out = (C and C(I)) or (ds and ds:C(I))
	elseif VType == "V" then	--Volume
		Out = (V and V(I)) or (ds and ds:V(I)) 
	elseif VType == "M" then	--Median
		Out = ((Value(I,"H",ds) + Value(I,"L",ds)) / 2)
	elseif VType == "T" then	--Typical
		Out = ((Value(I,"M",ds) * 2 + Value(I,"C",ds))/3)
	elseif VType == "W" then	--Weighted
		Out = ((Value(I,"T",ds) * 3 + Value(I,"O",ds))/4) 
	elseif VType == "D" then	--Difference
		Out = (Value(I,"H",ds) - Value(I,"L",ds))
	elseif VType == "A" then	--Any
		if ds then Out = ds[I] else Out = nil end
	end
return Out
end