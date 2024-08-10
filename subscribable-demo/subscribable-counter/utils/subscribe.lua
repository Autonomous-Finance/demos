local json = require 'json'
COUNTER_PROCESS = 's9dEySpErnPZXFWn8GZ-az16vRGPtTVxhTL9aGQ0nNo'

ao.send({
  Target = COUNTER_PROCESS,
  Action = "Register-Subscriber",
  Topics = json.encode({ 'counter-reset' })
})

ao.addAssignable(
  'receive-data-from-counter',
  { From = COUNTER_PROCESS }
)
