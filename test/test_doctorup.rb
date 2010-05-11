require 'helper'

#puts DoctorUp.methods.include?('silence_warnings')

class TestDoctorup < Test::Unit::TestCase

  should "have had a better time last night" do
    assert true
  end

  context "Given options" do

    setup do
      @test_file = File.join(File.dirname(__FILE__),"fixtures","001_simple.textile")
      @source = File.open(@test_file).read
      DoctorUp.options[:theme] = 'idle'
      @doctor = DoctorUp.new({:theme => 'amy'})
    end

    should "have set class variable" do
      assert_equal('idle',DoctorUp.options[:theme])
    end

    should "have set an instance variable" do
      assert_equal('amy',@doctor.options[:theme])
    end

    should "have set an option in an output method" do
      @page = @doctor.process(@source,{:theme => 'cobalt'})
      assert_equal(1,@page[:themes_used].size)
      assert_equal('cobalt',@page[:themes_used].first)
    end


  end



  context "With a known test text" do
  context "DoctorUp" do
    setup do
      @test_file = File.join(File.dirname(__FILE__),"fixtures","002_three_and_three.textile")
      @source = File.open(@test_file).read
      @doctor = DoctorUp.new
      @page = @doctor.process(@source)
    end

    should "process some text" do
      assert(@page,"Expected something to be assigned!")
    end

    should "keep track of themes used" do
      assert_equal(3,@page[:themes_used].size)
    end


  end # => context "With a know test text"
  end # => context "Doctorup"

end
