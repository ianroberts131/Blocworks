require 'rack/test'
require 'test/unit'
require 'bloc_works'

$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "test", "controllers")
$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "test", "models")
$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "test")
$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "test", "config")

class MyTests < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Rack::Builder.parse_file("./config.ru").first
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
  
  # def test_map_function
  #   assert_equal map()
  # end
  
end