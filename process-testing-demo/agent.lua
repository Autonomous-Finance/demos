local limitOrder = require "limit-order"

Handlers.add(
  'Config',
  Handlers.utils.hasMatchingTag('Action', 'Config'),
  function(msg)
    -- Set the config for the limit order to be executed
    AMM = msg.Tags.AMM
    TOKEN_A = msg.Tags.TokenA
    TOKEN_B = msg.Tags.TokenB
    DIRECTION = msg.Tags.Direction
    INPUT_QTY = msg.Tags.InputQty
    OUTPUT_QUANTITY_THRESHOLD = msg.Tags.OutputQuantityThreshold
  end
)

-- on receiving an AMM-Params-Update (i.e. potential swap price has changed)
-- we handle by attempting to execute the limit order
Handlers.add(
  'AMM-Params-Update',
  Handlers.utils.hasMatchingTag('Action', 'AMM-Params-Update'),
  limitOrder.handleAmmParamsUpdate
)
