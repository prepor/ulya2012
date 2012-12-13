require 'bundler/setup'

require 'eventmachine'
require 'em-synchrony'
require "em-synchrony/em-http"

class FiberSpawn
  def initialize(app)
    @app = app
  end

  def call(env)
    Fiber.new do
      env['async.callback'].call @app.call(env)
    end.resume
    throw :async
  end
end
  
Clients = EM::Synchrony::ConnectionPool.new(size: 500) { EM::HttpRequest.new("http://localhost:7000/") }

class App
  def self.call(env)
    multi = EM::Synchrony::Multi.new
    5.times do |i| 
      multi.add i, Clients.aget(keepalive: true)
    end
    requests = multi.perform
    unless requests
      [500, {'Content-Type' => 'text/plain'}, []]
    else
      res = requests.responses[:callback].map { |i, r| r.response.to_i }.reduce(0, &:+)
      [200, {'Content-Type' => 'text/plain'}, [res]]
    end
  end
end

use FiberSpawn
run App
