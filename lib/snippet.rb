#
#   snippet
#
#   Created by William Champlin on 2010-04-16.
#   Copyright (c) 2010 CodeSponge. All rights reserved.
#
#--------------------------------------------------------------

class Snippet < String
  require 'handy'
  include Handy
# require 'uv'
#--------------------------------------------------------------
Description=<<-TEXTILE

A snippet is a string that can spit out syntax hightlighted,
 versions of it's self in HTML.

The strings value is preserved (syntax is seperate from *Self*).

TEXTILE

#--------------------------------------------------------------




  expected_methods = [:syntax_up,:to_html,:to_s,:sytaxify]
  attr_accessor :opts
  alias_method :options, :opts
  alias_method :settings, :opts

  def initialize(*args)
		#FIXME setting opts here is for stub testing only!
    @opts = {:parser => :ultraviolet,  }
    super
  end

  #create a marked up version with syntax highlighting
  #and textile parsed returns true on success and nil on
  #failure
  def syntax_up()
    doc = Hpricot(self.to_s)
    c = doc.search("/code")
    if (c.first.respond_to?(:attributes) and c.first.attributes['lang'] ) then

      if(syntax_languages.include?(c.first.attributes['lang'].to_s)) then
        lang = c.first.attributes['lang']
      elsif(c.first.attributes['lang'] == 'shell')
        c.first.attributes['lang'] = "shell-unix-generic"
        lang = c.first.attributes['lang']
      else
        lang = false
      end
    else
      lang = false
    end
    if(lang) then
      #TODO wrap and fix for info bar
      syntaxified = Hpricot(ultravioletize(c.inner_html, lang)).search("/pre")

      syntaxified.add_class('doctored')
      syntaxified.attr('lang'=>lang)
      syntaxified.inner_html =  build_info_bar({:language=>lang}) + syntaxified.inner_html
      @html = "<NOTEXTILE>" + syntaxified.first.to_html + "</NOTEXTILE>"
    else
      @html = "<NOTEXTILE><pre class='simple'>#{self}</pre></NOTEXTILE>"
    end
  end

  def build_info_bar(att_hash = {})
      str = att_hash.map {|k,v| "#{k}: '#{v}'"}.join(' ')
      "<span class='info_bar'>#{str}</span>\n"
  end




  def ultravioletize(input,lang)
    opts = DoctorUp::ultra_violet_options

    silence_warnings do

      syntaxed = Uv.parse(input,"xhtml",
              lang.to_s,
              opts[:line_numbers],
              opts[:render_style],
              opts[:headers] )
    end
  end

  def syntax_languages
    Uv.syntaxes
  end


  #return's marked up version with syntax highlighting
  #if syntax_up hasn't been called then it calls it with
  #default values
  def to_html
    syntax_up unless @html
    @html
  end

  alias_method :sytaxify, :to_html

#--------------------------------------------------------------
end # => class Snippet < String
#--------------------------------------------------------------
