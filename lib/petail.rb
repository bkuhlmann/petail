# frozen_string_literal: true

require "petail/payload"
require "petail/xml/deserializer"
require "petail/xml/serializer"

# Main namespace.
module Petail
  MEDIA_TYPE_JSON = "application/problem+json"
  MEDIA_TYPE_XML = "application/problem+xml"
  TYPES = %i[json xml].freeze

  def self.from_json(...) = Payload.from_json(...)

  def self.from_xml(...) = Payload.from_xml(...)

  def self.media_type_for key, types: TYPES
    types.include?(key) ? const_get("MEDIA_TYPE_#{key.upcase}") : ""
  end

  def self.new(**) = Payload.for(**)
end
