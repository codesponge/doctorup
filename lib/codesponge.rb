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




module Options
  module ClassMethods

    def options
      self.class_eval("@@options")
    end

    def options=(opts)
      self.class_eval("@@options").update(opts)
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
