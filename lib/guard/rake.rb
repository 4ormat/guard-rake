require 'guard'
require 'guard/guard'
require 'guard/version'
require 'rake'

module Guard
  class Rake < Guard
    def initialize(watchers=[], options={})
      super
      @options = {
        :run_on_start => true,
        :run_on_all => true,
        :with_args => false,
        :default_arg => nil
      }.update(options)
      @task = @options[:task]
    end

    def start
      UI.info "Starting guard-rake #{@task}"
      ::Rake.application.init

      # Important, otherwise tasks get called multiple times if there are multiple guards.
      ::Rake.application.load_rakefile if ::Rake::Task.tasks.empty? 

      run_rake_task if @options[:run_on_start]
      true
    end

    def stop
      UI.info "Stopping guard-rake #{@task}"
      true
    end

    def reload
      stop
      start
    end

    def run_all
      run_rake_task if @options[:run_on_all]
    end

    if ::Guard::VERSION < "1.1"
      def run_on_change(paths)
        run_rake_task(paths)
      end
    else
      def run_on_changes(paths)
        run_rake_task(paths)
      end
    end

    def run_rake_task(args = @options[:default_arg])
      ::Rake::Task.tasks.each { |t| t.reenable }
      if @options[:with_args]
        if args.is_a?(Array)
          args.each do |arg|
            UI.info "running #{@task} with args: #{arg}"
            ::Rake::Task[@task].invoke(arg)
            ::Rake::Task[@task].reenable
          end
        elsif args
          UI.info "running #{@task} with args: #{args}"
          ::Rake::Task[@task].invoke(*args)
        else
          UI.info "skipping #{@task} as no arguments were passed"
        end
      else
        ::Rake::Task[@task].invoke
      end
    end
  end
end
