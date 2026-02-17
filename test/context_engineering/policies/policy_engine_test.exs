defmodule ContextEngineering.Policies.PolicyEngineTest do
  use ExUnit.Case, async: true

  alias ContextEngineering.Contexts.Agents.Agent
  alias ContextEngineering.Contexts.Agents.AgentCapability
  alias ContextEngineering.Policies.PolicyEngine

  test "denies non-active agents" do
    agent = %Agent{status: "quarantined", trust_score: 0.8}
    capability = %AgentCapability{max_risk_level: 2, requires_cosign: false}

    result = PolicyEngine.evaluate(agent, capability, %{"risk_level" => 1})

    assert result.decision == "deny"
    assert result.reason == "agent_not_active"
  end

  test "requires cosign for high risk actions" do
    agent = %Agent{status: "active", trust_score: 0.8}
    capability = %AgentCapability{max_risk_level: 3, requires_cosign: false}

    result = PolicyEngine.evaluate(agent, capability, %{"risk_level" => 3})

    assert result.decision == "require_cosign"
    assert result.reason == "high_risk_requires_cosign"
  end

  test "requires evidence for low trust agent on elevated risk" do
    agent = %Agent{status: "active", trust_score: 0.2}
    capability = %AgentCapability{max_risk_level: 2, requires_cosign: false}

    result = PolicyEngine.evaluate(agent, capability, %{"risk_level" => 2})

    assert result.decision == "require_evidence"
    assert result.reason == "low_trust_requires_evidence"
  end
end
