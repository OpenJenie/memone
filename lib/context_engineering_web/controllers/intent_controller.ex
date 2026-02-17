defmodule ContextEngineeringWeb.IntentController do
  use ContextEngineeringWeb, :controller

  alias ContextEngineering.Knowledge

  @doc """
  Handle an HTTP request to submit a new intent.
  
  Accepts a map of intent attributes, submits the intent via the Knowledge context, and sends an appropriate JSON HTTP response:
  - 201 Created with the created intent on success.
  - 404 Not Found with `{error: "Agent not found"}` if the agent is missing.
  - 403 Forbidden with `{error: "Capability not allowed for this agent"}` if the agent lacks capability.
  - 422 Unprocessable Entity with `{errors: ...}` when validation fails.
  
  ## Parameters
  
    - params: Map of attributes for the intent to be submitted.
  
  @returns The updated Plug connection containing the JSON response corresponding to the submission outcome.
  """
  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, params) do
    case Knowledge.submit_intent(params) do
      {:ok, intent} ->
        conn
        |> put_status(:created)
        |> json(intent)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Agent not found"})

      {:error, :capability_not_allowed} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Capability not allowed for this agent"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Knowledge.format_errors(changeset)})
    end
  end

  @doc """
  Retrieves an intent by its ID and renders it as JSON.
  
  If the intent exists, responds with the intent payload; if not, responds with HTTP 404 and a JSON error message.
  """
  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    case Knowledge.get_intent(id) do
      {:ok, intent} ->
        json(conn, intent)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Intent not found"})
    end
  end

  @doc """
  Attempts to cosign an intent and responds with the resulting JSON payload.
  
  On success returns the updated intent JSON.
  On failure returns one of:
    - 404 with `{"error": "Intent not found"}` when the intent does not exist.
    - 422 with `{"error": "Intent is not pending cosign"}` when the intent status is invalid.
    - 422 with `{"errors": ...}` when validation errors are present (formatted via Knowledge.format_errors/1).
  """
  @spec cosign(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def cosign(conn, %{"id" => id, "cosigned_by" => cosigned_by}) do
    case Knowledge.cosign_intent(id, cosigned_by) do
      {:ok, intent} ->
        json(conn, intent)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Intent not found"})

      {:error, :invalid_status} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Intent is not pending cosign"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Knowledge.format_errors(changeset)})
    end
  end

  @doc """
  Handle cosign requests that are missing the required "cosigned_by" parameter.
  
  Responds with HTTP 422 and a JSON body describing the missing parameter.
  """
  @spec cosign(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def cosign(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "cosigned_by is required"})
  end

  @doc """
  Initiates a rollback for the intent identified by `id` using an optional `"reason"`.
  
  Performs a rollback via the Knowledge context and sends a JSON response:
  - on success returns the updated intent as JSON,
  - on failure returns a JSON error with an appropriate HTTP status.
  
  ## Parameters
  
    - params: map containing `"id"` (required) and optional `"reason"` (defaults to `"Manual rollback"`).
  
  ## Returns
  
  The connection with a JSON response: the updated intent on success, or an error payload and status on failure.
  """
  @spec rollback(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def rollback(conn, %{"id" => id} = params) do
    reason = Map.get(params, "reason", "Manual rollback")

    case Knowledge.rollback_intent(id, reason) do
      {:ok, intent} ->
        json(conn, intent)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Intent not found"})

      {:error, :invalid_status} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Intent is not in an executable state"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Knowledge.format_errors(changeset)})
    end
  end
end