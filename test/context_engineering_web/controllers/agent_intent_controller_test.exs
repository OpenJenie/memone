defmodule ContextEngineeringWeb.AgentIntentControllerTest do
  use ContextEngineeringWeb.ConnCase

  defp register_agent(conn, attrs \\ %{}) do
    params =
      Map.merge(
        %{
          "name" => "planner-agent",
          "tenant_id" => "tenant-a",
          "capabilities" => [
            %{"capability" => "update_adr", "max_risk_level" => 2, "requires_cosign" => false},
            %{"capability" => "archive_record", "max_risk_level" => 3, "requires_cosign" => true}
          ]
        },
        attrs
      )

    post(conn, "/api/agents/register", params)
  end

  test "POST /api/agents/register creates an agent with capabilities", %{conn: conn} do
    conn = register_agent(conn)

    response = json_response(conn, 201)

    assert response["name"] == "planner-agent"
    assert response["tenant_id"] == "tenant-a"
    assert length(response["capabilities"]) == 2
  end

  test "GET /api/agents/:id/trust returns trust score", %{conn: conn} do
    conn = register_agent(conn)
    agent = json_response(conn, 201)

    conn = get(conn, "/api/agents/#{agent["id"]}/trust")
    response = json_response(conn, 200)

    assert response["agent_id"] == agent["id"]
    assert response["trust_score"] == 0.5
    assert response["status"] == "active"
  end

  test "POST /api/intents evaluates and executes allowed intent", %{conn: conn} do
    conn = register_agent(conn)
    agent = json_response(conn, 201)

    conn =
      post(conn, "/api/intents", %{
        "agent_id" => agent["id"],
        "capability" => "update_adr",
        "resource_type" => "adr",
        "resource_id" => "ADR-001",
        "risk_level" => 2,
        "idempotency_key" => Ecto.UUID.generate(),
        "payload" => %{"status" => "accepted"}
      })

    response = json_response(conn, 201)

    assert response["status"] == "executed"
    assert response["decision"]["decision"] == "allow"
    assert response["decision"]["reason"] == "policy_allow"
  end

  test "POST /api/intents returns needs_cosign for high-risk capability", %{conn: conn} do
    conn = register_agent(conn)
    agent = json_response(conn, 201)

    conn =
      post(conn, "/api/intents", %{
        "agent_id" => agent["id"],
        "capability" => "archive_record",
        "resource_type" => "failure",
        "resource_id" => "FAIL-001",
        "risk_level" => 3,
        "idempotency_key" => Ecto.UUID.generate(),
        "payload" => %{"status" => "archived"}
      })

    response = json_response(conn, 201)

    assert response["status"] == "needs_cosign"
    assert response["decision"]["decision"] == "require_cosign"

    conn =
      post(conn, "/api/intents/#{response["id"]}/cosign", %{
        "cosigned_by" => "human-reviewer"
      })

    response = json_response(conn, 200)
    assert response["status"] == "executed"
    assert response["decision"]["cosigned_by"] == "human-reviewer"
  end

  test "POST /api/policies/evaluate returns policy decision", %{conn: conn} do
    conn = register_agent(conn)
    agent = json_response(conn, 201)

    conn =
      post(conn, "/api/policies/evaluate", %{
        "agent_id" => agent["id"],
        "capability" => "archive_record",
        "risk_level" => 3
      })

    response = json_response(conn, 200)

    assert response["decision"] == "require_cosign"
    assert response["reason"] == "high_risk_requires_cosign"
  end

  test "POST /api/intents/:id/rollback rolls back executed intent", %{conn: conn} do
    conn = register_agent(conn)
    agent = json_response(conn, 201)

    conn =
      post(conn, "/api/intents", %{
        "agent_id" => agent["id"],
        "capability" => "update_adr",
        "resource_type" => "adr",
        "resource_id" => "ADR-002",
        "risk_level" => 1,
        "idempotency_key" => Ecto.UUID.generate(),
        "payload" => %{"status" => "accepted"}
      })

    created_intent = json_response(conn, 201)

    conn =
      post(conn, "/api/intents/#{created_intent["id"]}/rollback", %{
        "reason" => "Unexpected side effect"
      })

    response = json_response(conn, 200)
    assert response["status"] == "rolled_back"
    assert response["execution_notes"] =~ "Unexpected side effect"
  end


  test "POST /api/agents/register is atomic when a capability is invalid", %{conn: conn} do
    conn =
      register_agent(conn, %{
        "name" => "atomic-agent",
        "capabilities" => [
          %{"capability" => "update_adr", "max_risk_level" => 2},
          %{"capability" => "archive_record", "max_risk_level" => 9}
        ]
      })

    response = json_response(conn, 422)
    assert response["errors"]["max_risk_level"]

    conn = get(conn, "/api/agents?tenant_id=tenant-a")
    agents = json_response(conn, 200)

    refute Enum.any?(agents, fn agent -> agent["name"] == "atomic-agent" end)
  end

  test "POST /api/policies/evaluate returns forbidden for unknown capability", %{conn: conn} do
    conn = register_agent(conn)
    agent = json_response(conn, 201)

    conn =
      post(conn, "/api/policies/evaluate", %{
        "agent_id" => agent["id"],
        "capability" => "delete_everything",
        "risk_level" => 1
      })

    response = json_response(conn, 403)
    assert response["error"] == "Capability not allowed for this agent"
  end

end
