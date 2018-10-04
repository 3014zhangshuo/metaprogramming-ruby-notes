lambda do
  events = []
  setups = []

  Kernel.send :define_method, :setup do |&block|
    setups << block
  end

  Kernel.send :define_method, :event do |description, &condition|
    events << { description: description, condition: condition }
  end

  Kernel.send :define_method, :each_setup do |&block|
    setups.each { |setup| block.call(setup) }
  end

  Kernel.send :define_method, :each_event do |&block|
    events.each { |event| block.call(event) }
  end
end.call

load 'events.rb'

each_event do |event|
  env = Object.new
  each_setup do |setup|
    env.instance_eval &setup
  end
  puts "ALERT: #{event[:description]}" if env.instance_eval &(event[:condition])
end
