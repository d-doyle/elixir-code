defmodule Stack.Server do
  use GenServer

  #####
  # External API

  # Start a new GenServer link with the name of the module
  def start_link(current_stack) do
    # Pass server to start, intial state, and a name for the process and turn on statistics and trace
    GenServer.start_link(__MODULE__, current_stack, [name: __MODULE__, debug: [:statistics, :trace]])
  end

  # Get the next number
  def pop() do
    # Make a call to get the next number
    GenServer.call(__MODULE__, :pop)
  end

  # Set the number
  def push(new_item) do
    # Make a cast to set the number
    GenServer.cast(__MODULE__, {:push, new_item})
  end

  # Get the status
  def status() do
    # Return the statistics for this GenServer
    :sys.statistics(__MODULE__, :get)
  end

  #####
  # GenServer implementation

  # Handle the call for next stack item from GenServer
  # :pop - call indicator
  # from - tuple containing PID and Reference
  # [h|t] - current state
  def handle_call(:pop, _from, [h|t]) do
    # return reply with the response (head) and the new state (tail)
    { :reply, h, t }
  end

  # Handle the cast to push an item on the stack from GenServer
  # {:push, item, state} - cast indicator, new value, stack
  def handle_cast({:push, item}, state) do
    # return no reply with new state (pushing item on to the stack)
    { :noreply, [item|state]}
  end

  # Handle the event that the server is about to be terminated
  def terminate(reason, state) do
    # Show the reason and state
    IO.puts("Reason: #{inspect reason}; State: #{inspect state}")
  end

  # Handle the call to get the state
  # pdict - the current value of the process dictionary
  # state - the internal state of the GenServer
  def format_status(_reason, [ _pdict, state]) do
    [data: [{'State', "My current state is '#{inspect state}', and I'm awesome."}]]
  end
end
