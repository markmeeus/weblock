defmodule ResourceLock do

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :init, []);
  end

  def enqueue resource_lock do
    res = GenServer.call(resource_lock, {:enqueue})
    res
  end

  def unlock resource_lock, lock_id do
    GenServer.call(resource_lock, {:unlock, lock_id})
  end

  #genserver events
  def init(:init) do
    {:ok, {:available, "", []}}
  end

  #resource is available
  def handle_call({:enqueue}, {from_pid, _}, {:available, _lock_id, []}) do
    new_id = UUID.uuid1()
    send from_pid, {:locked, new_id}
    {:reply, {:ok, new_id}, {:locked, new_id, []}}
  end

  #resource is locked
  def handle_call({:enqueue}, {fromPid, _}, {:locked, lock_id, queue}) do
    queue = fromPid |> enqueue_pid(queue)
    {:reply, {:enqueued}, {:locked, lock_id, queue}}
  end

  #unlock with correct lock_id
  def handle_call({:unlock, lock_id}, _from, {:locked, lock_id, []}) do
    {:reply, {:unlocked}, {:available, "", []}}
  end

  def handle_call({:unlock, lock_id}, _from, {:locked, lock_id, queue}) do
    case dequeue_pid(queue) do
      {nil, []} ->
        {:reply, {:unlocked}, {:available, nil, []}}

      {new_owner_pid, new_queue} ->
        new_id = UUID.uuid1()
        send new_owner_pid, {:locked, new_id}
        {:reply, {:unlocked}, {:locked, new_id, new_queue}}

    end
  end

  #cannot unlock available lock
  def handle_call({:unlock, _}, _from, state = {:available, _, _}) do
    {:reply, {:unknown_lock_id}, state}
  end

  #cannot unlock with wrong lock_id
  def handle_call({:unlock, _wrong_lock_id}, _from, state = {:locked, _lock_id, _}) do
    {:reply, {:unknown_lock_id}, state}
  end

  # enqueues a pid to the queue
  # filo queue for now
  defp enqueue_pid(fromPid, queue) do
   [fromPid | queue]
  end

  #List as queue for now
  defp dequeue_pid([pid|t]) do
    case (Process.alive?(pid)) do
      true -> {pid, t}
      false -> dequeue_pid(t)
    end
  end

  defp dequeue_pid([]), do: {nil, []}

end