defmodule JSONPath.Error do
  @moduledoc """
  Error value for invalid JSONPath queries
  """
  defstruct [:type, :expression, message: ""]

  @type error_type ::
          :invalid_expression
          | :unexpcected_argument
          | :unexpected_comparison
          | :invalid_number
          | :invalid_unicode

  @type t() :: %__MODULE__{
          expression: binary(),
          message: binary(),
          type: error_type()
        }
end
