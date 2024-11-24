defmodule Realworld.Policy do
  @callback authorize(atom(), map() | nil, map() | nil) :: {:ok, map() | nil} | {:error, atom()}

  def allowed_to?(module, action, user), do: allowed_to?(module, action, user, nil)

  def allowed_to?(module, action, user, resource) do
    case module.authorize(action, user, resource) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  def authorize(module, action, user), do: module.authorize(action, user, nil)
  def authorize(module, action, user, resource), do: module.authorize(action, user, resource)
end
