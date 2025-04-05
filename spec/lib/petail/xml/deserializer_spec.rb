# frozen_string_literal: true

require "spec_helper"

RSpec.describe Petail::XML::Deserializer do
  subject(:deserializer) { described_class }

  describe "#call" do
    it "answers array" do
      node = REXML::Element.new "list"
      node.add_element("i").add_text("one")
      node.add_element("i").add_text("two")

      expect(deserializer.call(node)).to eq({list: %w[one two]})
    end

    it "answers hash" do
      node = REXML::Element.new "list"
      node.add_element("one").add_text("1")
      node.add_element("two").add_text("2")

      expect(deserializer.call(node)).to eq({one: "1", two: "2"})
    end

    it "answers nested hash" do
      document = REXML::Document.new
      one = document.add_element "one"
      two = one.add_element "two"
      three = two.add_element "three"
      three.text = "3"

      expect(deserializer.call(document)).to eq({one: {two: {three: "3"}}})
    end
  end
end
