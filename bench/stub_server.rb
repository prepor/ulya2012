require 'bundler/setup'

require 'bundler/setup'
require 'thin/fun_embed'
require 'eventmachine'


EM.epoll = true

class Server < Thin::FunEmbed
  def handle_http_request(env)
    EM.add_timer(0.1) { send_200_ok(1.to_s) }
  end

end

EM.run { EM.start_server '0.0.0.0', 7000, Server }
  
