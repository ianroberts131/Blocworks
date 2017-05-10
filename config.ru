app = BlocWorks::Application.new

use Rack::ContentType

app.route do
  map "", "test#welcome"
  # map "/create_me_yo", { controller: "yo", action: "create_me", method: "PoST" }
  resources :test
end

run(app)