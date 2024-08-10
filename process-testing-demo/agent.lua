local limitOrder = require "limit-order"

-- TODO

-- a config for the limit order to be executed
--[[
 - tokens
 - input quantity
 - price
]]

-- a handler by which it is informed of updates in the pool reserves / fee
--[[
  - simulates expected output calculation
  - infers swap price from there
  - decides whether to execute the limit order
]]
