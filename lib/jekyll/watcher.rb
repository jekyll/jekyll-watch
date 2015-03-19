module Jekyll
  module Watcher
    extend self

    def watch(options)
      site = Jekyll::Site.new(options)
      listener = build_listener(site, options)
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

    def build_listener(site, options)
      require 'listen'
      Listen.to(
        options['source'],
        :ignore => listen_ignore_paths(options),
        :force_polling => options['force_polling'],
        &(listen_handler(site))
      )
    end

    def listen_handler(site)
      proc { |modified, added, removed|
        t = Time.now
        c = modified + added + removed
        n = c.length
        print Jekyll.logger.message("Regenerating:", "#{n} file(s) changed at #{t.strftime("%Y-%m-%d %H:%M:%S")} ")
        begin
          site.process
          puts  "...done in #{Time.now - t} seconds."
        rescue => e
          puts "...error:"
          Jekyll.logger.warn "Error:", e.message
          Jekyll.logger.warn "Error:", "Run jekyll build --trace for more information."
        end
      }
    end

    def custom_excludes(options)
      Array(options['exclude']).map { |e| Jekyll.sanitized_path(options['source'], e) }
    end

    def config_files(options)
      %w[yml yaml toml].map do |ext|
        Jekyll.sanitized_path(options['source'], "_config.#{ext}")
      end
    end

    def to_exclude(options)
      [
        config_files(options),
        options['destination'],
        custom_excludes(options)
      ].flatten
    end

    # Paths to ignore for the watch option
    #
    # options - A Hash of options passed to the command
    #
    # Returns a list of relative paths from source that should be ignored
    def listen_ignore_paths(options)
      source       = Pathname.new(options['source']).expand_path
      paths        = to_exclude(options)

      paths.map do |p|
        absolute_path = Pathname.new(p).expand_path
        if absolute_path.exist?
          begin
            relative_path = absolute_path.relative_path_from(source).to_s
            unless relative_path.start_with?('../')
              if File.directory?(relative_path)
                path_to_ignore = Regexp.new("^#{Regexp.escape(relative_path)}\/")
              else
                path_to_ignore = Regexp.new("^#{Regexp.escape(relative_path)}$")
              end

              Jekyll.logger.debug "Watcher:", "Ignoring #{path_to_ignore}"
              path_to_ignore
            end
          rescue ArgumentError
            # Could not find a relative path
          end
        end
      end.compact + [/^\.jekyll\-metadata$/]
    end

  end
end
