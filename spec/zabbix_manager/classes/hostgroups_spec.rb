# frozen_string_literal: true

require "spec_helper"

describe "ZabbixManager::HostGroups" do
  let(:actions_mock) { ZabbixManager::HostGroups.new(client) }
  let(:client) { double }

  describe ".method_name" do
    subject { actions_mock.method_name }

    it { is_expected.to eq "hostgroup" }
  end

  describe ".identify" do
    subject { actions_mock.identify }

    it { is_expected.to eq "name" }
  end

  describe ".key" do
    subject { actions_mock.key }

    it { is_expected.to eq "groupid" }
  end
end
