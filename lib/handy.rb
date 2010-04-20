module Handy
  
  #  suppress warnings from block
  #  taken from active_support
  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end
  
end