# frozen_string_literal: true

require "spec_helper"

RSpec.describe Petail::XML::Serializer do
  subject(:serializer) { described_class }

  describe "#call" do
    let :document do
      document = REXML::Document.new
      document << REXML::XMLDecl.new("1.0", "UTF-8")

      problem = REXML::Element.new "problem"
      document.add problem
    end

    it "answers element with array" do
      serializer.call :test, %w[one two], document

      expect(document.to_s).to eq("<problem><test><i>one</i><i>two</i></test></problem>")
    end

    it "answers element with name and value" do
      serializer.call :test, "test", document

      expect(document.to_s).to eq("<problem><test>test</test></problem>")
    end
  end
end
