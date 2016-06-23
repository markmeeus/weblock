defmodule LockManager do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :init, [])        
  end

  def lock(manager, name) do
    GenServer.call(manager, {:lock, name})        
  end

  def unlock(manager, name, lock_id) do
    GenServer.call(manager, {:unlock, name, lock_id})
  end

  #Genserver events
  def init(:init) do
    {:ok, {0, %{}}}    
  end
  
  def handle_call({:lock, name}, _from, {count, locks}) do        
    case Map.fetch(locks, name) do
      {:ok, id} -> {:reply, :timeout, {count, locks}}      
      :error ->
        new_lock_id = count + 1 
        {
          :reply, 
          {:ok, new_lock_id}, 
          {new_lock_id,  Map.put(locks, name, new_lock_id)}
        }                
    end        
  end

  def handle_call({:unlock, name, lock_id}, _from, {last_id, locks}) do
    case Map.fetch(locks, name) do
      {:ok, _} -> {:reply, :unlocked, {last_id, Map.delete(locks, name)}}            
    end
  end
end
