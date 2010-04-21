#
#		snippet
#
#		Created by William Champlin on 2010-04-16.
#		Copyright (c) 2010 CodeSponge. All rights reserved.
#
#-------------------------------------------------------------------------#

require 'helper'

#--------------------------------------------------------------------------

class	 Test_snippet_case < Test::Unit::TestCase

  context "A snippet" do
	  setup do
  		@snippet = Snippet.new
  	end

  	should "be like a string" do
  		assert_equal(@snippet, @snippet.to_s)
  	end

  	should "respond to these methods " do
      [:syntax_up,:to_html,:to_s,:sytaxify,:options].each do | method |
        assert_respond_to(@snippet, method)
      end
    end

    should "have options that behave like a hash" do
      assert_hashish(@snippet.options)
    end

    context "Created with a string" do
      setup do
        @snippet = Snippet.new("Hello there *folks*")
      end

      should "be like a sting" do
        assert_equal(@snippet, @snippet.to_s)
      end

    end # => context "Created with a string"
  end # => context "A snippet"
end # => class

