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


  # should "fail" do
  #   assert false
  # end
  
	context "An empty Snippet" do
		setup do
			@snippet = Snippet.new
		end

		should "be like a string" do
			assert_equal(@snippet, @snippet.to_s)
		end
	end


	  
  context "A snippet with some text" do
    setup do
      @snippet = Snippet.new("Hello there *folks*")
    end

    should "be like a string" do
      assert_equal(@snippet, @snippet.to_s)
    end
    
    
    should "at least claim to respond to some methods" do
      [:syntax_up,:to_html,:to_s,:sytaxify].each do | method |
        assert_respond_to(@snippet, method)
      end
    end
    
  end
  
	
end
