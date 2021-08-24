# frozen_string_literal: true

class CustomFieldValue < Dry::Struct
  attribute :field_id?, Types::Integer
  attribute :field_code?, Types::String
end

class CustomFieldValue::Text < CustomFieldValue
  attribute :values, Types::Strict::Array.of(
    Types::Hash.schema(value: Types::Strict::String)
  )
end

class CustomFieldValue::Checkbox < CustomFieldValue
  attribute :values, Types::Strict::Array.of(
    Types::Hash.schema(value: Types::Strict::Bool)
  )
end

class CustomFieldValue::Multitext < CustomFieldValue
  attribute :values, Types::Strict::Array.of(
    Types::Hash.schema(
      value: Types::Strict::String,
      enum_id?: Types::Integer,
      enum_code?: Types::String
    )
  )
end

class CustomFieldsValues < Dry::Struct
  attribute :custom_fields_values, Types::Strict::Array.of(
    CustomFieldValue
  )
end
