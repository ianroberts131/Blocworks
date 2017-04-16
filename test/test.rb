require 'rack/test'
require 'test/unit'
require 'bloc_works'

$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "test", "controllers")

class MyTests < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    BlocWorks::Application.new
  end
  
  def test_controller_and_action
    get '/test/welcome'
    assert last_response.ok?
    assert_equal 'This is the welcome action YAY!', last_response.body
  end
  
  def test_fav_icon
    get '/favicon.ico'
    assert_equal last_response.status, 404
    assert_equal 'No favicon found', last_response.body
  end
end