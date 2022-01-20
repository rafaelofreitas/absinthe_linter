defmodule AbsintheLinter.Rules.EnumValuesSortedAlphabetically do
  @moduledoc """
  Ensure enum values are sorted alphabetically.
  """
  @behaviour Absinthe.Phase
  alias Absinthe.Blueprint

  def run(blueprint, _options \\ []) do
    blueprint = Blueprint.prewalk(blueprint, &validate_node/1)

    {:ok, blueprint}
  end

  defp validate_node(%Blueprint.Schema.EnumTypeDefinition{name: "__" <> _} = node) do
    node
  end

  defp validate_node(%Blueprint.Schema.EnumTypeDefinition{} = node) do
    if sorted_values?(node) do
      node
    else
      node |> Absinthe.Phase.put_error(error(node))
    end
  end

  defp validate_node(node) do
    node
  end

  defp sorted_values?(node) do
    Enum.sort_by(node.values, & &1.name) == node.values
  end

  defp error(node) do
    %Absinthe.Phase.Error{
      message: "Enum values are not sorted alphabetically",
      locations: [node.__reference__.location],
      phase: __MODULE__
    }
  end
end
