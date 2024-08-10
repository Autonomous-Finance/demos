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
    Counter = 0
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
