#
#   snippet
#
#   Created by William Champlin on 2010-04-16.
#   Copyright (c) 2010 CodeSponge. All rights reserved.
#
#--------------------------------------------------------------

class Snippet < String

#--------------------------------------------------------------
Description=<<-TEXTILE

A snippet is a string that can spit out syntax hightlighted,
and textilized versions of it's self in HTML.

The strings value is preserved (syntax is seperate from *Self*).

TEXTILE

#--------------------------------------------------------------




  expected_methods = [:syntax_up,:to_html,:to_s,:sytaxify]
  attr_accessor :opts
  alias_method :options, :opts
  alias_method :settings, :opts

  def initialize(*args)
		#FIXME setting opts here is for stub testing only!
    @opts = {:parser => :coderay }
    super
  end

  #create a marked up version with syntax highlighting
  #and textile parsed returns true on success and nil on
  #failure
  def syntax_up(*args)
    :stub
  end

  def ultravioletize()
    @html = ""
  end

  #return's marked up version with syntax highlighting
  #if syntax_up hasn't been called then it calls it with
  #default values
  def to_html(*args)
    :stub
  end

  alias_method :sytaxify, :to_html

#--------------------------------------------------------------
end # => class Snippet < String
#--------------------------------------------------------------
