# frozen_string_literal: true

require "listen"

module Jekyll
  module Watcher
    extend self

    # Public: Continuously watch for file changes and rebuild the site
    # whenever a change is detected.
    #
    # If the optional site argument is populated, that site instance will be
    # reused and the options Hash ignored. Otherwise, a new site instance will
    # be instantiated from the options Hash and used.
    #
    # options - A Hash containing the site configuration
    # site    - The current site instance (populated starting with Jekyll 3.2)
    #           (optional, default: nil)
    #
    # Returns nothing.
    def watch(options, site = nil)
      ENV["LISTEN_GEM_DEBUGGING"] ||= "1" if options["verbose"]

      site ||= Jekyll::Site.new(options)
      listener = build_listener(site, options)
      listener.start

      Jekyll.logger.info "Auto-regeneration:", "enabled for '#{options["source"]}'"

      unless options["serving"]
        trap("INT") do
          listener.stop
          Jekyll.logger.info "", "Halting auto-regeneration."
          exit 0
        end

        sleep_forever
      end
    rescue ThreadError
      # You pressed Ctrl-C, oh my!
    end

    private

    def build_listener(site, options)
      ignore_regexps, ignore_paths = listen_ignore_paths(options)

      Listen.to(
        options["source"],
        :ignore        => ignore_regexps,
        :force_polling => options["force_polling"],
        &listen_handler(site, ignore_paths)
      )
    end

    def listen_handler(site, ignore_paths)
      proc do |modified, added, removed|
        modified = strip_ignore_paths(modified, ignore_paths)
        added    = strip_ignore_paths(added, ignore_paths)
        removed  = strip_ignore_paths(removed, ignore_paths)

        c = modified + added + removed
        unless c.empty?
          t = Time.now
          n = c.length

          Jekyll.logger.info "Regenerating:",
                             "#{n} file(s) changed at #{t.strftime("%Y-%m-%d %H:%M:%S")}"

          c.each { |path| Jekyll.logger.info "", path["#{site.source}/".length..-1] }
          process(site, t)
        end
      end
    end

    def normalize_encoding(obj, desired_encoding)
      case obj
      when Array
        obj.map { |entry| entry.encode!(desired_encoding, entry.encoding) }
      when String
        obj.encode!(desired_encoding, obj.encoding)
      end
    end

    # paths that user specified to be excluded in their _config.yml file.
    def custom_excludes(options)
      options.fetch("exclude", []).map { |e| Jekyll.sanitized_path(options["source"], e) }
    end

    def config_files(options)
      %w(yml yaml toml).map do |ext|
        Jekyll.sanitized_path(options["source"], "_config.#{ext}")
      end
    end

    def to_exclude(options)
      [
        config_files(options),
        options["destination"],
        custom_excludes(options),
      ].flatten.map { |e| normalize_encoding(e, options["source"].encoding) }
    end

    # Paths to ignore for the watch option
    #
    # options - A Hash of options passed to the command
    #
    # Returns a tuple where the first entry is a list of regular
    #         expressions relating to exact (existing) files to
    #         ignore and the second is a list of fnmatch patterns
    #         to ignore.
    def listen_ignore_paths(options)
      source = Pathname.new(options["source"]).expand_path
      exclusion_fnmatch_paths = []

      exclusion_regexps = to_exclude(options).map do |path|
        # convert to absolute path from the source directory
        absolute_path = Pathname.new(path).expand_path
        relative_path = absolute_path.relative_path_from(source).to_s

        if !absolute_path.exist?
          # maybe wildcard, or just a file that doesn't exist.
          nil.tap { exclusion_fnmatch_paths << relative_path }
        else
          relative_path = File.join(relative_path, "") if absolute_path.directory?

          begin
            unless relative_path.start_with?("../")
              %r!^#{Regexp.escape(relative_path)}!.tap do |pattern|
                Jekyll.logger.debug "Watcher:", "Ignoring #{pattern}"
              end
            end
          rescue ArgumentError
            # Could not find a relative path
          end
        end
      end.compact + [%r!^\.jekyll\-metadata!]

      [exclusion_regexps, exclusion_fnmatch_paths]
    end

    # remove any paths from PATHS which're matched to by some fnmatch
    # pattern in IGNORE_PATTERNS
    def strip_ignore_paths(paths, ignore_patterns)
      paths.select do |path|
        ignore_patterns.find { |pattern| File.fnmatch?(pattern, path) }.nil?
      end
    end

    def sleep_forever
      loop { sleep 1000 }
    end

    def process(site, time)
      begin
        site.process
        Jekyll.logger.info "", "...done in #{Time.now - time} seconds."
      rescue StandardError => e
        Jekyll.logger.warn "Error:", e.message
        Jekyll.logger.warn "Error:", "Run jekyll build --trace for more information."
      end
      Jekyll.logger.info ""
    end
  end
end
