#encodeing: UTF-8
begin
  require 'RedCloth'
  require 'hpricot'
  require 'optparse'
  require 'uv'
  require 'snippet'
  require 'set'
  require 'codesponge'
rescue LoadError
  require 'rubygems'
  require 'RedCloth'
  require 'hpricot'
  require 'uv'
end



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

  def wrap_style(content)
    "<style type='text/css'>" + content + "</style>"
  end

  def wrap_style_from_file(file)
    raise ArgumentError, "The File #{file} doesn't exist or is unreadable" unless File.readable?(file)
    wrap_style File.read(file)
  end

  def page_style(theme_names_array)
    styles = ''
    styles << wrap_style(self.class.info_bar_style) unless options[:no_info_bar]
    theme_names_array.each do |t|
      styles << wrap_style_from_file(File.join(options[:themes_css_dir],"#{t}.css"))
    end
    "<NOTEXTILE>#{styles}</NOTEXTILE>"
  end

  def linked_style_array(theme_names_array)
    links = []
    theme_names_array.each do |l|
      url = File.join( "#{options[:themes_css_url]}" ,"#{l}.css")
      links << "<link rel='stylesheet' href='#{url}' type='text/css' media='screen' charset='utf-8'>"
    end
    links
  end

  def parse_code_blocks(input,opts={})
    Snippet.reset_themes_used
    doc = Hpricot(input)
    doc.search('/code').each do |code|
      code.swap((Snippet.new(code.to_html, opts )).to_html)
    end
    doc.to_html
  end

  def process(input,opts = {})
   page = {}
   page[:syntaxed] = parse_code_blocks(input,opts)
   page[:body] = textilize(page[:syntaxed])
   page[:head] = linked_style_array(Snippet.themes_used).join("\n")
   page[:themes_used] = Snippet.themes_used
   page
  end


  def rx(input,opts={})
    syntaxed = parse_code_blocks(input,opts)
    textiled = textilize(syntaxed)
    page_style(Snippet.themes_used) + textiled
  end



end