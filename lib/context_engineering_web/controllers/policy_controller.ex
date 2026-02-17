defmodule ContextEngineeringWeb.PolicyController do
  use ContextEngineeringWeb, :controller

  alias ContextEngineering.Knowledge

  @doc """
  Evaluates an intent policy from request parameters and responds with JSON.
  
  Takes the request parameters, delegates policy evaluation, and sends an HTTP JSON response:
  - on success: responds with the policy decision,
  - if the agent is not found: responds with status 404 and `{"error": "Agent not found"}`,
  - if the capability is not allowed: responds with status 403 and `{"error": "Capability not allowed for this agent"}`.
  
  ## Parameters
  
    - conn: the Plug connection for the request.
    - params: request parameters used to evaluate the intent policy.
  
  @returns the updated Plug connection with the JSON response set.
  """
  @spec evaluate(Plug.Conn.t(), map()) :: Plug.Conn.t()
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