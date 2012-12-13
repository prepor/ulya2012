require 'bundler/setup'

require 'eventmachine'
require 'em-http'

Clients = EM::Pool.new
500.times { Clients.add EM::HttpRequest.new("http://localhost:7000/") }

class App
  def self.call(env)
    res = []
    clb = proc do |http|
      res << http.response.to_i
      if res.size == 5
        env['async.callback'].call [200, {'Content-Type' => 'text/plain'}, [res.reduce(0, &:+).to_s]]
      end
    end

    erb = proc do 
      env['async.callback'].call [500, {'Content-Type' => 'text/plain'}, []]
    end
    5.times do
      Clients.perform do |c|
        req = c.get keepalive: true
        req.callback(&clb)
        req.errback(&erb)
        req
      end
    end
    throw :async
  end
end

run App
