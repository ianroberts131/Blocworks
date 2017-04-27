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
      rack_app = get_rack_app(env)
      rack_app.call(env)
    end
  end
end
