defmodule ContextEngineering.Contexts.Intents.Intent do
  use Ecto.Schema
  import Ecto.Changeset

  alias ContextEngineering.Contexts.Agents.Agent
  alias ContextEngineering.Contexts.Intents.IntentDecision

  @derive {Jason.Encoder,
           only: [
             :id,
             :agent_id,
             :capability,
             :resource_type,
             :resource_id,
             :risk_level,
             :idempotency_key,
             :payload,
             :payload_hash,
             :status,
             :execution_notes,
             :inserted_at,
             :agent,
             :decision
           ]}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "intents" do
    field :capability, :string
    field :resource_type, :string
    field :resource_id, :string
    field :risk_level, :integer, default: 0
    field :idempotency_key, :string
    field :payload, :map, default: %{}
    field :payload_hash, :string
    field :status, :string, default: "submitted"
    field :execution_notes, :string

    belongs_to :agent, Agent, type: :binary_id
    has_one :decision, IntentDecision

    timestamps(updated_at: false)
  end

  def changeset(intent, attrs) do
    intent
    |> cast(attrs, [
      :agent_id,
      :capability,
      :resource_type,
      :resource_id,
      :risk_level,
      :idempotency_key,
      :payload,
      :payload_hash,
      :status,
      :execution_notes
    ])
    |> validate_required([:agent_id, :capability, :risk_level, :idempotency_key, :payload_hash])
    |> validate_number(:risk_level, greater_than_or_equal_to: 0, less_than_or_equal_to: 3)
    |> validate_inclusion(:status, ["submitted", "executed", "denied", "needs_cosign", "needs_evidence", "rolled_back"])
    |> unique_constraint([:agent_id, :idempotency_key])
  end
end
