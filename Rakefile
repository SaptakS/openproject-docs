# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'

def uncommitted_changes?
  `git status --porcelain`.chomp.length > 0
end

desc 'Build and publish to Github Pages'
task :deploy do
  root_dir = File.expand_path('.', __dir__)
  build_dir = File.expand_path('build', __dir__)

  puts root_dir
  puts build_dir

  Dir.mktmpdir do |tmpdir|
    cd tmpdir do
      puts 'Initialize github repo'
      sh 'git init .'
      sh 'git remote add origin git@github.com:finnlabs/finnlabs.github.io.git'
      sh 'git fetch'
      sh 'git checkout master'
      sh 'git reset --hard origin/master'
    end

    cd root_dir do
      puts 'Building site ... '
      sh 'bundle exec middleman build --clean'
    end

    puts "Copying build to #{tmpdir}"
    sh "cp -r #{build_dir}/* #{tmpdir}"

    head = nil
    message = nil

    cd root_dir do
      head = `git log --pretty="%h" -n1`.chomp
      message = "Site updated to #{head}\n\n[ci skip]"
    end

    cd tmpdir do
      sh 'git add --all'
      if uncommitted_changes?
        sh "git commit -m \"#{message}\""
      else
        puts 'No changes to commit.'
      end
      sh 'git push origin master'
    end
  end
end
