defmodule ContextEngineering.Repo.Migrations.CreateAgentAutonomyTables do
  use Ecto.Migration

  @doc """
  Create the database schema for agent autonomy, including tables, constraints, and indexes.
  
  Creates four tables with their columns, defaults, foreign keys, unique constraints, and indexes:
  
  - agents: stores agents with id (binary_id), name, tenant_id, trust_score (default 0.5), status (default "active"), metadata (default %{}), and timestamps. Unique index on (tenant_id, name); indexes on tenant_id and status.
  
  - agent_capabilities: stores capabilities per agent with id (binary_id), agent_id (FK -> agents, on_delete: :delete_all), capability, max_risk_level (default 0), requires_cosign (default false), and timestamps. Unique index on (agent_id, capability).
  
  - intents: stores agent intents with id (binary_id), agent_id (FK -> agents, on_delete: :restrict), capability, optional resource_type/resource_id, risk_level (default 0), idempotency_key, payload (default %{}), payload_hash, status (default "submitted"), execution_notes, and inserted_at only. Unique index on (agent_id, idempotency_key); indexes on agent_id and status.
  
  - intent_decisions: stores decisions for intents with id (binary_id), intent_id (FK -> intents, on_delete: :delete_all), decision, reason, risk_score (default 0.0), policy_snapshot (default %{}), cosigned_by, cosigned_at, and inserted_at only. Unique index on (intent_id); index on decision.
  """
  @spec change() :: :ok
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