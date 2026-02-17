defmodule ContextEngineeringWeb.PolicyController do
  use ContextEngineeringWeb, :controller

  alias ContextEngineering.Knowledge

  def evaluate(conn, params) do
    case Knowledge.evaluate_intent_policy(params) do
      {:ok, decision} ->
        json(conn, decision)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Agent not found"})

      {:error, :capability_not_allowed} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Capability not allowed for this agent"})
    end
  end
end
