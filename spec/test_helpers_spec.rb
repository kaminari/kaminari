require File.expand_path('spec_helper', File.dirname(__FILE__))
include Kaminari::TestHelpers

describe "Kaminari::TestHelpers::" do

  describe "discover_mock_framework" do

    context "when the mock framework does not support framework_name" do

      before do
        dumb_framework = Object.new
        stub(RSpec.configuration).mock_framework { dumb_framework }
      end

      it "should return :nothing" do
        puts ("in here")
        discover_mock_framework.should == :nothing

      end

    end

    context "when the mock framework does support framework_name" do

      before do
        mock_framework = RSpec.configuration.mock_framework
        stub(mock_framework).respond_to?(:framework_name) { true }
        stub(mock_framework).framework_name { :my_framework }
      end

      it "should return the framework name" do
        discover_mock_framework.should == :my_framework
      end

    end

  end

  describe "calculate_values" do

    context "when no total_count is specified" do

      context "and when passed an object that does not implement length" do

        it "sets total_count to 1" do

          values = calculate_values(Object.new)
          values[:total_count].should == 1

        end

      end

      context "and when passed an object that implements length" do

        it "sets total_count to the length of the object" do

          values = calculate_values([ Object.new, Object.new])
          values[:total_count].should == 2

        end

      end


    end

    context "when total_count is specified" do

      it "sets the total_count to the specified value" do

        values = calculate_values(Object.new, :total_count => 13)
        values[:total_count].should == 13

      end

    end

    context "when per_page is not specified" do

      it "set per_page to the default of 25" do

        values = calculate_values(Object.new)
        values[:per_page].should == 25

      end

    end

    context "when per_page is specified" do

      it "sets per_page to the specified value" do

        values = calculate_values(Object.new, :per_page => 17)
        values[:per_page].should == 17

      end

    end

    it "sets num_pages based on total_count and per_page" do
      values = calculate_values(Object.new, :total_count => 50, :per_page => 25)
      values[:num_pages].should == 2
    end

    context "when current_page is not specified" do

      it "set current_page to the default of 1" do

        values = calculate_values(Object.new)
        values[:current_page].should == 1

      end

    end

    context "when current_page is specified" do

      it "sets current_page to the specified value" do

        values = calculate_values(Object.new, :current_page => 19)
        values[:current_page].should == 19

      end

    end

  end

  describe "stub_pagination" do

    context "when passed a nil resource" do

      it "returns nil" do
        result = stub_pagination(nil)
        result.should be_nil
      end

    end

    context "when passed a non nil resource" do

      # we check for total_count, to know if the stubbing was successful, no need to check for each
      # method individually
      it "has the total_count method stubbed" do
        resource = Object.new
        result = stub_pagination(resource, :mock => :rr, :total_count => 23)
        result.total_count.should == 23
      end

      context "and an unknown mocking framework" do

        it "raises an error" do
          resource = Object.new
          expect { stub_pagination(resource, :mock => :my_mock)}.to raise_error(ArgumentError)

        end

      end

    end

  end

end


