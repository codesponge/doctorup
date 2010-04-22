#
#   snippet
#
#   Created by William Champlin on 2010-04-16.
#   Copyright (c) 2010 CodeSponge. All rights reserved.
#
#--------------------------------------------------------------

class Snippet < String
  require 'codesponge'
  require 'set'
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

  expected_methods = [:syntax_up,:to_html,:to_s,:sytaxify] # => DEV REMINDER



  @@options = { :render_style                 => :mac_classic,
                :ultraviolet_language_aliases => { 'shell' => 'shell-unix-generic'},
                :tab_stop                     => 2,
                :line_numbers                 => false }

  include CodeSponge::Options

  def initialize(str = '',opts = {})
    @options = self.class.options.merge opts
    super(str)
  end

  def self.syntax_languages
    Uv.syntaxes
  end

  def self.syntax_themes
    Uv.themes
  end

  def self.theme_available?(theme)
    syntax_themes.include?(theme.to_s)
  end

  def self.language_available?(lang)
    syntax_languages.include?(lang.to_s)
  end

  def self.reset_themes_used
    @@themes_used = Set.new
  end

  def self.themes_used
    @@themes_used
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

    if( self.class.language_available?(c.attributes['lang']) ) then
      lang = c.attributes['lang']
      process_theme_for_lang(lang)
      process_inline_theme(c)
      syntaxified = Hpricot(ultravioletize(c.inner_html, lang)).search("/pre")
      @@themes_used << options[:render_style]
      syntaxified.add_class('doctored')
      syntaxified.attr('lang'=>lang)
      syntaxified.inner_html =  build_info_bar({:language=>lang}) + syntaxified.inner_html
      @html = "<NOTEXTILE>" + syntaxified.first.to_html + "</NOTEXTILE>"
    else
      @html = "<NOTEXTILE><pre class='code_nolang'>#{self}</pre></NOTEXTILE>"
    end
    @html
  end

  def process_theme_for_lang(lang)
    if(options[:theme_for_lang].respond_to?('has_key?')) then
      if(options[:theme_for_lang].has_key?( lang ) and self.class.theme_available?(options[:theme_for_lang][lang]) ) then
        options[:render_style] = options[:theme_for_lang][lang]
      end
    end
  end

  def process_inline_theme(elem)
    raise ArgumentError "expected a Hpricot::Elem but got #{elem.class}" unless elem.class == Hpricot::Elem
    @@log.debug("trying for '#{elem.attributes['theme']}'")
    if(self.class.theme_available?(elem.attributes['theme'])) then


      options[:render_style] = elem.attributes['theme']
    end
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


  def ultravioletize(input,lang,opts={})
    opts = options.merge(opts)

    silence_warnings do

      syntaxed = Uv.parse(input,"xhtml",
              lang.to_s,
              opts[:line_numbers],
              opts[:render_style].to_s,
              opts[:headers] )
    end
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
