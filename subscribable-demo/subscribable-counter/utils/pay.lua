COUNTER_PROCESS = 's9dEySpErnPZXFWn8GZ-az16vRGPtTVxhTL9aGQ0nNo'
DEXI = 'QHuiEyWvTr9--2ctHeYqgjC60APrVB-_1MMvU9EpMcI'

ao.send({
  Target = DEXI,
  Action = "Transfer",
  Recipient = COUNTER_PROCESS,
  Quantity = "1",
  ["X-Action"] = "Pay-For-Subscription",
  ["X-Subscriber-Process-Id"] = ao.id
})
