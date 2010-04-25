=begin rdoc
Copyright (c) 2010 CodeSponge[www.CodeSponge.com] see LICENSE for details

- A snippet is a string that can spit out syntax hightlighted,
  versions of it's self in HTML.

- The strings value is preserved (syntax is seperate from *Self*).

- Options are handled via a inheratible option hash.

- A class variable keeps track of themes used so stylesheets can
  be added smartly.

=== Note:
A Snippet is ususally instantiated by a parser and probably rarely used on it's own
see [link]DoctorUp for a more suitable examples

=== Trivial Example:
  str = <<-EOC
  <code lang='ruby'>
  class Dog < Animal
    def speak
      "Woof"
    end
  end
  EOC

  a_snippet = Snippet.new(str,{:line_numbers => true, :theme => 'dawn'})
  syntaxed = a_snippet.to_html
  puts syntaxed # => (html string not displayed because it was breaking rdoc)
=end
class Snippet < String
  require 'codesponge'
  require 'set'
  include CodeSponge::Handy

def self.dev_key
  "aklsejowaflkejwoeifjql;kcmlvzkjczkleuproqiwejr"
end



expected_methods = [:syntax_up,:to_html,:to_s,:sytaxify] # => DEV REMINDER

#default options
@@options = { :theme                        => :dawn,  #the theme (or render_style) to use
                :ultraviolet_language_aliases => { 'shell' => 'shell-unix-generic'},
                :theme_for_lang               => {'lang_name' => :theme_name }, # => must use the actual lang name not an alias
                :tab_stop                     => 2,
                :line_numbers                 => false,
                :no_info_bar                  => false
              }

 include CodeSponge::Options

=begin rdoc

Creates a new Snippet, which is is a sub class of String.

No processing is done on creation. You must actually call to_html
to have _+self+_ parsed for syntax highlighting.
 str = "<code lang='ruby'>...</code>"
 syntaxed = Snippet.new(str,{:line_numbers => true}).to_html
=end
  def initialize(str = '',opts = {})
    @options = self.class.options.merge opts
    super(str)
  end

  # Returns an array of availible languages.
  def self.syntax_languages
    Uv.syntaxes
  end

  # Returns an array of available themes.
  def self.syntax_themes
    Uv.themes
  end

  # Is language available?
  def self.theme_available?(theme_name)
    syntax_themes.include?(theme_name.to_s)
  end

  # Is language available?
  def self.language_available?(lang_name)
    syntax_languages.include?(lang_name.to_s)
  end

  #Reset (empty) the Set that contains themes used.
  def self.reset_themes_used
    @@themes_used = Set.new
  end

  #A set containing all themes used by Snippets since reset_themes_used was
  #last called
  def self.themes_used
    @@themes_used = Set.new unless defined?(@@themes_used)
    @@themes_used
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
      syntaxified.inner_html =  build_info_bar({:language=>lang}) + syntaxified.inner_html
      @html = "<NOTEXTILE>" + syntaxified.first.to_html + "</NOTEXTILE>"
    else
      @html = "<NOTEXTILE><pre class='code_nolang'>#{self}</pre></NOTEXTILE>"
    end
    @html
  end


  #if options[:no_info_bar] is true then returns an empty string,
  #otherwise creates an info bar. att_hash will get expanded to:
  # key: value key: value ...
  #example
  # build_info_bar({:lang => 'ruby',:File_name => 'lib/sorce.rb'})
  # => "<span class='info_bar'>lang: ruby File_name: lib/source.rb</span>"
  def build_info_bar(att_hash = {})
      str = att_hash.map {|k,v| "#{k.to_s}: '#{v.to_s}'"}.join(' ')
      bar = "<span class='info_bar'>#{str}</span>"
      unless(options[:no_info_bar]) then
        bar
      else
        ''
      end
  end


  #wrapper for Uv.parse
  def ultravioletize(input,lang,opts={})
    opts = options.merge(opts)

    silence_warnings do
      syntaxed = Uv.parse(input,"xhtml",
              lang.to_s,
              opts[:line_numbers],
              opts[:theme].to_s,
              opts[:headers])
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

  def process_theme_for_lang(lang)
    if(options[:theme_for_lang].respond_to?('has_key?')) then
      if(options[:theme_for_lang].has_key?( lang ) and self.class.theme_available?(options[:theme_for_lang][lang]) ) then
        options[:theme] = options[:theme_for_lang][lang]
      end
    end
  end

  #Accepts an Hpricot:Elem
  def process_inline_theme(elem)
    raise ArgumentError "expected a Hpricot::Elem but got #{elem.class}" unless elem.class == Hpricot::Elem
    if(self.class.theme_available?(elem.attributes['theme'])) then
      options[:theme] = elem.attributes['theme']
    end
  end

  #Accepts an Hpricot:Elem
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
