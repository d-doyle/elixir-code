defmodule Sequence.Server do
  use GenServer

  #####
  # External API

  # Start a new GenServer link with the name of the module
  def start_link(stash_pid) do
    # Pass server to start, intial state, and a name for the process and turn on statistics and trace
    {:ok, _pid} = GenServer.start_link(__MODULE__, stash_pid, [name: __MODULE__, debug: [:statistics, :trace]])
  end

  # Get the next number
  def next_number() do
    # Make a call to get the next number
    GenServer.call(__MODULE__, :next_number)
  end

  # Set the number
  def set_number(new_number) do
    # Make a cast to set the number
    GenServer.cast(__MODULE__, {:set_number, new_number})
  end

  # Increment the number
  def increment_number(delta) do
    # Make a call to increment the number by the delta
    GenServer.cast(__MODULE__, {:increment_number, delta})
  end

  # Get the status
  def status() do
    # Return the statistics for this GenServer
    :sys.statistics(__MODULE__, :get)
  end

  #####
  # GenServer implementation

  # Handle the init call from GenServer
  # stash_pid - current state from the start_link call above
  def init(stash_pid) do
    # Get the current number from the stash
    current_number = Sequence.Stash.get_value(stash_pid)
    # Return ok and the new state
    { :ok, {current_number, stash_pid} }
  end

  # Handle the call for next number from GenServer
  # :next_number - call indicator,
  # from - tuple containing PID and Reference
  # current_number - current state
  def handle_call(:next_number, _from, {current_number, stash_pid}) do
    # return reply with the response (current state) and the new state
    { :reply, current_number, {current_number + 1, stash_pid} }
  end

  # Handle the cast to set the number from GenServer
  # {:next_number, new_number} - cast indicator, new value
  # current_number - current state
  def handle_cast({:set_number, new_number}, {_current_number, stash_pid}) do
    # return no reply with new state
    { :noreply, {new_number, stash_pid} }
  end

  # Handle the cast to increment the number from GenServer
  # {:increment_number, delta} - cast indicator, value by which to change the number
  # current_number - current state
  def handle_cast({:increment_number, delta}, {current_number, stash_pid}) do
    # return no reply with new state to GenServer
    { :noreply, {current_number + delta, stash_pid} }
  end

  # Handle the terminate call from GenServer
  # reason - the reason for the termination
  # {current_number, stash_pid} - the current state
  def terminate(_reason, {current_number, stash_pid}) do
    # save the current state to the stash
    Sequence.Stash.save_value(stash_pid, current_number)
  end

  # Handle the call to get the state
  # pdict - the current value of the process dictionary
  # state - the internal state of the GenServer
  def format_status(_reason, [ _pdict, state]) do
    [data: [{'State', "My current state is '#{inspect state}', and I'm awesome."}]]
  end
end
