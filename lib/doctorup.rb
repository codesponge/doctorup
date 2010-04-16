#encodeing: UTF-8

module DoctorUp
begin
 
  require 'RedCloth'
  require 'hpricot'
  require 'coderay'
  require 'optparse'
  require 'uv' 
rescue LoadError
  require 'rubygems'
  
  require 'RedCloth'
  require 'hpricot'
  require 'coderay'
  require 'optparse'
  require 'uv'
end

  @parser = :coderay
  
  
  
  #  suppress warnings from block
  #  taken from active_support
  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end
  
  #TODO write accessors for this
  def init_ultraviolet_options(option_hash = {:default_lang => 'shell-unix-generic',:tabstops => 2,:line_numbers => false, :render_style => "cobaltcs", :headers => false })
    @ultraviolet_options = option_hash
  end
  
  def wrap_style(content)
    "<style type='text/css'>" + content + "</style>"
  end
  
  def wrap_style_from_file(file)
    wrap_style File.read(file)
  end
  
  def syntax_up(input)
    #wrap so that our syntaxed html doesn't get textilized
    #--for some reason this can't doesn't work if we try to
    #wrap it with Hpricot later.
    

    input.gsub!(/\<code( lang='(.+?)')?\>(.*?)\<\/code\>/m) {
      "<NOTEXTILE>#{$&}</NOTEXTILE>"
    }

    doc = Hpricot(input)
    doc.search('code').each do |code|
      
      case @parser
      when :coderay
        (code.attributes['lang']) ? lang = code.attributes['lang'] : lang = 'none'
        if (code.inner_html.include?("\n")) then
          wo = :div
        else
          wo = :span
        end
        syntaxed = CodeRay.scan(code.inner_html, lang.to_sym).html(:wrap => wo, :css => :class, :tab_width => 3 , :hint => :debug) 
        
      when :ultraviolet
        init_ultraviolet_options unless @ultraviolet_options
        (code.attributes['lang']) ? lang = code.attributes['lang'] : lang = @ultraviolet_options[:default_lang]
        if (lang == 'shell') then; lang = 'shell-unix-generic'; end
        lang = @ultraviolet_options[:default_lang] unless Uv.syntaxes.include?(lang)
        
        #replace tabs with spaces before it goes to ultraviolet
        code.inner_html = code.inner_html.to_s.gsub(/\t/," " * @ultraviolet_options[:tabstops])
        #!hacky kinda pisses me off that Hpricot:Attributes looks like a hash but doesn't quite act like one
        # 
        attrib_hash = eval(code.attributes.inspect)
        
        if (attrib_hash.has_key?("gist")) then
          code.inner_html = <<-TEXT
          "Gist Attribute Detected!
          This will gist up and add a link to the info_bar
          When it gets hooked in at line #{__LINE__} 
          in #{__FILE__}" #{code.inner_html}
          TEXT
        end
        
        silence_warnings do
          syntaxed = Uv.parse(code.inner_html,"xhtml", lang, @ultraviolet_options[:line_numbers],@ultraviolet_options[:render_style],@ultraviolet_options[:headers])
        end
        
        #syntaxed = Uv.parse(code.inner_html.to_s, "xhtml", lang, false, "cobalt", false)
        #syntaxed = Uv.parse( "class SmurfRocket;def pig;'oink';end;end" , "xhtml", lang, false, "cobaltcs", false)
        #syntaxed = "<span clss='warn'>lang is: #{lang}, hash is a #{@ultraviolet_options.class}</span>"
      end
        
      pre = code.swap(syntaxed).first
      
      pre.attributes['class'] = pre.attributes['class'] + " doctored"
      pre.attributes['lang'] = lang
      
      #pre.first.attributes['class'] = pre.first.attributes['class'] + " doctored"
      
      #code.attributes['class'] = code.attributes['class'] + " doctoredup"
      #code.search("pre").first.before("<span class='language_label'>#{lang}</span>")
    end
      doc.search("pre.doctored").each do |pre|
        pre.inner_html = "<span class='info_bar'>language: #{pre.attributes['lang']}</span>\n" + pre.inner_html
        
      end
    doc.to_html
  end
  

  
end