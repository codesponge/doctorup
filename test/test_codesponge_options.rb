require 'helper'

require 'codesponge'


class TestCodespongeOptions < Test::Unit::TestCase
  context "A class that includes CodeSponge::Options" do
    setup do
      class ThingThatHasOptions
        @@options = {:color => "blue", :scoper => 'class original'}
        include CodeSponge::Options
      end
       @c = ThingThatHasOptions.new()
       #puts @c.class_methods
       puts ThingThatHasOptions.methods
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
    
  end
end