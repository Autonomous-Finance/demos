local json = require "json"
local ammCalc = require "amm-calc"

local mod = {}

local function swap(expectedOut)
  ao.send({
    Target = DIRECTION == 'BUY' and TOKEN_A or TOKEN_B,
    Action = "Transfer",
    Quantity = INPUT_QTY,
    Recipient = AMM,
    ["X-Action"] = "Swap",
    ["X-Slippage-Tolerance"] = "1",
    ["X-Expected-Output"] = tostring(expectedOut)
  })
end

function mod.checkSwapCondition(reserves, fee)
  local expectedOut = ammCalc.getExpectedOut(reserves, fee)

  if expectedOut >= OUTPUT_QUANTITY_THRESHOLD then
    return true, expectedOut
  else
    return false, nil
  end
end

--[[
  - simulates expected output calculation
  - infers swap price from there
  - decides whether to execute the limit order
]]
function mod.handleAmmParamsUpdate(msg)
  local reserves = json.decode(msg.Tags.Reserves)
  local fee = msg.Tags.Fee

  local success, expectedOut = mod.checkSwapCondition(reserves, fee)
  if success then
    swap(expectedOut)
  end
end

return mod
