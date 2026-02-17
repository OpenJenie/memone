defmodule ContextEngineeringWeb.AgentController do
  use ContextEngineeringWeb, :controller

  alias ContextEngineering.Knowledge

  @doc """
  Register a new agent with optional capabilities and send an HTTP JSON response reflecting the outcome.
  
  ## Parameters
  
    - conn: The Plug connection.
    - params: Map of agent attributes. May include the "capabilities" key (a list) which will be extracted and associated with the created agent.
  
  ## Responses
  
    - On success: sets status 201 and returns the created agent as JSON.
    - On validation failure: sets status 422 and returns formatted changeset errors under the `errors` key.
    - On other failure: sets status 422 and returns an `errors` object with `detail` set to the error reason.
  
  """
  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, params) do
    capabilities = Map.get(params, "capabilities", [])
    agent_params = Map.drop(params, ["capabilities"])

    case Knowledge.register_agent_with_capabilities(agent_params, capabilities) do
      {:ok, agent} ->
        conn
        |> put_status(:created)
        |> json(agent)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Knowledge.format_errors(changeset)})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: %{detail: to_string(reason)}})
    end
  end

  @doc """
  Renders a JSON array of agents filtered by the given query parameters.
  
  ## Parameters
  
    - params: Map of query parameters used for filtering, pagination, or sorting of the returned agents.
  
  @returns The updated connection with a JSON body containing the list of agents.
  """
  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, params) do
    agents = Knowledge.list_agents(params)
    json(conn, agents)
  end

  @doc """
  Fetches an agent by ID and returns a JSON response containing the agent or a 404 error.
  
  On success, responds with the agent serialized as JSON. If the agent is not found, responds with HTTP 404 and a JSON body of %{error: "Agent not found"}.
  """
  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    case Knowledge.get_agent(id) do
      {:ok, agent} ->
        json(conn, agent)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Agent not found"})
    end
  end

  @doc """
  Renders the agent's trust information as JSON; responds with 404 if the agent is not found.
  
  ## Parameters
  
    - id: Identifier of the agent to retrieve.
  
  ## Returns
  
  The connection with a JSON body containing `agent_id`, `trust_score`, and `status` on success; on failure the connection has status 404 and a JSON error message.
  """
  @spec trust(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def trust(conn, %{"id" => id}) do
    case Knowledge.get_agent(id) do
      {:ok, agent} ->
        json(conn, %{agent_id: agent.id, trust_score: agent.trust_score, status: agent.status})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Agent not found"})
    end
  end
end