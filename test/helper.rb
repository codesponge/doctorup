require 'rubygems'
require 'test/unit'
require 'shoulda'

begin
  #turn pretties up test output
  require 'turn'
rescue LoadError
  #current version of turn (0.7.0) doesn't work on 1.9.x
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
    opt_key,opt_value = relativly_random_string,relativly_random_string
    object[opt_key] = opt_value
    assert(object.has_key? opt_key)
    assert_equal(object[opt_key], opt_value)
  end

  def relativly_random_string(chars = 8)
    ar = [] + ('a'..'z').to_a + ('A'..'Z').to_a
    os = ""
    chars.times{ os << ar[rand(ar.size)] }
    os
  end

 
end
