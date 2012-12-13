require 'bundler/setup'

require 'green'
#require 'green/monkey'
require 'green-em/em-http'
require 'green/group'
require 'green/connection_pool'

class GreenSpawn
  def initialize(app)
    @app = app
  end

  def call(env)
    Green.spawn do
      env['async.callback'].call @app.call(env)
    end
    throw :async
  end
end

Clients = Green::ConnectionPool.new(size: 500) { EM::HttpRequest.new("http://localhost:7000/") }
  
class App
  def self.call(env)
    g = Green::Group.new
    res = g.enumerator(5.times) do |i|
      Clients.get(keepalive: true).response.to_i
    end.reduce(0, &:+).to_s
    [200, {'Content-Type' => 'text/plain'}, [res]]
  end
end

use GreenSpawn
run App
