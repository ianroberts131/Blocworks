module BlocWorks
  class Application
    
    def controller_and_action(env)
      _, controller, action, _ = env["PATH_INFO"].split("/", 4)
      controller = controller.capitalize
      controller = "#{controller}Controller"
      
      [Object.const_get(controller).new(env), action]
    end
    
    def fav_icon(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, ["No favicon found"]]
      end
    end
    
    def route(&block)
      @router ||= Router.new
      @router.instance_eval(&block)
    end
    
    def get_rack_app(env)
      if @router.nil?
        raise "No routes defined"
      end
      puts "The env is #{env}"
      @router.look_up_url(env["PATH_INFO"], env["REQUEST_METHOD"])
    end
  end
  
  class Router
    def initialize
      @rules = []
    end
    
    def resources(resource)
      
      send(:map, "GET",     ":#{resource.to_s}", "#{resource.to_s}#index")
      send(:map, "GET",     ":#{resource.to_s}/new", "#{resource.to_s}#new")
      send(:map, "GET",     ":#{resource.to_s}/:id", "#{resource.to_s}#show")
      send(:map, "GET",     ":#{resource.to_s}/:id/edit", "#{resource.to_s}#edit")
      send(:map, "POST",    ":#{resource.to_s}", "#{resource.to_s}#create")
      send(:map, "POST",    ":#{resource.to_s}/:id", "#{resource.to_s}#update")
      send(:map, "DELETE",  ":#{resource.to_s}/:id", "#{resource.to_s}#destroy")
    end
      
    def map(request_method, url, *args)
      options = args[-1].is_a?(Hash) ? args.pop : {}
      options[:default] ||= {}
      
      args.size > 1 ? (raise "Too many args!") : destination = args[0]

      define_rules(request_method, url, options, destination)
    end
    
    def look_up_url(url, request_method)
      @rules.each do |rule|
        if rule_match(rule, url) && rule[:request_method] == request_method
          params = rule[:options][:default].dup
          
          rule[:vars].each_with_index do |var, index|
            params[var] = rule_match(rule, url).captures[index]
          end
          return set_destination(rule, params)
        end
      end
    end
    
    def split_url(url)
      url.split("/").reject { |part| part.empty? }
    end
    
    def create_regex(expression)
      Regexp.new("^/#{expression}$")
    end
    
    def define_rules(request_method, url, options, destination)
      url_parts = split_url(url)
      vars, regex_parts = [], []
      
      url_parts.each do |part|
        case part[0]
        when ":"
          vars << part[1..-1]
          regex_parts << "([a-zA-Z0-9]+)"
        when "*"
          vars << part[1..-1]
          regex_parts << "(.*)"
        else
          regex_parts << part
        end
      end
      regex = create_regex(regex_parts.join("/"))
      @rules.push({ regex: regex, vars: vars, 
                    destination: destination, options: options, request_method: request_method })
    end
    
    def set_destination(rule, params)
      if rule[:destination]
        return get_destination(rule[:destination], params)
      else
        controller = params["controller"]
        action = params["action"]
        return get_destination("#{controller}##{action}", params)
      end
    end
    
    def rule_match(rule, url)
      puts "The rule is #{rule}"
      puts "The url is #{url}"
      rule[:regex].match(url)
    end
    
    def get_destination(destination, routing_params = {})
      puts "The destination is #{destination}"
      puts "The controller is #{routing_params["controller"]}"
      if destination.respond_to?(:call)
        return destination
      end
      
      if destination =~ /^([^#]+)#([^#]+)$/
        name = $1.capitalize
        controller = Object.const_get("#{name}Controller")
        return controller.action($2, routing_params)
      end
      raise "Destination not found: #{destination}"
    end
  end
end