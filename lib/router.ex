defmodule Router do

  use Plug.Router

  import Plug.Conn

  plug :match
  plug :dispatch

  get "/lock/:resource" do
    conn = fetch_query_params(conn)

    [timeout | lease] = [conn.params["timeout"], conn.params["lease"]]
      |> params_to_int

    LockManager
      |> LockManager.lock(resource, timeout, lease)
      |> respond_to_lock(conn)
  end

  delete "/lock/:resource/:lock_id" do
    LockManager
      |> LockManager.unlock(resource, lock_id)
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

  def param_to_int param do
    {param, _} =
      case param do
        nil -> {nil, nil}
        param_as_string -> param_as_string |> Integer.parse
      end
    param
  end

  def params_to_int [] do
    []
  end

  def params_to_int [param] do
    param_to_int(param)
  end

  def params_to_int [h|t] do
    [param_to_int(h) | params_to_int(t)]
  end
end