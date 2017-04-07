require "bloc_works/utility"
require "bloc_works/dependencies"
require "bloc_works/version"
require "bloc_works/controller"
require 'bloc_works/router'

module BlocWorks
  class Application
    def call(env)
      if fav_icon(env)
        return fav_icon(env)
      end
      controller, action = controller_and_action(env)
      [200, {'Content-Type' => 'text/html'}, [controller.new(env).send(action)]]
    end
  end
end
