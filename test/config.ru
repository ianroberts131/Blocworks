app = BlocWorks::Application.new

use Rack::ContentType

app.route do
  map "", "test#welcome"
  resources :test
end

run(app)