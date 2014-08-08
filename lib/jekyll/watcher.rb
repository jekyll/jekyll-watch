module Jekyll
  module Watcher
    extend self

    def watch(options)
      require 'listen'

      listener = build_listener(options)
      listener.start

      Jekyll.logger.info "Auto-regeneration:", "enabled for '#{options['source']}'"

      unless options['serving']
        trap("INT") do
          listener.stop
          puts "     Halting auto-regeneration."
          exit 0
        end

        loop { sleep 1000 }
      end
    rescue ThreadError => e
      # You pressed Ctrl-C, oh my!
    end

    def build_listener(options)
      Listen.to(
        options['source'],
        :ignore => listen_ignore_paths(options),
        :force_polling => options['force_polling'],
        &(listen_handler(options))
      )
    end

    def listen_handler(options)
      proc { |modified, added, removed|
        t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
        c = modified + added + removed
        n = c.length
        print Jekyll.logger.message("Regenerating:", "#{n} files at #{t} ")
        begin
          if config_file_changed?(c, options)
            options = Jekyll::Configuration[base_options(options)]
          end
          Jekyll::Command.process_site(Jekyll::Site.new(options))
          puts  "...done."
        rescue => e
          puts "...error:"
          Jekyll.logger.warn "Error:", e.message
          Jekyll.logger.warn "Error:", "Run jekyll build --trace for more information."
        end
      }
    end

    def base_options(options)
      opts = {
        'source' => options['source'],
        'destination' => options['destination']
      }
      if options.fetch('config', nil)
        opts['config'] = options['config']
      end
      opts
    end

    def config_file_changed?(changed_files, options)
      config_files = options.fetch('config', %w{_config.yml}).map do |c|
        Jekyll.sanitized_path(options['source'], c)
      end
      p changed_files
      p config_files

      !!(config_files & changed_files)
    end

    # Paths to ignore for the watch option
    #
    # options - A Hash of options passed to the command
    #
    # Returns a list of relative paths from source that should be ignored
    def listen_ignore_paths(options)
      source      = options['source']
      destination = options['destination']
      paths = (
        Array(destination) \
        + Array(options['exclude']).map { |e| Jekyll.sanitized_path(source, e) }
      )
      ignored = []

      source_abs = Pathname.new(source).expand_path
      paths.each do |p|
        path_abs = Pathname.new(p).expand_path
        begin
          rel_path = path_abs.relative_path_from(source_abs).to_s
          ignored << Regexp.new(Regexp.escape(rel_path)) unless rel_path.start_with?('../')
        rescue ArgumentError
          # Could not find a relative path
        end
      end

      Jekyll.logger.debug "Watcher:", "Ignoring #{ignored.map(&:inspect).join(', ')}"
      ignored
    end

  end
end
