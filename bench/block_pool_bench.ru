require 'bundler/setup'
require 'net/http'

Thread.abort_on_exception = true

class Atomic
  attr_accessor :value
  def initialize(value)
    @value = value
    @m = Mutex.new
  end

  def update(&blk)
    @m.synchronize { @value = blk.call @value }
  end
end

class Pool
  attr_accessor :q
  def initialize(size = 5, &blk)
    @q = Queue.new
    @res_q = Queue.new
    @started = Atomic.new 0
    size.times do
      Thread.new do
        state = blk.call if blk
        while task = q.pop
          begin
            task.call state
          ensure
            complete
          end
        end
      end
    end
  end

  def schedule(&blk)
    @started.update { |v| v + 1 }
    q.push blk
  end

  def complete
    @started.update { |v| v - 1 }
    if @started.value == 0
      @res_q.push :complete
    end
  end

  def join
    @res_q.pop
  end
end

HttpPool = Pool.new 1000 do
  Net::HTTP.start("localhost", 7000)
end

class App
  def self.call(env)
    que = Queue.new
    5.times do
      HttpPool.schedule do |state|
        req = Net::HTTP::Get.new("/")       
        http_res = state.request(req)
         # puts "KEEP: #{http.instance_eval { keep_alive? }}"
        que << http_res.body.to_i
      end
    end
    res = []
    5.times{ res << que.pop }
    [200, {'Content-Type' => 'text/plain'}, [res.reduce(0, &:+).to_s]]
  end
end

run App
