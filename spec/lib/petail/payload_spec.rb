# frozen_string_literal: true

require "petail/payload"
require "spec_helper"

RSpec.describe Petail::Payload do
  subject(:payload) { described_class[**attributes] }

  let :attributes do
    {
      type: "https://test.io/problem_details/out_of_credit",
      title: "You do not have enough credit.",
      status: 403,
      detail: "Your current balance is 30, but that costs 50.",
      instance: "/accounts/1",
      extensions: {
        balance: 30,
        accounts: %w[/accounts/1 /accounts/10]
      }
    }
  end

  describe ".for" do
    it "answers default attributes" do
      expect(described_class.for).to eq(described_class.new)
    end

    it "answers custom attributes" do
      expect(described_class.for(**attributes)).to eq(described_class[**attributes])
    end

    it "answers status and title when given status symbol" do
      expect(described_class.for(status: :accepted)).to eq(
        described_class[title: "Accepted", status: 202]
      )
    end

    it "answers status custom title when given status symbol and custom title" do
      expect(described_class.for(status: :accepted, title: "Test")).to eq(
        described_class[title: "Test", status: 202]
      )
    end
  end

  describe ".from_json" do
    let :body do
      <<~JSON
        {
          "type": "https://test.io/problem_details/out_of_credit",
          "title": "You do not have enough credit.",
          "status": 403,
          "detail": "Your current balance is 30, but that costs 50.",
          "instance": "/accounts/1",
          "extensions": {
            "balance": 30,
            "accounts": [
              "/accounts/1",
              "/accounts/10"
            ]
          }
        }
      JSON
    end

    it "answers instance" do
      expect(described_class.from_json(body)).to eq(payload)
    end
  end

  describe ".from_xml" do
    let :body do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <problem xmlns="urn:ietf:rfc:7807">
          <type>https://test.io/problem_details/out_of_credit</type>
          <title>You do not have enough credit.</title>
          <status>403</status>
          <detail>Your current balance is 30, but that costs 50.</detail>
          <instance>/accounts/1</instance>
          <balance>30</balance>
          <accounts>
            <i>/accounts/1</i>
            <i>/accounts/10</i>
          </accounts>
        </problem>
      XML
    end

    it "answers instance" do
      expect(described_class.from_xml(body)).to eq(
        described_class[
          type: "https://test.io/problem_details/out_of_credit",
          title: "You do not have enough credit.",
          status: 403,
          detail: "Your current balance is 30, but that costs 50.",
          instance: "/accounts/1",
          extensions: {
            balance: "30",
            accounts: %w[/accounts/1 /accounts/10]
          }
        ]
      )
    end
  end

  describe "#initialize" do
    it "sets defaults" do
      payload = described_class.new
      expect(payload).to eq(described_class[type: "about:blank", extensions: {}])
    end

    it "sets title when title is missing and status code is given" do
      payload = described_class[status: 200]

      expect(payload).to eq(
        described_class[type: "about:blank", title: "OK", status: 200, extensions: {}]
      )
    end

    it "is frozen" do
      expect(payload.frozen?).to be(true)
    end
  end

  describe "#to_h" do
    it "answers default attributes" do
      expect(described_class.new.to_h).to eq({type: "about:blank"})
    end

    it "answers custom attributes" do
      expect(payload.to_h).to eq(
        type: "https://test.io/problem_details/out_of_credit",
        title: "You do not have enough credit.",
        status: 403,
        detail: "Your current balance is 30, but that costs 50.",
        instance: "/accounts/1",
        extensions: {
          balance: 30,
          accounts: %w[/accounts/1 /accounts/10]
        }
      )
    end
  end

  describe "#add_extension" do
    subject(:payload) { described_class.new }

    it "adds extension" do
      payload.add_extension :test, "test"
      expect(payload.extensions).to eq(test: "test")
    end

    it "answers itself" do
      expect(payload.add_extension(:test, "test")).to eq(
        described_class[extensions: {test: "test"}]
      )
    end
  end

  describe "#extension?" do
    subject(:payload) { described_class[extensions: {test: "test"}] }

    it "answers true when extension exists" do
      expect(payload.extension?(:test)).to be(true)
    end

    it "answers false when extension doesn't exist" do
      expect(payload.extension?(:bogus)).to be(false)
    end
  end

  describe "#to_json" do
    it "answers default JSON" do
      expect(payload.to_json).to eq(<<~JSON.strip)
        {"type":"https://test.io/problem_details/out_of_credit","title":"You do not have enough credit.","status":403,"detail":"Your current balance is 30, but that costs 50.","instance":"/accounts/1","extensions":{"balance":30,"accounts":["/accounts/1","/accounts/10"]}}
      JSON
    end

    it "answers custom JSON" do
      json = payload.to_json indent: "  ", space: " ", object_nl: "\n", array_nl: "\n"

      expect(json).to eq(<<~JSON.strip)
        {
          "type": "https://test.io/problem_details/out_of_credit",
          "title": "You do not have enough credit.",
          "status": 403,
          "detail": "Your current balance is 30, but that costs 50.",
          "instance": "/accounts/1",
          "extensions": {
            "balance": 30,
            "accounts": [
              "/accounts/1",
              "/accounts/10"
            ]
          }
        }
      JSON
    end
  end

  describe "#to_xml" do
    let :pretty_print do
      <<~XML.strip
        <?xml version='1.0' encoding='UTF-8'?>
        <problem xmlns='urn:ietf:rfc:7807'>
          <type>
            https://test.io/problem_details/out_of_credit
          </type>
          <title>
            You do not have enough credit.
          </title>
          <status>
            403
          </status>
          <detail>
            Your current balance is 30, but that costs 50.
          </detail>
          <instance>
            /accounts/1
          </instance>
          <balance>
            30
          </balance>
          <accounts>
            <i>
              /accounts/1
            </i>
            <i>
              /accounts/10
            </i>
          </accounts>
        </problem>
      XML
    end

    it "answers XML" do
      expect(payload.to_xml).to eq(
        "<?xml version='1.0' encoding='UTF-8'?><problem xmlns='urn:ietf:rfc:7807'>" \
        "<type>https://test.io/problem_details/out_of_credit</type>" \
        "<title>You do not have enough credit.</title><status>403</status>" \
        "<detail>Your current balance is 30, but that costs 50.</detail>" \
        "<instance>/accounts/1</instance>" \
        "<balance>30</balance>" \
        "<accounts><i>/accounts/1</i><i>/accounts/10</i></accounts></problem>"
      )
    end

    it "answers formatted XML" do
      expect(payload.to_xml(indent: 2)).to eq(pretty_print)
    end
  end
end
