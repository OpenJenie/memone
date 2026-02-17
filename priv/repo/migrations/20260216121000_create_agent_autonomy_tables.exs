defmodule ContextEngineering.Repo.Migrations.CreateAgentAutonomyTables do
  use Ecto.Migration

  def change do
    create table(:agents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :tenant_id, :string, null: false
      add :trust_score, :float, default: 0.5, null: false
      add :status, :string, default: "active", null: false
      add :metadata, :map, default: %{}, null: false

      timestamps()
    end

    create unique_index(:agents, [:tenant_id, :name])
    create index(:agents, [:tenant_id])
    create index(:agents, [:status])

    create table(:agent_capabilities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :agent_id, references(:agents, type: :binary_id, on_delete: :delete_all), null: false
      add :capability, :string, null: false
      add :max_risk_level, :integer, default: 0, null: false
      add :requires_cosign, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:agent_capabilities, [:agent_id, :capability])

    create table(:intents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :agent_id, references(:agents, type: :binary_id, on_delete: :restrict), null: false
      add :capability, :string, null: false
      add :resource_type, :string
      add :resource_id, :string
      add :risk_level, :integer, default: 0, null: false
      add :idempotency_key, :string, null: false
      add :payload, :map, default: %{}, null: false
      add :payload_hash, :string, null: false
      add :status, :string, default: "submitted", null: false
      add :execution_notes, :string

      timestamps(updated_at: false)
    end

    create unique_index(:intents, [:agent_id, :idempotency_key])
    create index(:intents, [:agent_id])
    create index(:intents, [:status])

    create table(:intent_decisions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :intent_id, references(:intents, type: :binary_id, on_delete: :delete_all), null: false
      add :decision, :string, null: false
      add :reason, :string
      add :risk_score, :float, default: 0.0, null: false
      add :policy_snapshot, :map, default: %{}, null: false
      add :cosigned_by, :string
      add :cosigned_at, :utc_datetime_usec

      timestamps(updated_at: false)
    end

    create unique_index(:intent_decisions, [:intent_id])
    create index(:intent_decisions, [:decision])
  end
end
