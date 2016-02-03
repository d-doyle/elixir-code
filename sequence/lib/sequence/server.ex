defmodule Sequence.Server do
  use GenServer

  #####
  # External API

  # Start a new GenServer link with the name of the module
  def start_link(current_number) do
    # Pass server to start, intial state, and a name for the process and turn on statistics and trace
    GenServer.start_link(__MODULE__, current_number, [name: __MODULE__, debug: [:statistics, :trace]])
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

  # Handle the call for next number from GenServer
  # :next_number - call indicator,
  # from - tuple containing PID and Reference
  # current_number - current state
  def handle_call(:next_number, _from, current_number) do
    # return reply with the response (current state) and the new state
    { :reply, current_number, current_number + 1}
  end

  # Handle the cast to set the number from GenServer
  # {:next_number, new_number} - cast indicator, new value
  # current_number - current state
  def handle_cast({:set_number, new_number}, _current_number) do
    # return no reply with new state
    { :noreply, new_number }
  end

  # Handle the cast to increment the number from GenServer
  # {:increment_number, delta} - cast indicator, value by which to change the number
  # current_number - current state
  def handle_cast({:increment_number, delta}, current_number) do
    # return no reply with new state
    { :noreply, current_number + delta }
  end

  # Handle the call to get the state
  # pdict - the current value of the process dictionary
  # state - the internal state of the GenServer
  def format_status(_reason, [ _pdict, state]) do
    [data: [{'State', "My current state is '#{inspect state}', and I'm awesome."}]]
  end
end
