Object::Lax = Class.new(Array)
Lax::SOURCE = File.new(File.expand_path('../lax/source.rb', __FILE__)).read
Lax.class_eval Lax::SOURCE

