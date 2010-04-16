require 'helper'

#puts DoctorUp.methods.include?('silence_warnings')

class TestDoctorup < Test::Unit::TestCase
  
  should "have had a better time last night" do
    assert true
  end
  
  context "When DoctorUp is included" do
    setup do
      
    end
    should "actually silence warnings" do
      
      txt = silence_warnings do
        warn "this warning should be suppressed"
        assert_nil $VERBOSE, "Warnings are not nil"
      end
      
    end
  end
end
