# frozen_string_literal: true

module Petail
  module XML
    # Converts name and value into an XML element.
    Serializer = lambda do |name, value, node|
      if value.is_a? Array
        element = node.add_element name.to_s
        value.map { |item| element.add_element("i").add_text item.to_s }
      else
        node.add_element(name.to_s).add_text value.to_s
      end
    end
  end
end
