defmodule ContextEngineering.Contexts.Intents.IntentDecision do
  use Ecto.Schema
  import Ecto.Changeset

  alias ContextEngineering.Contexts.Intents.Intent

  @derive {Jason.Encoder,
           only: [
             :id,
             :intent_id,
             :decision,
             :reason,
             :risk_score,
             :policy_snapshot,
             :cosigned_by,
             :cosigned_at,
             :inserted_at
           ]}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "intent_decisions" do
    field :decision, :string
    field :reason, :string
    field :risk_score, :float, default: 0.0
    field :policy_snapshot, :map, default: %{}
    field :cosigned_by, :string
    field :cosigned_at, :utc_datetime_usec

    belongs_to :intent, Intent, type: :binary_id

    timestamps(updated_at: false)
  end

  def changeset(intent_decision, attrs) do
    intent_decision
    |> cast(attrs, [:intent_id, :decision, :reason, :risk_score, :policy_snapshot, :cosigned_by, :cosigned_at])
    |> validate_required([:intent_id, :decision])
    |> validate_inclusion(:decision, ["allow", "deny", "require_cosign", "require_evidence", "delay"])
    |> unique_constraint(:intent_id)
  end
end
