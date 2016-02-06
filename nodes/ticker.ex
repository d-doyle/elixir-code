@doc """
The Ticker Server
Sends out :tick messages at regular intervals
"""
defmodule Ticker do
  @interval 2000
  @name :ticker

  @doc """
  Takes no parameters
  Call this function to start the Ticker server
  """
  def start do
    # Spawn a new generator process
    # Pass in the module, function, and arguments
    pid = spawn(__MODULE__, :generator, [[]])
    # Register the name and pid of the process
    :global.register_name(@name, pid)
  end

  @doc """
  Takes the client pid
  Call this function to regeister your client process
  """
  def register(client_pid) do
    send :global.whereis_name(@name), { :register, client_pid }
  end

  @doc """
  Takes a list of clients
  Registers the clients to recieve the tick message
  Sets up the interval to send out the tick messages
  """
  def generator(clients) do
    receive do
      { :register, pid } ->
        IO.puts "registering #{inspect pid}"
        generator([pid|clients])
    after
      @interval ->
        IO.puts "tick"
        Enum.each clients, fn client -> send client, { :tick } end
        generator(clients)
    end
  end
end

@doc """
The Client
Receives :tick messages
"""
defmodule Client do
  @doc """
  Takes no parameters
  Call this function to start the client
  and register the client with the Ticker server
  """
  def start do
    # Spawn a new receiver process
    pid = spawn(__MODULE__, :receiver, [])
    # Register with the Ticker server
    Ticker.register(pid)
  end

  @doc """
  Sets up the client to receive tick messages
  """
  def receiver do
    receive do
      { :tick } ->
        IO.puts "tock in client"
        receiver
    end
  end
end
