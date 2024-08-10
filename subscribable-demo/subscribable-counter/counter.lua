Subscribable = require 'subscribable' ({
  useDB = false
})

Subscribable.PAYMENT_TOKEN = 'QHuiEyWvTr9--2ctHeYqgjC60APrVB-_1MMvU9EpMcI' -- DEXI token
Subscribable.PAYMENT_TOKEN_TICKER = 'DTST'

Subscribable.configTopicsAndChecks({
  ['counter-reset'] = {
    description = 'Counter was reset',
    returns = '{ "reached" : number }',
    subscriptionBasis = "Payment of 1 " .. Subscribable.PAYMENT_TOKEN_TICKER
  }
})


Counter = Counter or 0

Handlers.add(
  "increment",
  Handlers.utils.hasMatchingTag("Action", "Increment"),
  function(msg)
    Counter = Counter + 1
  end
)

Handlers.add(
  "reset",
  Handlers.utils.hasMatchingTag("Action", "Reset"),
  function(msg)
    local reachedValue = Counter
    Counter = 0
    Subscribable.notifySubscribers("counter-reset", { reached = reachedValue })
  end
)

Handlers.add(
  'counter',
  Handlers.utils.hasMatchingTag("Action", "Counter"),
  function(msg)
    ao.send({
      Target = msg.From,
      Action = "Resp-Counter",
      Counter = Counter
    })
  end
)
