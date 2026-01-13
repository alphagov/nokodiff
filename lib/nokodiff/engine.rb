return unless defined?(Rails)

module Nokodiff
  class Engine < ::Rails::Engine
    isolate_namespace Nokodiff
  end
end
