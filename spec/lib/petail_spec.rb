# frozen_string_literal: true

require "spec_helper"

RSpec.describe Petail do
  subject(:petail) { described_class }

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

  describe ".[]" do
    it "answers payload" do
      expect(petail[**attributes]).to eq(described_class::Payload[**attributes])
    end
  end

  describe ".new" do
    it "answers payload" do
      expect(petail.new(**attributes)).to eq(described_class::Payload[**attributes])
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
          "balance": 30,
          "accounts": [
            "/accounts/1",
            "/accounts/10"
          ]
        }
      JSON
    end

    it "answers instance" do
      expect(petail.from_json(body)).to eq(described_class::Payload[**attributes])
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
        described_class::Payload[
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

  describe ".media_type_for" do
    it "answers JSON when given JSON" do
      expect(petail.media_type_for(:json)).to eq("application/problem+json")
    end

    it "answers XML when given XML" do
      expect(petail.media_type_for(:xml)).to eq("application/problem+xml")
    end

    it "answers empty string when unknown" do
      expect(petail.media_type_for(:bogus)).to eq("")
    end

    it "answers empty string when nil" do
      expect(petail.media_type_for(nil)).to eq("")
    end
  end
end
