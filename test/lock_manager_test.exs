defmodule LockManagerTest do
  use ExUnit.Case
  doctest LockManager

  setup do
    {:ok, manager} = LockManager.start_link
    {:ok, manager: manager}
  end
  
  test "Locks a resource", %{manager: manager} do
    {:ok, lock_id} = LockManager.lock(manager, "resource")      
    assert lock_id != nil    
  end
  
  test "Retrieves a unique lock id", %{manager: manager} do
    {:ok, resource_1_lock_id} = LockManager.lock(manager, "resource1")
    {:ok, resource_2_lock_id} = LockManager.lock(manager, "resource2")      
    assert resource_1_lock_id != resource_2_lock_id
  end

  test "Cannot lock a resource twice", %{manager: manager} do
    {:ok, lock_id} = LockManager.lock(manager, "resource")
    result = LockManager.lock(manager, "resource")    
    assert(
      result == :timeout  
    )
  end  

  test "Unlocks a resource with a given id", %{manager: manager} do
    {:ok, lock_id} = LockManager.lock(manager, "resource")
    result = LockManager.unlock(manager, "resource", lock_id);
    assert result == :unlocked
  end

  test "Can relock an unlocked resource", %{manager: manager} do
    {:ok, lock_id} = LockManager.lock(manager, "resource")
    :unlocked = LockManager.unlock(manager, "resource", lock_id);
    {:ok, lock_id} = LockManager.lock(manager, "resource")
    assert lock_id != nil
  end
end
