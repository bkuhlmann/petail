# frozen_string_literal: true

require "json"
require "rack/utils"
require "rexml"

module Petail
  # Models the problem details response payload.
  Payload = Struct.new :type, :title, :status, :detail, :instance, :extensions do
    def self.for(**attributes)
      status = attributes.delete(:status).then { Rack::Utils.status_code it if it }
      title = attributes.delete(:title).then { it || Rack::Utils::HTTP_STATUS_CODES[status] }

      new title:, status:, **attributes
    end

    def self.from_json(body) = self.for(**JSON(body, symbolize_names: true))

    # :reek:TooManyStatements
    def self.from_xml body, deserializer: XML::Deserializer
      elements = REXML::Document.new(body).root.elements

      attributes = elements.each_with_object({extensions: {}}) do |element, collection|
        name = element.name
        text = element.text

        case name
          when "type", "title", "detail", "instance", "status" then collection[name.to_sym] = text
          else collection[:extensions].merge! deserializer.call(element)
        end
      end

      self.for(**attributes)
    end

    def initialize(**)
      super
      self[:type] ||= "about:blank"
      self[:title] ||= Rack::Utils::HTTP_STATUS_CODES[status]
      self[:extensions] ||= {}
      freeze
    end

    def add_extension name, value
      self[:extensions][name] = value
      self
    end

    def extension?(name) = extensions.key? name

    def to_h = super.compact.tap { it.delete :extensions if extensions.empty? }

    def to_json(*) = to_h.to_json(*)

    # :reek:TooManyStatements
    def to_xml(serializer: XML::Serializer, **options)
      document = REXML::Document.new
      document.add REXML::XMLDecl.new("1.0", "UTF-8")

      problem = REXML::Element.new("problem").add_namespace("urn:ietf:rfc:7807")
      document.add problem

      attributes = to_h
      attributes.merge! attributes.delete :extensions if extensions.any?
      attributes.each { |name, value| serializer.call name, value, problem }

      "".dup.tap { document.write(**options, output: it) }
    end
  end
end
