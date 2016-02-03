defmodule FibSolver do
  def fib(scheduler) do
    # Send a ready message to the scheduler pid, and include my pid
    send scheduler, { :ready, self }
    receive do
      # Receive a fibonacci messsage with a number and client pid
      { :fib, n, client } ->
        # Send back an answer with the number, the fibonacci result and my pid
        send client, { :answer, n, fib_calc(n), self }
        # Call myself recursively to stay alive
        fib(scheduler)
      # Receive a shutdown message
      { :shutdown } ->
        # Exit this process
        exit(:normal)
    end
  end

  defp fib_calc(0), do: 0
  defp fib_calc(1), do: 1
  defp fib_calc(n), do: fib_calc(n - 1) + fib_calc(n - 2)
end

defmodule Scheduler do
  @moduledoc """
  Define a run process that takes
  * num_processes - The number of processes to create
  * module - The module of the function to run
  * func - The function to run
  * to_caclulate - A list of numbers for which we are calculating fibonacci
  """
  def run(num_processes, module, func, to_calculate) do
    # Create a list of numbers
    (1..num_processes)
    # Spawn a new process for each number and collect the pids
    # Each new process will call FibSolver fib
    |> Enum.map(fn(_) -> spawn(module, func, [self]) end)
    # Pass the list of pids to the schedule processes function
    |> schedule_processes(to_calculate, [])
  end

  @moduledoc """
  Define a function that takes
  * processes - A list of process ids
  * queue - The queue of numbers for which we are calculating fibonacci
  * results - a list of results
  """
  defp schedule_processes(processes, queue, results) do
    receive do
      # Receive a ready message when there are items left in the queue
      { :ready, pid } when length(queue) > 0 ->
        # Get the head and the tail of the queue
        [ next | tail ] = queue
        # Send a fib message with the next item in the queue and our pid
        #:io.format "~w is calculating ~B~n", [pid, next]
        send pid, {:fib, next, self}
        # Call this function recursively to continue to receive messages
        schedule_processes(processes, tail, results)
      # Receive a ready message when there are no items left in the queue
      { :ready, pid } ->
        # Send a shutdown message
        #:io.format "~w is shutting down.~n", [pid]
        send pid, {:shutdown}
        # If there are processes that still need to be shutdown
        if length(processes) > 1 do
          # Recursively call this function deleting the current item from the process list
          schedule_processes(List.delete(processes, pid), queue, results)
        else
          # Else sort the results based on the initial numbers for which we were calculating fibonacci
          Enum.sort(results, fn {n1, _}, {n2, _} -> n1 <= n2 end)
        end
      # Receive an answer message
      { :answer, number, result, _pid} ->
        # Add it to the results and recursively call this function
        schedule_processes(processes, queue, [ {number, result} | results ])
    end
  end
end

#Scheduler.run(2, FibSolver, :fib, [2, 2])
to_process = [ 32, 33, 34, 35, 36, 37 ]

# For each number 1 to 10
Enum.each 1..10, fn num_processes ->
  # Start a scheduler to run that number of processes
  {time, result} = :timer.tc(Scheduler, :run, [num_processes, FibSolver, :fib, to_process])

  if num_processes == 1 do
    IO.puts inspect result
    IO.puts "\n # time (s)"
  end
:io.format "~2B  ~.4f~n", [num_processes, time/1000000.0]
end
