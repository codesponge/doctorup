require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'doctorup'
require 'snippet'

class Test::Unit::TestCase
  DATA_DIR = File.join(File.dirname(__FILE__), 'data')
end
