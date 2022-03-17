# frozen_string_literal: true

require "spec_helper"

describe "ZabbixManager::Problems" do
  let(:problems_mock) { ZabbixManager::Problems.new(client) }
  let(:client) { double }

  describe ".method_name" do
    subject { problems_mock.method_name }

    it { is_expected.to eq "problem" }
  end

  describe ".identify" do
    subject { problems_mock.identify }

    it { is_expected.to eq "name" }
  end

  # Problem object does not have a unique identifier
  describe ".key" do
    subject { problems_mock.key }

    it { is_expected.to eq "problemid" }
  end

  # Problem object does not have a unique identifier
  describe ".keys" do
    subject { problems_mock.keys }

    it { is_expected.to eq "problemids" }
  end
end
