defmodule Plaidex.Config do
  @moduledoc false

  def current_scope do
    if Process.get(:plaidex_auth, false), do: :process, else: :global
  end

  def get, do: get(current_scope())

  defp get(:global) do
    case Application.get_env(:plaidex, :plaidex_auth, nil) do
      nil -> set_application_env()
      config -> config
    end
    Application.get_env(:plaidex, :plaidex_auth, nil)
  end

  defp get(:process), do: Process.get(:plaidex_auth, nil)

  defp set_application_env() do
    config = ["plaid_client_id", "plaid_public_key", "plaid_secret"]
             |> Enum.reduce(%{}, fn (v, c) -> Map.put(c, String.to_atom(v), get_system_value(v)) end)
    Application.put_env(:plaidex, :plaidex_auth, config, [])
    config
  end

  defp get_system_value(val) do
    val
    |> String.upcase()
    |> System.get_env()
  end

  def set(value), do: set(current_scope(), value)

  def set(:global, value), do: Application.put_env(:plaidex, :plaidex_auth, value, [])

  def set(:process, value) do
    Process.put(:plaidex_auth, value)
    :ok
  end

end