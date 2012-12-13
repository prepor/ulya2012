require 'bundler/setup'
require 'thin/fun_embed'
require 'eventmachine'
require 'em-http'
require 'em/pool'

EM.epoll = true

Clients = EM::Pool.new
500.times { Clients.add EM::HttpRequest.new("http://localhost:7000/") }

class Server < Thin::FunEmbed
  def handle_http_request(env)
    res = []
    clb = proc do |http|
      res << http.response.to_i
      if res.size == 5
        send_200_ok res.reduce(0, &:+).to_s
      end
    end

    erb = proc do 
      send_status_body 500
    end
    5.times do
      Clients.perform do |c|
        req = c.get keepalive: true
        req.callback(&clb)
        req.errback(&erb)
        req
      end
    end
  end

end

EM.run { EM.start_server '0.0.0.0', 8080, Server }
  
