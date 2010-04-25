#encodeing: UTF-8
#TODO Move requires
begin
  require 'RedCloth'
  require 'hpricot'
  require 'optparse'
  require 'uv'
  require File.join(File.dirname(__FILE__),'snippet') # => needed to do this because I was loading from gem
  require 'set'
  require File.join(File.dirname(__FILE__),'codesponge')
rescue LoadError
  require 'rubygems'
  require 'RedCloth'
  require 'hpricot'
  require 'uv'
end
=begin rdoc
= Options
== Availalbe options (shown with class defaults)

 :theme => :dawn
The theme (render_style) to use.  You can do DoctorUp.themes to see a complet list.

 :ultraviolet_language_aliases => { 'shell' => 'shell-unix-generic'}
Aliases for languages.

 :tab_stop => 2
Number of spaces to expand tabs to.

 :line_numbers => false
Display line numbers in output?

 :themes_css_url => '/stylesheets/doctorup'
The url prefix for where you keep your theme stylesheets.

 :no_info_bar => false
Don't display the info_bar?

 :themes_css_dir => File.expand_path(File.join( Uv.path, "render", "xhtml", "files","css" ))
Local directory containing theme stylesheets.  Default points to the css folder in the ultraviolet gem dir.

 :theme_for_lang => {'lang_name' => :theme_name }
Will use :theme_name whenever langugage is 'lang_name'.  If you wanted
to have all JavaScript snippets use the cobalt theme and all ActionScript snippets use the
idle theme then you could do...</br>
<tt>DoctorUp.options[:theme_for_lang] = {'actionscript' => :idle,'javascript' => :cobalt }</tt>

== Options Cascade
Options cascade in the following order
1. Set on class.
    DoctorUp.options[:line_numbers] = true
2. Set in config file
    ~/.doctorup_options.yaml
3. Passed to constructor
    DoctorUp.new({:line_numbers => true})
4. Set on an instance
    d = DoctorUp.new; d.options[:line_numbers] = true
5. Passed to one of the output methods.
    d.process(input,{:line_numbers => true})

An option set furter down that list takes priority.  These options are
passed to new instances of Snippet, begining a similar option cascade.
A Snippet however does not have a config file, expecting that to be
handled by the parser creating it, which in this case is a DoctorUp
instance.

=end
class DoctorUp


  @@options = { :theme                        => :dawn,  #the theme (or render_style) to use
                :ultraviolet_language_aliases => { 'shell' => 'shell-unix-generic'},
                :theme_for_lang               => {'lang_name' => :theme_name }, # => must use the actual lang name not an alias
                :tab_stop                     => 2,
                :line_numbers                 => false,
                :themes_css_url               => '/stylesheets/doctorup',  #great for rails (if you put theme styleshets there!)
                :themes_css_dir               => File.expand_path(File.join( Uv.path, "render", "xhtml", "files","css" )),
                :no_info_bar                  => false
              }


  include CodeSponge::Options


  #create a DoctorUp instance with Options
  def initialize(opts={})
    config_file_path = File.expand_path(".doctorup_options.yaml", ENV['HOME'])
    if(File.readable?(config_file_path)) then
      @options = self.class.options
      config_opts = (YAML.load(File.open(config_file_path).read))
      @options.update(config_opts)
      @options.update(opts)
    else
      @options = self.class.options.merge(opts)
    end
  end


  #=== this method is here for convenience but may be moved or removed in the future.
  #some css for the info_bar
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
   page = {}
   page[:syntaxed] = parse_code_blocks(input,opts)
   page[:body] = textilize(page[:syntaxed])
   page[:theme_style] = page_style(Snippet.themes_used)
   page[:head] = linked_style_array(Snippet.themes_used).join("\n")
   page[:themes_used] = Snippet.themes_used
   page
  end

  #=== this method is here for convenience but may be moved or removed in the future.
  #output with style for themes included in the output wrapped in style tags
  def rx(input,opts={})
    syntaxed = parse_code_blocks(input,opts)
    textiled = textilize(syntaxed)
    page_style(Snippet.themes_used) + textiled
  end

protected
  
  
  #given an array of theme names, reads the stylesheets for them,
  #(looking in options[:thems_css_dir] for them) and wraps them in
  #style tags, also includes info_bar_style unless options[:no_info_bar]
  #is set.
  def page_style(theme_names_array)
    styles = ''
    styles << wrap_style(self.class.info_bar_style) unless options[:no_info_bar]
    theme_names_array.each do |t|
      styles << wrap_style_from_file(File.join(options[:themes_css_dir],"#{t}.css"))
    end
    "<NOTEXTILE>#{styles}</NOTEXTILE>"
  end

  #wrap +content+ in style tags.
  def wrap_style(content)
    "<style type='text/css'>" + content + "</style>"
  end

  #wrap contents of file in style tags.
  def wrap_style_from_file(file)
    raise ArgumentError, "The File #{file} doesn't exist or is unreadable" unless File.readable?(file)
    wrap_style File.read(file)
  end
  
  #parse input for &gt;code&lt; blocks and replaces them with
  #syntax higlighted html in the output.
  def parse_code_blocks(input,opts={})
    Snippet.reset_themes_used
    doc = Hpricot(input)
    doc.search('/code').each do |code|
      code.swap((Snippet.new(code.to_html, opts )).to_html)
    end
    doc.to_html
  end
  
  #given an array of theme names, returns an array of link
  #tags pointing to style sheets for each theme.
  #Uses options[:themes_css_url] as a prefix for the href attribute
  def linked_style_array(theme_names_array)
    links = []
    theme_names_array.each do |l|
      url = File.join( "#{options[:themes_css_url]}" ,"#{l}.css")
      links << "<link rel='stylesheet' href='#{url}' type='text/css' media='screen' charset='utf-8'>"
    end
    links
  end

end