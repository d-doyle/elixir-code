defmodule Sequence.Stash do
  use GenServer

  #####
  # External API

  # Start a new GenServer link with the name of the module and state
  def start_link(current_number) do
    # Pass server to start, intial state, and turn on statistics and trace
    {:ok, _pid} = GenServer.start_link(__MODULE__, current_number, [debug: [:statistics, :trace]])
  end

  # Save the value to the stash
  def save_value(pid, value) do
    # Tell GenServer to update the state
    GenServer.cast(pid, {:save_value, value})
  end

  # Get the value from the stash
  def get_value(pid) do
    # Tell GenServer to get the state
    GenServer.call(pid, :get_value)
  end

  #####
  # GenServer implementation

  # Handle the cast to set the value from GenServer
  # {:save_value, value} - cast indicator, new value
  # current_number - current state
  def handle_cast({:save_value, value}, _current_value) do
    # return no reply and new state to GenServer
    {:noreply, value}
  end

  # Handle the call to get the value from GenServer
  # :get_value - call indicator
  # from - tuple containing PID and Reference
  # current_value - current state
  def handle_call(:get_value, _from, current_value) do
    # return reply with current and new state to GenServer
    {:reply, current_value, current_value}
  end
end
