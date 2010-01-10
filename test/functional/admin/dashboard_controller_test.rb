require File.dirname(__FILE__) + '/../../test_helper'

class Admin::DashboardControllerTest < ActionController::TestCase

    [:get].each {|verb|
      should_route verb, "/admin", :controller => "admin/dashboard", :action => :index
    }

end
