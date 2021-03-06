#encodeing: UTF-8
#TODO Move requires
begin
  require 'RedCloth'
  require 'hpricot'
  require 'optparse'
  require 'uv'
  require 'snippet'
  require 'codesponge'
  require 'set'
rescue LoadError
  require 'rubygems'
  require 'RedCloth'
  require 'hpricot'
  require 'uv'
end

=begin

= DoctorUp

The process method is the work-horse of DoctorUp and should be the call you use most often

see Usage and Examples at [[LINKS]] --comming soon

= Options

== Availalbe options (shown with class defaults)

The defaults listed here may be outdated
see the class variable options(link:#options-classvariable)
for actual defaults.
---

=== :tab_stop
Number of spaces to expand tabs to.

Default:
 :tab_stop => 2
---

=== :line_numbers
Display line numbers in output?

Default:
  :line_numbers => false
---

=== :themes_css_url
The url prefix for where you keep your theme stylesheets.

Default
  :themes_css_url => '/stylesheets/doctorup'
---

=== :info_bar
Display the info_bar?

Default
  :info_bar => true
---

=== :themes_css_dir
Local directory containing theme stylesheets.
Default points to the css folder in the ultraviolet gem dir.

Default
 :themes_css_dir => File.expand_path(File.join( Uv.path, "render", "xhtml", "files","css" ))
---

=== :ultraviolet_language_aliases
Aliases for languages.  Use a more convient name for a language.

Default:
  :ultraviolet_language_aliases => { 'shell' => 'shell-unix-generic'}
---

=== :theme_for_lang
Will use :theme_name whenever langugage is 'lang_name'.  Does nothing if either lang_name or theme_name are not valid.

Default:
  :theme_for_lang => {'lang_name' => :theme_name }

The defaults don't match anything.  (Unless you decide to create a language actually named 'lang_name' and a theme named 'theme_name')

*NOTE:* This is processed after ultraviolet_language_aliases so you must use the actual language name.

EXAMPLE:

If you wanted to have all JavaScript snippets use the cobalt theme and all ActionScript snippets use the
idle theme then you could do:

  DoctorUp.options[:theme_for_lang] = {'actionscript' => :idle,'javascript' => :cobalt }

= Options Cascade


Options cascade in the following order

1. Set on class.
    DoctorUp.options[:line_numbers] = true

2. Set in config file
    ~/.doctorup_options.yml

3. Passed to constructor
    doctor = DoctorUp.new( {:line_numbers => true} )

4. Set on an instance
    doctor.options[:line_numbers] = true

5. Passed to one of the output methods.
    doctor.process(input,{:line_numbers => true})

An option set furter down that list takes priority.  These options are
passed to new instances of Snippet, begining a similar option cascade.
A Snippet however does not have a config file, expecting that to be
handled by the parser creating it, which in this case is a DoctorUp
instance.

=end
class DoctorUp

#Default Options.  You can override these in a config file
#  ~/.doctorup_options.yml
@@options = CodeSponge::OptionHash.new({ 
    :theme                        => :dawn,  #the theme (or render_style) to use
    :ultraviolet_language_aliases => { 'shell' => 'shell-unix-generic'},
    :theme_for_lang               => {'lang_name' => :theme_name }, # => must use the actual lang name not an alias
    :tab_stop                     => 2,
    :line_numbers                 => false,
    :themes_css_url               => '/stylesheets/doctorup',  #great for rails (if you put theme styleshets there!)
    :themes_css_dir               => File.expand_path(File.join( Uv.path, "render", "xhtml", "files","css" )),
    :info_bar                     => true
})


  include CodeSponge::Options


  #create a DoctorUp instance with Options
  def initialize(opts={})
    config_file_path = File.expand_path(".doctorup_options.yml", ENV['HOME'])
    @options = CodeSponge::OptionHash.new(@@options).update_from_yaml_file(config_file_path).update(opts)
    #@options.update(opts)
    self
  end




  #This method is here for convenience but may be moved or removed in the future.
  #@return [String] Some Default CSS for the info bar
  def self.info_bar_style
    <<-CSS
    	pre.doctored{
    		border:3px solid #788E7D;
    		padding-left:10px;
    		padding-top:0px;
    		padding-bottom:8px;
    		overflow:auto;
    	}
    	pre.doctored span.info_bar{
    		display:inline-block;
    /*		color:#FF8E0A;*/
    		color:#172D33;
    		position:relative;
    		top:-1px;
    		background-color:#788E7D;
    		font-size:10px;
    		border:0px solid #788E7D;
    		border-width:0px 0px 0px 0px;
    		margin-top:-1px;
    		margin-left:-10px;
    		margin-bottom:2px;

    		padding:2px 1em;
    		/*	bottom right*/
    		-moz-border-radius-bottomright:1em;
    		-webkit-border-bottom-right-radius:1em;
    	}
    CSS
  end



  def process(input,opts = {})
   #opts = options_percolate(opts)
   opts = @options.before(opts)
   page = {}
   page[:raw] = input
   page[:syntaxed] = parse_code_blocks(input,opts)
   page[:body] = markup(page[:syntaxed])
   page[:theme_style] = page_style(Snippet.themes_used)
   page[:head] = linked_style_array(Snippet.themes_used).join("\n")
   page[:themes_used] = Snippet.themes_used
   page
  end


protected

  #Only textile right now, options for others are forthcomming.
  #@param [String] input The text to get markup.
  def markup(input,opts = {})
    textilize(input)
  end

  #given an array of theme names, returns an array of link
  #tags pointing to style sheets for each theme.
  #Uses options[:themes_css_url] as a prefix for the href attribute
  #@param  [Array] of theme names
  #@return [Array] of link tags for theme style sheets
  def linked_style_array(theme_names_array)
    links = []
    theme_names_array.each do |l|
      url = File.join( "#{options[:themes_css_url]}" ,"#{l}.css")
      links << "<link rel='stylesheet' href='#{url}' type='text/css' media='screen' charset='utf-8'>"
    end
    links
  end

  #given an array of theme names, reads the stylesheets for them,
  #(looking in options[:thems_css_dir] for them) and wraps them in
  #style tags, also includes info_bar_style if options[:info_bar]
  #is set.
  def page_style(theme_names_array)
    styles = ''
    styles << wrap_style(self.class.info_bar_style) if options[:info_bar]
    theme_names_array.each do |t|
      styles << wrap_style_from_file(File.join(options[:themes_css_dir],"#{t}.css"))
    end
    "<NOTEXTILE>#{styles}</NOTEXTILE>"
  end

  #@param [String] css
  #@return [String] input wrapped in style tags.
  def wrap_style(input)
    "<style type='text/css'>" + input + "</style>"
  end

  #@param [String] file path
  #@return [String] contents of @file@ wrapped in style tags.
  def wrap_style_from_file(file)
    raise ArgumentError, "The File #{file} doesn't exist or is unreadable" unless File.readable?(file)
    wrap_style File.read(file)
  end
  
  #parse input for code blocks and replaces them with
  #syntax higlighted html in the output.
  #@param [String] input the doc to parse
  #@param [Hash] options
  #@return [String] doc with code blocks replaced with syntax highlighted version
  def parse_code_blocks(input,opts={})
    Snippet.reset_themes_used
    doc = Hpricot(input)
    doc.search('code').each do |code|
      code.swap((Snippet.new(code.to_html, opts )).to_html)
    end
    doc.to_html
  end
  


end