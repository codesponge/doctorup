#
#   snippet
#
#   Created by William Champlin on 2010-04-16.
#   Copyright (c) 2010 CodeSponge. All rights reserved.
#
#--------------------------------------------------------------

class Snippet < String
  require 'codesponge'
  include CodeSponge::Handy

#--------------------------------------------------------------
Description=<<-TEXTILE

A snippet is a string that can spit out syntax hightlighted,
 versions of it's self in HTML.

The strings value is preserved (syntax is seperate from *Self*).

TEXTILE

#--------------------------------------------------------------

#DEV LOGGER
require 'logger'
@@log = Logger.new( File.join("#{File.dirname(File.dirname(__FILE__))}","develop_logs", "#{self.name}.log"))
@@log.level = Logger::DEBUG
@@log.debug("\n#{'-' * 30}\n Logger Started @ #{Time.now}\n#{'-' * 30}")

#<=DEV LOGGER
  expected_methods = [:syntax_up,:to_html,:to_s,:sytaxify]


  @@options = { :render_style                 => :mac_classic,
                :ultraviolet_language_aliases => { 'shell' => 'shell-unix-generic'},
                :tab_stop                     => 2 }

  include CodeSponge::Options

  def initialize(str,opts = {})
		#FIXME setting opts here is for stub testing only!
    @options = self.class.options.merge opts
    super(str)
  end

  #create a marked up version with syntax highlighting
  def syntax_up()
    doc = Hpricot(self.gsub(/\t/," " * options[:tab_stop] ).to_s )
    d = doc.search("/code")
    if d.any? then
      c = d.first
    else
      @@log.warn("#{self.name} was asked to syntax_up a string that didn't contain a <code></code> block. @html is now same as self.to_s")
      @html = self.to_s
      return @html
    end

    c = filter_ultraviolet_language_aliaes(c)

    if( language_available?(c.attributes['lang']) ) then
      lang = c.attributes['lang']
      syntaxified = Hpricot(ultravioletize(c.inner_html, lang)).search("/pre")
      syntaxified.add_class('doctored')
      syntaxified.attr('lang'=>lang)
      syntaxified.inner_html =  build_info_bar({:language=>lang}) + syntaxified.inner_html
      @html = "<NOTEXTILE>" + syntaxified.first.to_html + "</NOTEXTILE>"
    else
      @html = "<NOTEXTILE><pre class='code_nolang'>#{self}</pre></NOTEXTILE>"
    end
    @html
  end



  #Accepts an Hpricot:Elem
  #filters the elemets attributes['lang'] -- if it matches a key
  #in @opts[:ultraviolet_language_aliases] then it swaps it with the
  #value stored there
  def filter_ultraviolet_language_aliaes(elem)
    raise ArgumentError "expected a Hpricot::Elem but got #{elem.class}" unless elem.class == Hpricot::Elem
    if( options[:ultraviolet_language_aliases].has_key?(elem.attributes['lang']) ) then
      elem.attributes['lang'] = options[:ultraviolet_language_aliases][elem.attributes['lang']]
    end
    elem
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
              options[:line_numbers],
              options[:render_style].to_s,
              options[:headers] )
    end
  end

  def syntax_languages
    Uv.syntaxes
  end

  def language_available?(lang)
    syntax_languages.include?(lang.to_s)
  end

  #return's marked up version with syntax highlighting
  #if syntax_up hasn't been called then it calls it with
  #default values
  def to_html
    #TODO write checkers based on SHA-1 of self @ SHA-1 of
    #pre_html_sha
    syntax_up unless @html
    @html
  end
  alias_method :sytaxify, :to_html

#--------------------------------------------------------------
end # => class Snippet < String
#--------------------------------------------------------------
