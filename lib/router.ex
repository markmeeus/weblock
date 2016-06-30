defmodule Router do

  use Plug.Router

  plug :match
  plug :dispatch

  get "/lock/:resource" do
    LockManager.lock(LockManager, resource)
      |> respond_to_lock(conn)
  end

  delete "/lock/:resource/:lock_id" do
    LockManager.unlock(LockManager, resource, lock_id)
      |> respond_to_unlock(conn)
  end

  match _ do
    send_resp(conn, 400, "This is not the droid you are looking for.")
  end

  defp respond response, status_code, conn do
    conn |> send_resp(status_code, response)
  end

  defp respond_to_lock({:ok, lock_id}, conn) do
    %{result: "ok", lock_id: lock_id}
      |> Poison.encode!
      |> respond(200, conn)
  end

  defp respond_to_lock({result} = {:timeout}, conn) do
    %{result: result}
      |> Poison.encode!
      |> respond(500, conn)
  end

  defp respond_to_unlock({result} = {:unlocked}, conn) do
    %{result: result}
      |> Poison.encode!
      |> respond(200, conn)
  end

  defp respond_to_unlock({result} = {:unknown_lock_id}, conn) do
    %{result: result}
      |> Poison.encode!
      |> respond(500, conn)
  end

end