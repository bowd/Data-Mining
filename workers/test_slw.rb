require "bunny"
b = Bunny.new(:logging => false) 
b.start

q = b.queue("test1")

e = b.exchange("")

e.publish("Hello, everybody!", :key => 'test1')

b.stop
