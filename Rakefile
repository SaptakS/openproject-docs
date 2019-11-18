# frozen_string_literal: true

Dir.glob('lib/tasks/*.rake').each { |r| load r }

desc 'Builds from sources and deploys to github'
task update: %i[build deploy]

task default: :update

