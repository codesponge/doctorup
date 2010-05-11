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

    context "Created with a string" do
      setup do
        @snippet = Snippet.new("Hello there *folks*")
      end

      should "be like a sting" do
        assert_equal(@snippet, @snippet.to_s)
      end

      should "not change if it doesn't have to" do
        assert_equal(@snippet, @snippet.to_html)
      end

    end # => context "Created with a string"

    context "with input code block" do
      setup do
        @source_str ="<code lang='ruby'>
        class Dog < Animal
          def speak
            'Woof'
          end
        end"
        @snippet = Snippet.new(@source_str)
      end

      should "output String when to_html called" do
        syntaxed = @snippet.to_html
        assert(syntaxed.class == String)
      end

    end # => context "created with a string containing a <code> block"
  end # => context "A snippet"
end # => class

