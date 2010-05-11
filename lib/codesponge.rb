module CodeSponge

module Handy
  #  suppress warnings from block
  #  (taken from active_support)
  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

end # => module Handy


class OptionHash < Hash

  def initialize(opts)
      super()
      update(opts)
      self
  end

  def update_from_yaml_file(path)
    if(File.readable?(path)) then
      update(YAML.load_file(path))
    end
  end
  
  def before(opts = {})
    mopts = self
    mopts.update(opts)
    mopts
  end
end




module Options
  module ClassMethods

    def options
      self.class_eval("@@options")
    end

    def options=(opts)
      self.class_eval("@@options").update(opts)
    end
    
    def options_percolate(opts)
      mopts = self.options
    end
  
  end
  
  
  def self.included(base)
    base.extend(ClassMethods)
  end

  def options=(opts={})
    @options.update(opts)
  end

  def options
    @options
  end



end # => module Options

end # => module CodeSponge
