#encodeing: UTF-8

module DoctorUp
begin
  require 'RedCloth'
  require 'hpricot'
  require 'coderay'
  require 'optparse'
  require 'uv'
  require 'snippet'
rescue LoadError
  require 'rubygems'
  require 'RedCloth'
  require 'hpricot'
  require 'coderay'
  require 'optparse'
  require 'uv'
end


  #TODO write accessors for options
  def self.ultra_violet_options(*args)
    {:default_lang => 'shell-unix-generic',:tabstops => 2,:line_numbers => false, :render_style => "cobaltcs", :headers => false }
  end

  def init_ultraviolet_options(*args)
    @ultraviolet_options = DoctorUp::ultra_violet_options
  end

  def self.ultra_violet_info_bar_style
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
    wrap_style File.read(file)
  end

  def parse(input)
    doc = Hpricot(input)
    doc.search('/code').each do |code|
      code.swap((Snippet.new(code.to_html)).to_html)
    end
    doc
  end

end