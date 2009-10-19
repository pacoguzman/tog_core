class Test::Unit::TestCase
  
  def self.should_create_comment_and_redirect
    should_respond_with :redirect
    should_redirect_to ("http://www.example.com") { "http://www.example.com" }
    should_change("the number of comments", :by => 1){ Comment.count }
  end
  
end
