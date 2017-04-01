require 'rack/test'
require 'test/unit'
require 'bloc_works'

class MyTests < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    BlocWorks::Application.new
  end
  
  def test_it_says_hello_blocheads
    get '/'
    assert last_response.ok?
    assert_equal 'Hello Blocheads!', last_response.body
  end
end