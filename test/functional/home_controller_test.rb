require File.dirname(__FILE__) + '/../test_helper'

class HomeControllerTest < ActionController::TestCase

  [:get].each {|verb|
    should_route verb, "/", :controller => "home", :action => :index
  }

end
