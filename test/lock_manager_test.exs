defmodule LockManagerTest do
  use ExUnit.Case
  doctest LockManager

  setup do
    {:ok, manager} = LockManager.start_link
    {:ok, manager: manager}
  end

  describe("Lock wihtout a timeout") do
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
      {:ok, _lock_id} = LockManager.lock(manager, "resource")
      {result} = LockManager.lock(manager, "resource")
      assert(
        result == :timeout
      )
    end

    test "Unlocks a resource with a given id", %{manager: manager} do
      {:ok, lock_id} = LockManager.lock(manager, "resource")
      {result} = LockManager.unlock(manager, "resource", lock_id);
      assert result == :unlocked
    end

    test "returns :unkown_lock_id when unlocking a never locked resource", %{manager: manager} do
      {result} = LockManager.unlock(manager, "resource", "non-existing-id-lock_id")
      assert result == :unknown_lock_id
    end

    test "returns :unkown_lock_id when unlocking a non-locked resource", %{manager: manager} do
      {:ok, id} = LockManager.lock(manager, "resource")
      {:unlocked} = LockManager.unlock(manager, "resource", id)
      {result} = LockManager.unlock(manager, "resource", "non-existing-id-lock_id")
      assert result == :unknown_lock_id
    end

    test "returns :unkown_lock_id when unlocking with wrong id", %{manager: manager} do
      {:ok, _} = LockManager.lock(manager, "resource")
      {result} = LockManager.unlock(manager, "resource", "non-existing-id-lock_id")
      assert result == :unknown_lock_id
    end

    test "Can relock an unlocked resource", %{manager: manager} do
      {:ok, lock_id} = LockManager.lock(manager, "resource")
      {:unlocked} = LockManager.unlock(manager, "resource", lock_id);
      {:ok, lock_id} = LockManager.lock(manager, "resource")
      assert lock_id != nil
    end
  end
end
