require 'rubygems'
require 'test/unit'
require 'shoulda'
begin
  require 'turn'
rescue LoadError
  ""
end



$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'doctorup'
require 'snippet'

class Test::Unit::TestCase
  DATA_DIR = File.join(File.dirname(__FILE__), 'data')
  
  
  def assert_hashish(object)
    [:key,:keys,:has_key?].each do |method|
      assert_respond_to(object, :method)
    end
    
    
    
  end
  
  def relativly_random_string(chars = 8)
    ar = [] + ('a'..'z').to_a + ('A'..'Z').to_a
    os = ""
    chars.times{ os << ar[rand(ar.size)] }
    os
  end
  
  
end
