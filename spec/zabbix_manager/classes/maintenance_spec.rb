# frozen_string_literal: true

require "spec_helper"

describe "ZabbixManager::Maintenance" do
  let(:maintenance_mock) { ZabbixManager::Maintenance.new(client) }
  let(:client) { double }

  describe ".method_name" do
    subject { maintenance_mock.method_name }

    it { is_expected.to eq "maintenance" }
  end

  describe ".identify" do
    subject { maintenance_mock.identify }

    it { is_expected.to eq "name" }
  end
end
