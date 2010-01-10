require File.dirname(__FILE__) + '/../../test_helper'

Comment.class_eval do
  acts_as_voteable
end

class Member::VotesControllerTest < ActionController::TestCase
  
  [:get, :post].each {|verb|
    should_route verb, "/member/vote", :controller => "member/votes", :action => :create
  }

  context "Given an object" do

    setup do
      @request.env['HTTP_REFERER'] = "http://www.example.com"

      @owner = Factory(:user, :login => "test")
      @voteable = Factory(:comment, :user => @owner, :commentable => @owner)

      @request.session[:user_id]= @owner.id
    end

    context "when POST-ing a " do
      context "positive vote" do
        setup do
          post :create, :type => @voteable.class.name, :id => @voteable.id, :vote => 'for'
        end
        should_respond_with :redirect
        should_redirect_to('http://www.example.com') { "http://www.example.com" }
        should "set a ok message in the flash" do
          assert_not_nil flash[:ok]
        end
        should_change("the number of votes", :by => 1){ @voteable.votes(true).size }
        should "changed the number of positive votes by 1"
      end

      context "negative vote" do
        setup do
          post :create, :type => @voteable.class.name, :id => @voteable.id, :vote => 'bad'
        end
        should_respond_with :redirect
        should_redirect_to('http://www.example.com') { "http://www.example.com" }
        should "set a ok message in the flash" do
          assert_not_nil flash[:ok]
        end
        should_change("the number of votes", :by => 1){ @voteable.votes(true).size }
        should "changed the number of negative votes by 1"
      end
    end

    context "when POST-ing a vote twice" do
      setup do
        @voteable.votes.create!(:vote => true, :user => @owner)
        post :create, :type => @voteable.class.name, :id => @voteable.id, :vote => 'for'
      end

      should_respond_with :redirect
      should_redirect_to('http://www.example.com') { "http://www.example.com" }
      should "set a error message in the flash" do
        assert_not_nil flash[:error]
      end
      should_change("the number of votes only the vote created in the setup", :by => 1){ Vote.count }
    end
  end
end
