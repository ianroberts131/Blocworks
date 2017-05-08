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
      @router.look_up_url(env["PATH_INFO"])
    end
  end
  
  class Router
    def initialize
      @rules = []
    end
    
    def resources(resource)
      send(:map, ":#{resource.to_s}", "#{resource.to_s}#index")
      send(:map, ":#{resource.to_s}/new", "#{resource.to_s}#new")
      send(:map, ":#{resource.to_s}/:id", "#{resource.to_s}#show")
      send(:map, ":#{resource.to_s}/:id/edit", "#{resource.to_s}#edit")
      send(:map, ":#{resource.to_s}", "#{resource.to_s}#create")
    end
      
    def map(url, *args)
      options = args[-1].is_a?(Hash) ? args.pop : {}
      options[:default] ||= {}
      
      args.size > 1 ? (raise "Too many args!") : destination = args[0]

      define_rules(url, options, destination)
    end
    
    def look_up_url(url)
      @rules.each do |rule|
        if rule_match(rule, url)
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
    
    def define_rules(url, options, destination)
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
                    destination: destination, options: options })
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
      rule[:regex].match(url)
    end
    
    def get_destination(destination, routing_params = {})
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