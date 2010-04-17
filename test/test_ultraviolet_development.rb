require 'helper'
class TestUltravioletDevelopment < Test::Unit::TestCase

should "run this test!" do
  assert true
end

should "load ultraviolet" do
  @sucsess = false
  begin
    require 'uv'
    @sucsess = true
  rescue LoadError => e
    @sucsess = false
  end
  assert @sucsess, "Couldn't seem to load ultraviolet"
  @sucsess = nil
end

should "still have ultraviolet loaded" do
  assert defined?('Uv'), "Can't seem to keep"
end


end