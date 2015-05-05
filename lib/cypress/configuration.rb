module Cypress
  class Configuration
  private
    def self.add_setting(method, default)
      attr_writer method

      name = method.to_s

      define_method method do
        if instance_variable_get("@" + name)
          instance_variable_get("@" + name)
        else
          instance_variable_set("@" + name, default)
          default
        end
      end
    end

    add_setting :url, 'http://localhost:2020/__socket.io'
  end
end
