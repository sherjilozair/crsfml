require "crsfml"
require "crsfml/audio"

class MySoundRecorder < SF::SoundRecorder
  def initialize(@samples : Array(Int16), @mutex : SF::Mutex)
    super()
  end
  def on_start()
    true
  end
  def on_process_samples(samples)
    @mutex.lock
    @samples.concat(samples)
    @mutex.unlock
    true
  end
  def on_stop()
  end
end

class MySoundStream < SF::SoundStream
  def initialize(@samples : Array(Int16), @mutex : SF::Mutex, *args)
    super()
    initialize_(*args)
    @result = [] of Int16
  end
  def on_get_data()
    while @samples.empty?
      SF.sleep(SF.seconds(0.05))
    end
    @mutex.lock
    @result.replace(@samples)
    @samples.clear
    @mutex.unlock
    @result.to_unsafe.to_slice(@result.size)
  end
  def on_seek(position)
  end
end

samples = Array(Int16).new
mutex = SF::Mutex.new()

sr = MySoundRecorder.new(samples, mutex)
sr.start(44100)
ss = MySoundStream.new(samples, mutex, 1, 44100)
ss.play()

puts "Recording... Press Enter to stop"
gets

sr.stop()
ss.stop()
