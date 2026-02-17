defmodule ContextEngineering.Contexts.Agents.Agent do
  use Ecto.Schema
  import Ecto.Changeset

  alias ContextEngineering.Contexts.Agents.AgentCapability

  @derive {Jason.Encoder,
           only: [
             :id,
             :name,
             :tenant_id,
             :trust_score,
             :status,
             :metadata,
             :capabilities,
             :inserted_at,
             :updated_at
           ]}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "agents" do
    field :name, :string
    field :tenant_id, :string
    field :trust_score, :float, default: 0.5
    field :status, :string, default: "active"
    field :metadata, :map, default: %{}

    has_many :capabilities, AgentCapability

    timestamps()
  end

  def changeset(agent, attrs) do
    agent
    |> cast(attrs, [:name, :tenant_id, :trust_score, :status, :metadata])
    |> validate_required([:name, :tenant_id])
    |> validate_number(:trust_score, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> validate_inclusion(:status, ["active", "quarantined", "revoked"])
    |> unique_constraint([:tenant_id, :name])
  end
end
