=begin
Copyright (c) 2010 "CodeSponge":www.CodeSponge.com see "LICENSE":file.LICENSE.html for details

* A snippet is a string that can spit out syntax hightlighted,
  versions of it's self in HTML.

* The strings value is preserved (syntax is seperate from *Self*).

* Options are handled via a inheratible option hash. See DoctorUp class for more info.

* A class variable keeps track of themes used so stylesheets can
  be added smartly.

=== Note

A Snippet is ususally instantiated by a parser and probably rarely used on it's own
see the [[DOC ARTICLES]] for a more info and some examples.


=end
class Snippet < String
  require 'codesponge'
  require 'set'
  include CodeSponge::Handy

#Default Options: see Doctor up for an explanation of options.
@@options = CodeSponge::OptionHash.new({
  :theme                        => :dawn,  #the theme (or render_style) to use
  :ultraviolet_language_aliases => { 'shell' => 'shell-unix-generic'},
  :theme_for_lang               => {'lang_name' => :theme_name },
  :tab_stop                     => 2,
  :line_numbers                 => false,
  :info_bar                     => true
})

 include CodeSponge::Options

  #@param [String] str
  #@param [Hash] opts Options
  def initialize(input = '',opts = {})
    @options = CodeSponge::OptionHash.new(@@options).update(opts)
    super(input)
  end

  
  #@return [Array] language_names
  def self.syntax_languages
    Uv.syntaxes
  end  
  
  #@return [Array] theme_names 
  def self.syntax_themes
    Uv.themes
  end

  # Is language available?
  #@param [String | Symbol] theme_name
  #@return [Boolean]
  def self.theme_available?(theme_name)
    syntax_themes.include?(theme_name.to_s)
  end

  # Is language available?
  #@param [String | Symbol] lang_name
  #@return [Boolean]
  def self.language_available?(lang_name)
    syntax_languages.include?(lang_name.to_s)
  end

  #Reset (empty) the Set that contains themes used.
  def self.reset_themes_used
    @@themes_used = Set.new
  end

  #A set containing all themes used by all Snippets,
  #since reset_themes_used was last called.
  #@return [Set] names of themes
  def self.themes_used
    @@themes_used = Set.new unless defined?(@@themes_used)
    @@themes_used
  end
  
  #Aliases for class methods
  class << self
    alias :languages :syntax_languages
    alias :themes :syntax_themes
  end
  
  
  #store a html version of _self_ marked up for syntax highlighting
  #in @html
  def syntax_up()
    doc = Hpricot(self.gsub(/\t/," " * options[:tab_stop] ).to_s )
    d = doc.search("/code")
    if d.any? then
      c = d.first
    else
      @html = self.to_s
      return @html
    end

    c = filter_ultraviolet_language_aliaes(c)

    if( self.class.language_available?(c.attributes['lang']) ) then
      lang = c.attributes['lang']
      process_theme_for_lang(lang)
      process_inline_theme(c)
      syntaxified = Hpricot(ultravioletize(c.inner_html, lang)).search("/pre")
      self.class.themes_used << options[:theme]
      syntaxified.add_class('doctored')
      syntaxified.attr('lang'=>lang)
      syntaxified.inner_html =  build_info_bar({:language => lang}) + syntaxified.inner_html
      @html = "<NOTEXTILE>" + syntaxified.first.to_html + "</NOTEXTILE>"
    else
      @html = "<NOTEXTILE><pre class='code_nolang'>#{self}</pre></NOTEXTILE>"
    end
    @html
  end


  #Info bar gets displayed in Snippets output
  #Allows you to pass in helpful info about the snippet,
  #like language, or perhaps file name.
  #@param [Hash] att_hash gets expanded to 'key: value key: value ...'
  #@return [String] Output html for an info_bar or empty string if options[:info_bar] is false
  def build_info_bar(att_hash = {})
      str = att_hash.map {|k,v| "#{k.to_s}: '#{v.to_s}'"}.join(' ')
      bar = "<span class='info_bar'>#{str}</span>"
      if(options[:info_bar]) then
        bar
      else
        ''
      end
  end


  #wrapper for Uv.parse
  #@param [String] input
  #@param [String] lang the syntax language.
  #@param [Hash] opts Options for ultraviolet
  def ultravioletize(input,lang,opts={})
    opts = @options.before(opts)
    silence_warnings do
      syntaxed = Uv.parse(input,"xhtml",
          lang.to_s,
          opts[:line_numbers],
          opts[:theme].to_s,
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

protected

  #@param [String]
  def process_theme_for_lang(lang)
    if(options[:theme_for_lang].respond_to?('has_key?')) then
      if(options[:theme_for_lang].has_key?( lang ) and self.class.theme_available?(options[:theme_for_lang][lang]) ) then
        options[:theme] = options[:theme_for_lang][lang]
      end
    end
  end

  #@param [Hpricot:Elem] 
  def process_inline_theme(elem)
    raise ArgumentError "expected a Hpricot::Elem but got #{elem.class}" unless elem.class == Hpricot::Elem
    if(self.class.theme_available?(elem.attributes['theme'])) then
      options[:theme] = elem.attributes['theme']
    end
  end

  #@param [Hpricot:Elem]
  #@return [HPricot:Elem]
  def filter_ultraviolet_language_aliaes(elem)
    raise ArgumentError "expected a Hpricot::Elem but got #{elem.class}" unless elem.class == Hpricot::Elem
    if( options[:ultraviolet_language_aliases].has_key?(elem.attributes['lang']) ) then
      elem.attributes['lang'] = options[:ultraviolet_language_aliases][elem.attributes['lang']]
    end
    elem
  end

#--------------------------------------------------------------
end # => class Snippet < String
#--------------------------------------------------------------


