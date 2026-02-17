defmodule ContextEngineering.Policies.PolicyEngine do
  @doc """
  Decides whether an agent may execute a capability based on risk level, capability constraints, and agent trust.
  
  Evaluates the provided `attrs` for a "risk_level" (defaults to 0) and applies policy rules in order:
  - deny if the agent is not active;
  - deny if the capability is not provided;
  - deny if the risk level exceeds the capability's `max_risk_level`;
  - require cosign if the capability requires cosign or the risk level is 3 or higher;
  - require evidence if the agent's `trust_score` is less than 0.3 and the risk level is 2 or higher;
  - allow otherwise.
  
  Parameters
  
    - agent: Map representing the agent (expects keys like `:status` and `:trust_score`).
    - capability: Map or `nil`. When present, expected keys include `:max_risk_level` and `:requires_cosign`.
    - attrs: Map of attributes; the `"risk_level"` key is used and defaults to 0 when absent.
  
  Returns
  
    - A map containing:
      - `:decision` - decision string (`"deny"`, `"require_cosign"`, `"require_evidence"`, or `"allow"`).
      - `:reason` - short reason code for the decision.
      - `:risk_score` - numeric risk score computed from the evaluated risk level.
      - `:policy_snapshot` - map with evaluated policy details (`max_risk_level`, `requires_cosign`, and `evaluated_risk_level`).
  """
  @spec evaluate(map(), map() | nil, map()) :: map()

  def evaluate(agent, capability, attrs) do
    risk_level = Map.get(attrs, "risk_level", 0)

    cond do
      agent.status != "active" ->
        decision("deny", "agent_not_active", risk_level, capability)

      is_nil(capability) ->
        decision("deny", "capability_not_allowed", risk_level, capability)

      risk_level > capability.max_risk_level ->
        decision("deny", "risk_level_exceeds_capability", risk_level, capability)

      capability.requires_cosign or risk_level >= 3 ->
        decision("require_cosign", "high_risk_requires_cosign", risk_level, capability)

      agent.trust_score < 0.3 and risk_level >= 2 ->
        decision("require_evidence", "low_trust_requires_evidence", risk_level, capability)

      true ->
        decision("allow", "policy_allow", risk_level, capability)
    end
  end

  defp decision(decision, reason, risk_level, capability) do
    %{
      decision: decision,
      reason: reason,
      risk_score: risk_level / 3,
      policy_snapshot: %{
        max_risk_level: capability && capability.max_risk_level,
        requires_cosign: capability && capability.requires_cosign,
        evaluated_risk_level: risk_level
      }
    }
  end
end