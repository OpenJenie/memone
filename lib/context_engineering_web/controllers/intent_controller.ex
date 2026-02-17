defmodule ContextEngineeringWeb.IntentController do
  use ContextEngineeringWeb, :controller

  alias ContextEngineering.Knowledge

  def create(conn, params) do
    case Knowledge.submit_intent(params) do
      {:ok, intent} ->
        conn
        |> put_status(:created)
        |> json(intent)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Agent not found"})

      {:error, :capability_not_allowed} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Capability not allowed for this agent"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Knowledge.format_errors(changeset)})
    end
  end

  def show(conn, %{"id" => id}) do
    case Knowledge.get_intent(id) do
      {:ok, intent} ->
        json(conn, intent)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Intent not found"})
    end
  end

  def cosign(conn, %{"id" => id, "cosigned_by" => cosigned_by}) do
    case Knowledge.cosign_intent(id, cosigned_by) do
      {:ok, intent} ->
        json(conn, intent)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Intent not found"})

      {:error, :invalid_status} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Intent is not pending cosign"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Knowledge.format_errors(changeset)})
    end
  end

  def cosign(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "cosigned_by is required"})
  end

  def rollback(conn, %{"id" => id} = params) do
    reason = Map.get(params, "reason", "Manual rollback")

    case Knowledge.rollback_intent(id, reason) do
      {:ok, intent} ->
        json(conn, intent)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Intent not found"})

      {:error, :invalid_status} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Intent is not in an executable state"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Knowledge.format_errors(changeset)})
    end
  end
end
