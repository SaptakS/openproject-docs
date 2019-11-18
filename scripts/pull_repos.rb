#!/usr/bin/env ruby
puts <<~EOS
  This script has been replaced by a rake task `build`.
  Call `bundle exec rake build` to update, or `bundle exec rake update` to build + release in one step
EOS

exec 'bundle exec rake build'
