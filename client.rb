require 'socket'
require 'ruby2d'

s = UDPSocket.new
s.bind(nil, ARGV[0])
s.send("0 #{ARGV[0]}", 0, 'localhost', 4000)
# ignore first message from server
s.recvfrom(16)
#sema = Mutex.new

# Stores the current location of player
location = "#{ARGV[0]} 0-0"
# stores where squares last known locations are
state = {}
threads = []

# this gurantees something you choose will not be executed more then 60 times a second
def once_per_frame
  last = Time.now
  while true
    yield
    now = Time.now
    _next = [last + (1 / 60), now].max
    sleep(_next - now)
    last = _next
  end
end

# tell server where you are, once per frame
threads.push(Thread.new do
  once_per_frame do
    s.send("1 #{ARGV[0]} #{location}", 0, 'localhost', 4000)
  end
end)

# Ctrl-c will kill threads
at_exit do
  puts 'trapping'
  threads.each do |t|
    puts 'killing'
    Thread.kill t
  end
end

#reciever
threads.push(Thread.new do
  loop do
    text, _sender = s.recvfrom(16)
    #sema.synchronize do
    ary = text.split('-')
    state[ary[0]] = [ary[1], ary[2]]
    #end
  end
end)

update do
  puts get(:fps)
  #sema.synchronize do
  state.each do |_color, square|
    Square.draw(color: [[1.0, 0.0, 0.0, 1.0],
                        [1.0, 0.0, 0.0, 1.0],
                        [1.0, 0.0, 0.0, 1.0],
                        [1.0, 0.0, 0.0, 1.0]],
                x: square[0].to_i,
                y: square[1].to_i,
                size: 25)
  end
  #end
  # update location of square
  location = "#{get :mouse_x}-#{get :mouse_y}"
end

show
