require File.dirname(__FILE__) + '/../../test_helper'

class Member::DashboardControllerTest < ActionController::TestCase

  context "Dashboard" do
    setup do
      get :index
    end

    should_render_template ""
  end

  [:get].each {|verb|
    should_route verb, "/member", :controller => "member/dashboard", :action => :index
  }

end
