defmodule ContextEngineeringWeb.AgentController do
  use ContextEngineeringWeb, :controller

  alias ContextEngineering.Knowledge

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

  def index(conn, params) do
    agents = Knowledge.list_agents(params)
    json(conn, agents)
  end

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
