require File.dirname(__FILE__) + '/../test_helper'

class LocaleControllerTest < ActionController::TestCase

  context "change the locale" do
    context "to an available locale" do
      setup do
        get :set, :locale => "en"
      end

      should "set the new locale in the session" do
        assert_equal "en", session[:user_locale]
      end

      should "set the new locale in a cookie" do
        assert_equal "en", cookies['user_locale'] # Need the key as a string in test
      end

      should_respond_with :redirect

      context "with a request referer" do
        setup do
          @referer = "http://test.host/coming/from"
          @request.env['HTTP_REFERER'] = @referer
          get :set, :locale => "wk"
        end

        should_redirect_to("the request.referer"){ @referer }
      end

      context "without a request referer" do
        should_redirect_to("the root path"){ root_path }
      end
    end

    context "to an unavailable locale" do
      setup do
        get :set, :locale => "wk" # Wookieespeak
      end

      should "not set the locale in the session" do
        assert_not_equal "wk", session[:user_locale]
      end
    end
  end

  [:get, :post].each {|verb|
    should_route verb, "/locale", :controller => "locale", :action => :set
  }

end
