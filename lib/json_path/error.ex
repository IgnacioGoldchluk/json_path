defmodule JSONPath.Error do
  @moduledoc """
  Error value for invalid JSONPath queries
  """
  defexception [:type, :expression, message: ""]

  @type error_type ::
          :invalid_expression
          | :unexpcected_argument
          | :unexpected_comparison
          | :invalid_number
          | :invalid_unicode
          | :invalid_pattern

  @type t() :: %__MODULE__{
          expression: binary(),
          message: binary(),
          type: error_type()
        }

  @impl true
  def message(%{type: type, message: "", expression: expr} = _error) do
    "#{type}: #{expr}"
  end

  @impl true
  def message(%{type: type, expression: expr, message: message} = _error) do
    "#{type} (#{message}): #{expr}"
  end
end
