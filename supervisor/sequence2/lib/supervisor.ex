defmodule Sequence.Supervisor do
  use Supervisor

  def start_link(initial_number) do
    # Start a supervisor for this module and pass in initial state
    # Is initial_number necessary here?
    result = { :ok, sup } = Supervisor.start_link(__MODULE__, [initial_number])
    # Start the workers and pass in the pid and initial value
    start_workers(sup, initial_number)
    # Return the result
    result
  end

  def start_workers(sup, initial_number) do
    # Start the child stash worker and pass in the initial state
    { :ok, stash } =
      Supervisor.start_child(sup, worker(Sequence.Stash, [initial_number]))

    # and then the child subsupervisor for the actual sequence server and pass in the stash pid
    Supervisor.start_child(sup, supervisor(Sequence.SubSupervisor, [stash]))
  end

  def init(_) do
    # Initialize supervisor with no children (we have started them above)
    supervise [], strategy: :one_for_one
  end
end
