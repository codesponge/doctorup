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



  
	context "An empty Snippet" do
		setup do
			@snippet = Snippet.new
		end

		should "be like a string" do
			assert_equal(@snippet, @snippet.to_s)
		end
	end
	  
  context "A snippet" do
    setup do
      @snippet = Snippet.new("Hello there *folks*")
    end

    should "be like a string" do
      assert_equal(@snippet, @snippet.to_s)
    end
    
    
    should "respond to these methods " do
      [:syntax_up,:to_html,:to_s,:sytaxify,:options,:settings].each do | method |
        assert_respond_to(@snippet, method)
      end
    end
    
    should "have options that behave like a hash" do
      assert_hashish @snippet
    end
    
    should "have options that are settable" do
      opt_key,opt_value = relativly_random_string,relativly_random_string
      @snippet.options[opt_key] = opt_value
      assert @snippet.options.has_key? opt_key
      assert_equal(@snippet.options[opt_key], opt_value)
    end
    
  end
end