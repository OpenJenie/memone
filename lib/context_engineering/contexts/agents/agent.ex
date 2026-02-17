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

  @doc """
  Builds a changeset for an Agent with casting and validation of allowed fields.
  
  Casts only the permitted fields and validates presence of `:name` and `:tenant_id`,
  ensures `:trust_score` is between 0.0 and 1.0, restricts `:status` to
  "active", "quarantined", or "revoked", and enforces uniqueness of the
  `:tenant_id` + `:name` combination.
  
  ## Parameters
  
    - agent: Agent struct or changeset to apply the changes to.
    - attrs: Map of attributes to cast (allowed keys: `:name`, `:tenant_id`, `:trust_score`, `:status`, `:metadata`).
  
  """
  @spec changeset(Ecto.Schema.t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(agent, attrs) do
    agent
    |> cast(attrs, [:name, :tenant_id, :trust_score, :status, :metadata])
    |> validate_required([:name, :tenant_id])
    |> validate_number(:trust_score, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> validate_inclusion(:status, ["active", "quarantined", "revoked"])
    |> unique_constraint([:tenant_id, :name])
  end
end