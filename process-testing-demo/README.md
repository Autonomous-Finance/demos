# Process Testing Demo

Showcase For Testing Practices

## Application

An agent that executes a limit order using an AMM.

The agent is subscribed to receive updates on the AMM reserves & fee. On each update, it checks whether the condition to execute the swap is met. If so, it performs a swap.

## Testing 

- Unit tests
- Handler implementation separation
- `ao` mocking within the test file, to handle outgoing messages


## No integration, No process mocking

Integration tests with other processes would be possible but bring no benefit in this simple setup