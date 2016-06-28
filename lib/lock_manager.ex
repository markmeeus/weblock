defmodule LockManager do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :init, [])
  end

  def lock(manager, name, timeout \\ 0) do
    {:ok, lock} = GenServer.call(manager, {:get_lock, name})
    ResourceLock.enqueue(lock)
    receive do
      {:locked, lock_id } ->
        {:ok, lock_id}
      after timeout -> {:timeout}
    end
  end

  def unlock(manager, name, lock_id) do
    GenServer.call(manager, {:unlock, name, lock_id})
  end

  #Genserver events
  def init(:init) do
    {:ok, %{} }
  end

  def handle_call({:get_lock, name}, _from, locks) do
    resource_lock = case Map.fetch(locks, name) do
      {:ok, lock} -> lock
        {:reply, {:ok, lock}, locks}
      :error ->
        {:ok, lock} = ResourceLock.start_link
        {:reply, {:ok, lock}, Map.put(locks, name, lock)}
    end
  end


  def handle_call({:unlock, name, lock_id}, _from, locks) do
    case Map.fetch(locks, name) do
      {:ok, lock} ->
        {:reply, ResourceLock.unlock(lock, lock_id), locks}
      :error ->
        {:reply, {:unknown_lock_id}, locks}
    end
  end
end
