# Agent-Delegated Full Autonomy Design

Date: 2026-02-16  
Status: Draft validated in collaborative brainstorming

## 1) Architecture Overview

### Goal
Build a platform that is fully dependent on user-owned agents for orchestration while the application acts as a deterministic memory, policy, and evaluation substrate.

### Core Principle
- **Agents decide** what actions to attempt.
- **Platform enforces** identity, policy, traceability, and outcomes.

### Control Plane
All write behavior follows:
1. Plan (agent creates signed intent)
2. Act (platform executes allowed intent)
3. Evaluate (outcome + quality capture)
4. Learn (trust/policy adaptation)

### Key Layers
1. **Agent Identity & Trust Layer**
   - Agent keys, tenant association, capabilities, trust tier, revocation/quarantine states.
2. **Capability Gateway**
   - Versioned action contracts (`create_adr`, `update_failure`, `link_context`, `archive_record`, etc.).
3. **Policy Decision Engine (PDE)**
   - Decides `allow | deny | delay | require_cosign | require_evidence`.
4. **Execution + Evidence Graph**
   - Persists immutable chain from intent to mutation and rationale.
5. **Continuous Evaluation Loop**
   - Tracks quality outcomes and updates trust score and policy strictness.

### Write Authority Model (selected)
**Hybrid authority**:
- Low-risk mutations can publish autonomously.
- High-risk actions require human cosign (or policy-defined dual evidence).

---

## 2) Components and Data Model

### New Components
1. **Agent Registry**
   - Lifecycle for agents: register, rotate keys, disable, quarantine, revoke.
2. **Intent Ledger**
   - Immutable append-only record of all intended writes.
3. **Policy Engine**
   - Evaluates risk and permissions using tenant, scope, capability, and history.
4. **Evidence Store**
   - Stores retrieval corpus, confidence metrics, references, and rationale.
5. **Outcome Tracker**
   - Measures post-action performance and reliability impact.

### Proposed Tables
- `agents`
- `agent_capabilities`
- `agent_keys`
- `intents`
- `intent_decisions`
- `evidence_artifacts`
- `action_outcomes`
- `trust_events`
- `policy_rules`
- `policy_overrides`

### Key Relationships
- `agents` 1:N `intents`
- `intents` 1:1 `intent_decisions`
- `intents` 1:N `evidence_artifacts`
- `intents` 1:N `action_outcomes`
- `agents` 1:N `trust_events`

### Risk Bands
- **L0**: low-risk metadata updates (tag/link/summarize)
- **L1**: normal content mutations
- **L2**: structural relationships and cross-domain merges
- **L3**: archival/deprecation/removal actions

Policy defaults map risk bands to required controls.

---

## 3) End-to-End Runtime Flow

### Sequence
1. **Agent submits signed intent**
   - Includes capability version, idempotency key, tenant scope, target resources.
2. **Gateway validates and normalizes**
   - Signature verification, key status check, schema normalization.
3. **PDE evaluation**
   - Inputs: risk band, blast radius, trust score, evidence quality, conflicts.
   - Outputs: allow/deny/delay/require_evidence/require_cosign.
4. **Evidence enrichment**
   - Attach semantic retrieval set, graph neighbors, related debates, recency slices.
5. **Transactional execution**
   - Apply mutation with concurrency controls; persist decision and evidence snapshot.
6. **Event publication**
   - Emit domain events (`context.updated`, `relationship.added`, etc.).
7. **Outcome observation**
   - Capture reversions, contradiction rates, incident recurrence, human feedback.
8. **Trust adaptation**
   - Update trust score and optional policy tightening/loosening per agent.

### Determinism Requirements
- Capability contracts are versioned.
- Input payload and normalized form are hash-persisted.
- Evidence snapshot is immutable and replayable.

---

## 4) Failure Modes, Guardrails, and Recovery

### Failure Modes
1. **Bad low-confidence write**
2. **Agent key compromise**
3. **Policy misconfiguration**
4. **Evidence drift (stale context)**
5. **Automation loops (agent repeatedly mutates same records)**

### Guardrails
- Mandatory idempotency keys for writes.
- Cooldowns for repeated action patterns.
- Blast-radius caps (max records touched per intent).
- Quarantine mode on anomaly detection.
- Human cosign for L3 actions.
- Optional dual-agent agreement for sensitive updates.

### Recovery and Rollback
- Revert operation generated for every mutating intent.
- Rollback events count negatively toward trust.
- Automatic temporary policy hardening after threshold breaches.
- Incident report generated from evidence chain for postmortems.

### Explainability
Each action exposes:
- actor identity
- retrieved context set
- confidence/risk scores
- applied policy rules
- exact diff and downstream outcomes

---

## 5) Delivery Plan, APIs, and Testing Strategy

### API Surface (first iteration)
- `POST /api/agents/register`
- `POST /api/intents`
- `GET /api/intents/:id`
- `POST /api/intents/:id/cosign`
- `POST /api/intents/:id/rollback`
- `GET /api/agents/:id/trust`
- `GET /api/policies/evaluate` (debug/visibility)

### Milestones
1. **M1: Identity + Intent Ledger + Policy skeleton**
2. **M2: Evidence capture + decision visibility**
3. **M3: Outcome tracker + trust adaptation**
4. **M4: Hybrid authority rollout (L3 cosign path)**
5. **M5: Agent SDK contracts + tenant onboarding toolkit**

### Test Strategy
- **Unit tests**
  - policy evaluation matrix (capability × risk × trust)
  - intent normalization and signature verification
  - trust score updates from outcome events
- **Integration tests**
  - intent submission through execution and event emission
  - cosign-required path and rollback path
  - policy hardening after repeated failures
- **Property tests**
  - idempotency and replay safety
- **Load tests**
  - high-rate intent ingestion and PDE latency SLOs

### Success Criteria
- ≥95% of low-risk intents auto-resolved within target latency.
- 100% of high-risk intents blocked or cosigned per policy.
- Full traceability (intent → decision → diff → outcome) for all mutations.
- Measurable trust calibration improvements over a rolling 30-day window.
