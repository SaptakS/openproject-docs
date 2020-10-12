#!/usr/bin/env ruby
puts <<~EOS
  This script has been replaced by a rake task `build`.
  Call `bundle exec rake build`.
EOS

exec 'bundle exec rake build'
