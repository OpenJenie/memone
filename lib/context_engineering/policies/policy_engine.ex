defmodule ContextEngineering.Policies.PolicyEngine do
  @moduledoc """
  Minimal policy decision engine for agent-delegated intent execution.
  """

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
