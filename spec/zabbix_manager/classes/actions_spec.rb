# frozen_string_literal: true

require "spec_helper"

describe "ZabbixManager::Actions" do
  let(:actions_mock) { ZabbixManager::Actions.new(client) }
  let(:client) { double }

  describe ".method_name" do
    subject { actions_mock.method_name }

    it { is_expected.to eq "action" }
  end

  describe ".identify" do
    subject { actions_mock.identify }

    it { is_expected.to eq "name" }
  end
end
