#encodeing: UTF-8
begin
  require 'RedCloth'
  require 'hpricot'
  require 'coderay'
  require 'optparse'
  require 'uv'
  require 'snippet'
  require 'set'
  require 'codesponge'
rescue LoadError
  require 'rubygems'
  require 'RedCloth'
  require 'hpricot'
  require 'coderay'
  require 'optparse'
  require 'uv'
end



class DoctorUp


  @@options = { :render_style                 => :cobalt,
                :ultraviolet_language_aliases => { 'shell' => 'shell-unix-generic'},
#                :theme_for_lang               => {'shell-unix-generic' => :sunburst }, # => must use the actual lang name not an alias
                :tab_stop                     => 2,
                :line_numbers                 => false,
                :themes_css_url               => 'http://ssss.heroku.com/'  #FIXME hard coded option!
              }

  include CodeSponge::Options

  def initialize(opts={})
    @options = self.class.options.merge opts
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

  def page_style
    styles = wrap_style(self.class.info_bar_style)
    Snippet.themes_used.each do |t|
      styles << wrap_style_from_file(File.join(options[:ultraviolet_css_dir],"#{t}.css"))
    end
    "<NOTEXTILE>#{styles}</NOTEXTILE>"
  end

  def linked_style_array
    links = []
    Snippet.themes_used.each do |l|
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
    @page = {}
    @page[:body] = textilize(parse_code_blocks(input,opts))
    @page[:head] = linked_style_array.join("\n")
    @page
  end

  def rx(input,opts={})
    syntaxed = parse_code_blocks(input,opts)
    textiled = textilize(syntaxed)
    page_style + textiled
  end



end