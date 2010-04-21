require 'helper'

require 'codesponge'


class TestCodespongeOptions < Test::Unit::TestCase
  context "A class that includes CodeSponge::Options" do
    setup do

      class ThingThatHasOptions
        @@options = {:color => "blue", :scoper => 'class original'}
        include CodeSponge::Options
        def initialize(value = nil,opts={})
          @options = self.class.options.merge opts
        end
      end

       @c = ThingThatHasOptions.new()
       #puts @c.class_methods
    end

    should "have had a better time last night" do
      assert true
    end

    should "respond_to options" do
      assert_respond_to(@c, :options)
    end
    should "return a hash when options is called" do
      assert_hashish( @c.options )
    end

    should "return a default value" do
      assert_equal(@c.options[:color] , "blue")
    end

    should "return an option set in the class" do
      assert_equal(@c.options[:scoper],"class original")
    end

    should "be able to set an option" do
      key,val = relativly_random_string,relativly_random_string
      @c.options[key] = val
      assert_equal(@c.options[key],val)
    end

  end
end