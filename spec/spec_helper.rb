$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "lib")
$LOAD_PATH << File.join(File.dirname(__FILE__))

require "active_record"
require "rspec"
require "my_factory_girl"
require "models"
