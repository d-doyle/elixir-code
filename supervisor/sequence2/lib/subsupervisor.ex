defmodule Sequence.SubSupervisor do
  use Supervisor

  def start_link(stash_pid) do
    # Start a supervisor for this module and send in the stash pid to be passed to init
    { :ok, _pid } = Supervisor.start_link(__MODULE__, stash_pid)
  end

  def init(stash_pid) do
    # Setup the child processes and pass in the initial state
    child_processes = [ worker(Sequence.Server, [stash_pid]) ]
    # Initialize the supervisor and the child processes
    supervise child_processes, strategy: :one_for_one
  end
end
