defmodule ContextEngineering.Contexts.Agents.AgentCapability do
  use Ecto.Schema
  import Ecto.Changeset

  alias ContextEngineering.Contexts.Agents.Agent

  @derive {Jason.Encoder, only: [:id, :capability, :max_risk_level, :requires_cosign]}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "agent_capabilities" do
    field :capability, :string
    field :max_risk_level, :integer, default: 0
    field :requires_cosign, :boolean, default: false

    belongs_to :agent, Agent, type: :binary_id

    timestamps()
  end

  @doc """
  Builds a changeset for an AgentCapability from the given attributes.
  
  Validates that `:capability` is present, ensures `:max_risk_level` is between 0 and 3 (inclusive), and enforces a unique constraint on the combination of `:agent_id` and `:capability`.
  
  ## Parameters
  
    - agent_capability: an AgentCapability struct or existing changeset.
    - attrs: map of attributes. Accepted keys: `:capability`, `:max_risk_level`, `:requires_cosign`
  """
  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(agent_capability, attrs) do
    agent_capability
    |> cast(attrs, [:capability, :max_risk_level, :requires_cosign])
    |> validate_required([:capability])
    |> validate_number(:max_risk_level, greater_than_or_equal_to: 0, less_than_or_equal_to: 3)
    |> unique_constraint([:agent_id, :capability])
  end
end