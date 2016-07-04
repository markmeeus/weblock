defmodule RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Router.init([])

  test "Returns lock_id when locking a resource" do
    json = request_and_return_json :get, "/lock/test_resource"
    assert json["result"] == "ok"
    assert json["lock_id"] != nil
  end

  test "Returns timeout when trying to lock a locked resource" do
    LockManager.lock(LockManager, "test_resource2")
    json = request_and_return_json :get, "/lock/test_resource2"
    assert json["result"] == "timeout"
  end

  test "Returns unlocked when unlocking a locked resource" do
    {:ok, lock_id} = LockManager.lock(LockManager, "test_resource3")
    json = request_and_return_json :delete, "/lock/test_resource3/" <> lock_id
    assert json["result"] == "unlocked"
  end

  test "Returns unknown_lock_id when unlocking a non-locked resource" do
    {:ok, lock_id} = LockManager.lock(LockManager, "test_resource4")
    LockManager.unlock(LockManager, "test_resource4", lock_id)
    json = request_and_return_json :delete, "/lock/test_resource4/" <> lock_id
    assert json["result"] == "unknown_lock_id"
  end

  defp request_and_return_json method, path do
    conn = conn(method, path)
      |> Router.call(@opts)
    {:ok, json} = Poison.decode(conn.resp_body)
    json
  end
end