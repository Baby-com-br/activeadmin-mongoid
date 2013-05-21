require 'spec_helper'
require 'active_admin/mongoid/adaptor'

describe ActiveAdmin::Mongoid::Adaptor::Search do

  class Product
    include Mongoid::Document

    attr_accessible :name
    field :name, :type => String
  end

  after { Product.delete_all }

  let(:search_params) { {} }
  subject(:search) { described_class.new(Product, search_params).to_a }

  let!(:product) { Product.create(:name => "Something totally random") }
  let!(:product_2) { Product.create(:name => "abra cadabra") }

  it { should == [product, product_2] }

  context "when there are search params with contains" do
    let(:search_params) { { 'name_contains' => "Something" } }

    it { should == [product] }

    context "and scrambled case" do
      let(:search_params) { { 'name_contains' => "SomeThing ToTaLLy" } }
      it { should == [product] }
    end
  end

  context "when there are search params with eq" do
    let(:search_params) { { 'name_eq' => "abra cadabra" } }

    it { should == [product_2] }
  end
end
