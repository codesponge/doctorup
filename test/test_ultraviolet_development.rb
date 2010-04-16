require 'helper'
class TestUltravioletDevelopment < Test::Unit::TestCase

should "run this test!" do
  assert true
end

should "load ultraviolet" do
  @sucess = false
  begin
    require 'uv'
    @sucess = true
  rescue LoadError => e
    @sucess = false
  end
  assert @sucess, "Couldn't seem to load ultraviolet"
  @sucess = nil
end

should "still have ultraviolet loaded" do
  assert defined?('Uv'), "Can't seem to keep"
end


end