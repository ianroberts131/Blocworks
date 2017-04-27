require 'erubis'

module BlocWorks
  class Controller
    def request
      @request ||= Rack::Request.new(@env)
    end
    
    def params
      request.params
    end
    
    def initialize(env)
      @env = env
    end
    
    def render(view, locals = {})
      filename = File.join("app", "views", controller_dir, "#{view}.html.erb")
      template = File.read(filename)
      eruby = Erubis::Eruby.new(template)
      eruby.result(locals.merge(env: @env))
    end
    
    def controller_dir
      klass = self.class.to_s
      klass.slice!("Controller")
      BlocWorks.snake_case(klass)
    end
  end
end