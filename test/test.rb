require 'rack/test'
require 'test/unit'
require 'bloc_works'
require 'bloc_record'
require_relative './models/test_model'

BlocRecord.connect_to("test.db")

$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "test", "controllers")
$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "test", "models")
$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "test")
$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "test", "config")

class MyTests < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    # Rack::Builder.parse_file("./config.ru").first
    app = BlocWorks::Application.new
    app.route do
      map "/test/welcome", "test#welcome"
      resources :test
    end
    app
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
  
  def test_index
    get '/tests'
    assert last_response.ok?
    assert_match "Hello", last_response.body
  end
  
  def test_show
    TestModel.create(
      testy_test: "Hello"  
    )
    get '/tests/1'
    assert last_response.ok?
    assert_match "Hello", last_response.body
  end
  
  def test_new
    get '/tests/new'
    assert last_response.ok?
    assert_match "Add a test!", last_response.body
  end
  
  def test_create
    
  end
  
end