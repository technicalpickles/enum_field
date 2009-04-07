$LOAD_PATH.reject! { |path| path.include?('TextMate') }
require 'test/unit'
require 'rubygems'
require 'active_record'
require 'active_support'
require 'rr'
require 'shoulda'
require File.dirname(__FILE__)+'/../lib/enum_field'
require File.dirname(__FILE__)+'/../init'

class MockedModel; include EnumField; end;

class EnumFieldTest < Test::Unit::TestCase
  include RR::Adapters::TestUnit

  context "with a simple gender enum" do
    setup do
      @possible_values = %w( male female )
      mock(MockedModel).validates_inclusion_of :gender, :in => @possible_values, :message => "invalid gender"
      MockedModel.send(:enum_field, :gender, @possible_values)
    end
  
    should "create constant with possible values named as pluralized field" do
      assert_equal @possible_values, MockedModel::GENDERS
    end
    
    should "create query methods for each enum type" do
      model = MockedModel.new
      
      stub(model).gender.returns("male")
      assert model.male?
      assert !model.female?

      stub(model).gender.returns("female")
      assert !model.male?
      assert model.female?
    end
    
    should "extend active record base with method" do
      assert_respond_to ActiveRecord::Base, :enum_field
    end
  end

  context "Specifying a message" do
    setup do
      @possible_values = %w(on off)
      mock(MockedModel).validates_inclusion_of :status, :in => @possible_values, :message => "custom insult"
    end

    should "override the default message" do
      MockedModel.send(:enum_field, :status, @possible_values, :message => 'custom insult')
    end
  end

  context "With an enum containing multiple word choices" do
    setup do
      stub(MockedModel).validates_inclusion_of
      MockedModel.send :enum_field, :field, ['choice one', 'choice-two', 'other']
      @model = MockedModel.new
    end

    should "define an underscored query method for the multiple word choice" do
      assert_respond_to @model, :choice_one?
    end

    should "define an underscored query method for the dasherized choice" do
      assert_respond_to @model, :choice_two?
    end
  end

  context "With an enum containing mixed case choices" do
    setup do
      stub(MockedModel).validates_inclusion_of
      MockedModel.send :enum_field, :field, ['Choice One', 'ChoiceTwo', 'Other']
      @model = MockedModel.new
    end

    should "define a lowercase, underscored query method for the multiple word choice" do
      assert_respond_to @model, :choice_one?
    end

    should "define a lowercase query method for the camelcase choice" do
      assert_respond_to @model, :choicetwo?
    end
  end

  context "With an enum containing strange characters" do
    setup do
      stub(MockedModel).validates_inclusion_of
      MockedModel.send :enum_field, :field, ['choice%one', 'choice☺two', 'other.']
      @model = MockedModel.new
    end

    should "define a normal query method for the unicode choice" do
      assert_respond_to @model, :choice_two?
    end

    should "define a normal query method for the % choice" do
      assert_respond_to @model, :choice_one?
    end

    should "define a query method without the trailing punctuation for the other choice" do
      assert_respond_to @model, :other?
    end
  end
end

