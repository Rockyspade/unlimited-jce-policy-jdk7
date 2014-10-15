require_relative 'jdk7/version'
require 'fileutils'

module Unlimited
  module Jce
    module Policy
      module Jdk7
        extend self

        def init(system_install = true)
          FileUtils.mkdir_p(security_path)
          FileUtils.mkdir_p(system_security_path) if system_install

          jars.each do |jar|
            dest = File.join(security_path, File.basename(jar))
            FileUtils.cp(jar, dest)

            system_dest = File.join(system_security_path, File.basename(jar))

            FileUtils.cp(jar, system_dest) if system_install
          end
        end

        def jars
          Dir.glob(File.expand_path('../../../../jars/*.jar', __FILE__))
        end

        def security_path
          File.join(app_root, '.jdk-overlay/jre/lib/security')
        end

        def system_security_path
          return File.expand_path('~/.jdk/jre/lib/security') if ENV.key?('DYNO')

          @system_security_path ||= begin
            java_home = java.lang.System.properties['java.home']
            path = File.join(java_home, 'lib/security')
            FileUtils.touch(File.join(path, '.write-test'))
            path
          rescue => e
            warn e
            File.expand_path('~/.jdk/jre/lib/security')
          end
        end

        def app_root
          return Sinatra::Application.settings.root if defined?(Sinatra)
          return Rails.root if defined?(Rails)
          return ENV['RAILS_ROOT'] if ENV.key?('RAILS_ROOT')
          Dir.pwd
        end
      end
    end
  end
end
