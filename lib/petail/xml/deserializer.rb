# frozen_string_literal: true

module Petail
  module XML
    # Converts an XML element into a Hash.
    Deserializer = lambda do |node, attributes = {}|
      if node.has_elements?
        node.each_element do |element|
          if element.name == "i"
            attributes[node.name.to_sym] ||= []
            attributes[node.name.to_sym].push element.text
          elsif element.elements.empty?
            attributes[element.name.to_sym] = element.text
          else
            attributes = {element.name.to_sym => Deserializer.call(element, attributes)}
          end
        end
      else
        attributes[node.name.to_sym] = node.text
      end

      attributes
    end
  end
end
