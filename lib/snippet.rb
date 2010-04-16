#
#   snippet
#
#   Created by William Champlin on 2010-04-16.
#   Copyright (c) 2010 CodeSponge. All rights reserved.
#	
#-------------------------------------------------------------------------
<<-DESCRIPTION





DESCRIPTION
#--------------------------------------------------------------------------
#
#-	
#-------

class Snippet < String

  expected_methods = [:syntax_up,:to_html,:to_s,:sytaxify]

  #create a marked up version with syntax highlighting
  #and textile parsed returns true on success and nil on
  #failure
  def syntax_up(*args)
    :stub
  end

  #return's marked up version with syntax highlighting
  #if syntax_up hasn't been called then it calls it with
  #default values
  def to_html(*args)
    :stub
  end
  
  alias_method :sytaxify, :to_html
  

end