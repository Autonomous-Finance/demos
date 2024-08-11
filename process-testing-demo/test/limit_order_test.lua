---@diagnostic disable: duplicate-set-field
require("test.setup")()

_G.VerboseTests = 0 -- how much logging to see (0 - none at all, 1 - important ones, 2 - everything)
-- optional logging function that allows for different verbosity levels
_G.printVerb = function(level)
  level = level or 2
  return function(...) -- define here as global so we can use it in application code too
    if _G.VerboseTests >= level then print(table.unpack({ ... })) end
  end
end

local limitOrder = require "limit-order" -- testing this

local ammCalc = require "amm-calc"       -- mocking this within tests

local bint = require ".bint" (256)


local TEST_AMM = '123MyAmm321'
local TEST_TOKEN_A = 'xyz_TokenA'
local TEST_TOKEN_B = 'xyz_TokenB'

-- MOCK MESSAGE SENDING
-- replace with tracking what is sent out by our agent

_G.Outgoing = { -- mock outbox
  [TEST_AMM] = {}
}
_G.ao = {
  send = function(msg)
    print('sending to ', msg.Target)
    if msg.Target == TEST_TOKEN_A or msg.Target == TEST_TOKEN_B then
      table.insert(_G.Outgoing[msg.Target], msg)
    end
  end
}

-- TEST FIXTURES & CASE VARIATION

local function resetGlobals()
  _G.DIRECTION = nil
  _G.INPUT_QTY = nil
  _G.OUTPUT_QUANTITY_THRESHOLD = nil
end

local function configLimitOrder(direction, inputQty, outputThreshold)
  _G.DIRECTION = direction
  _G.INPUT_QTY = inputQty
  _G.OUTPUT_QUANTITY_THRESHOLD = outputThreshold
end

-- TESTS

describe("limit order unit test", function()
  -- we mock out the amm-calc functionality, in order to strictly test limit-order logic
  setup(function()
    _G.AMM = TEST_AMM
    _G.TOKEN_A = TEST_TOKEN_A
    _G.TOKEN_B = TEST_TOKEN_B
  end)

  local originalGetExpectedOut
  local originalCheckSwapCondition
  before_each(function()
    resetGlobals()
    _G.Outgoing[_G.TOKEN_A] = {}
    _G.Outgoing[_G.TOKEN_B] = {}
    originalGetExpectedOut = ammCalc.getExpectedOut
    originalCheckSwapCondition = limitOrder.checkSwapCondition
  end)

  -- inside ANY TEST CASE, we can MOCK ammCalc.getExpectedOut as needed

  after_each(function()
    ammCalc.getExpectedOut = originalGetExpectedOut
    limitOrder.checkSwapCondition = originalCheckSwapCondition
  end)

  it("should disregard negative swap condition", function()
    local direction = 'BUY'
    local inputQty = '100000'
    local outputThreshold = '50000'

    -- effective price (after fees) is 2 or better
    configLimitOrder(direction, inputQty, outputThreshold)

    -- mock the output calculation
    ammCalc.getExpectedOut = function()
      return bint('49999')
    end

    -- reserves and fee passed in are irrelevant due to mocking
    local success, expOut = limitOrder.checkSwapCondition(nil, nil)

    assert.is_not_true(success, "should be negative check")
    assert.are.equal(expOut, nil)
  end)

  it("should recognize positive swap condition", function()
    local direction = 'BUY'
    local inputQty = '100000'
    local outputThreshold = '50000'

    -- effective price (after fees) is 2 or better
    configLimitOrder(direction, inputQty, outputThreshold)

    -- mock the output calculation
    ammCalc.getExpectedOut = function()
      return bint('50000')
    end

    -- reserves and fee passed in are irrelevant due to mocking
    local success, expOut = limitOrder.checkSwapCondition(nil, nil)

    assert.is_true(success, "should be positive check")
    assert.are.equal(expOut, bint('50000'))
  end)

  it("should not attempt swap when condition is not met", function()
    -- mock the check
    limitOrder.checkSwapCondition = function(reserves, fee)
      return false, nil
    end

    limitOrder.handleAmmParamsUpdate({
      Tags = {
        Reserves = "{}" -- irrelevant because of mocked behaviour
      }
    })
    assert.are.equal(0, #_G.Outgoing[_G.TOKEN_A]) -- no outgoing messages (no swap attempted)
    assert.are.equal(0, #_G.Outgoing[_G.TOKEN_B]) -- no outgoing messages (no swap attempted)
  end)

  it("should attempt swap when condition is met", function()
    local direction = 'BUY'
    local inputQty = '100000'
    local outputThreshold = '50000'
    configLimitOrder(direction, inputQty, outputThreshold)

    -- mock the check
    limitOrder.checkSwapCondition = function(reserves, fee)
      return true, bint("0") -- irrelevant
    end

    limitOrder.handleAmmParamsUpdate({
      Tags = {
        Reserves = "{}" -- irrelevant because of mocked behaviour
      }
    })
    assert.are.equal(1, #_G.Outgoing[_G.TOKEN_A]) -- a swap message to buy was sent out
    assert.are.equal(0, #_G.Outgoing[_G.TOKEN_B])
  end)

  it("should perform the swap correctly", function()
    local direction = 'BUY'
    local inputQty = '100000'
    local outputThreshold = '50000'
    configLimitOrder(direction, inputQty, outputThreshold)

    -- mock the check
    local expOut = "55555"
    limitOrder.checkSwapCondition = function(reserves, fee)
      return true, bint(expOut) -- irrelevant
    end

    limitOrder.handleAmmParamsUpdate({
      Tags = {
        Reserves = "{}" -- irrelevant because of mocked behaviour
      }
    })

    local swap = _G.Outgoing[_G.TOKEN_A][1]
    local expSwap = {
      Target = _G.TOKEN_A,
      Action = "Transfer",
      Quantity = _G.INPUT_QTY,
      Recipient = _G.AMM,
      ["X-Action"] = "Swap",
      ["X-Slippage-Tolerance"] = "1",
      ["X-Expected-Output"] = expOut
    }
    assert.are.same(expSwap, swap)
  end)
end)
