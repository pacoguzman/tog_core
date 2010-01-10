require File.dirname(__FILE__) + '/../../test_helper'

class Admin::ConfigurationControllerTest < ActionController::TestCase

  context "when GET-ing index" do
    setup do
      @admin = Factory(:user, :login => "adminstrator", :admin => 1)
      @request.session[:user_id]= @admin.id
      get :index
    end

    should_assign_to :config_items
  end

  context "when PUT-ing update" do
    setup do
      @admin = Factory(:user, :login => "adminstrator", :admin => 1)
      @request.session[:user_id]= @admin.id
      put :update, :config => { "plugins.tog_core.site.name" => "test.host" }
    end

    should_respond_with :redirect
    should_redirect_to("the configuration index"){ admin_configuration_path }

    should "set a ok flash message" do
      assert_not_nil flash[:ok]
    end

    should_change("the plugins.tog_core.site.name config key", :to => "test.host"){ Tog::Config["plugins.tog_core.site.name"] }
  end

  [:get].each {|verb|
    should_route verb, "/admin/configuration", :controller => "admin/configuration", :action => :index
  }

  [:put].each {|verb|
    should_route verb, "/admin/configurator/update", :controller => "admin/configuration", :action => :update
  }

end
