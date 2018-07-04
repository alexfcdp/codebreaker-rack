require_relative 'lib/racker'
require_relative 'lib/filter'

use Rack::Session::Pool
use Rack::Static, urls: %w[/stylesheets /images], root: 'public'
use Filter
run Racker
