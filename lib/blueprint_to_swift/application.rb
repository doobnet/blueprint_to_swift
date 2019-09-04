# frozen_string_literal: true

module BlueprintToSwift
  class Application
    Args = Struct.new(:help, :verbose, :version)

    attr_reader :raw_args
    attr_reader :args
    attr_reader :option_parser

    def initialize(raw_args)
      @raw_args = raw_args
      @args = Args.new
    end

    def self.start
      new(ARGV).run
    end

    # rubocop:disable Metrics/AbcSize
    def run
      parse_verbose_argument(raw_args, args)
      handle_errors do
        @option_parser = parse_arguments(raw_args, args)
        exit = handle_arguments(args)
        return if exit

        ast = parser.parse_from_file(input_file)
        puts generator.generate(ast)
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    def input_file
      raw_args.first
    end

    def error_handler
      args.verbose ? :verbose_error_handler : :default_error_handler
    end

    def handle_errors(&block)
      send(error_handler, &block)
    end

    def default_error_handler(&block)
      verbose_error_handler(&block)
    rescue OptionParser::InvalidArgument => e
      args = e.args.join(' ')
      puts "Invalid argument: #{args}"
      exit 1
      # rubocop:disable Lint/RescueException
    rescue Exception => e
      # rubocop:enable Lint/RescueException
      puts "An unexpected error occurred: #{e.message}"
      exit 1
    end

    def verbose_error_handler(&block)
      block.call
    end

    def parse_verbose_argument(raw_args, args)
      args.verbose = raw_args.include?('-v') || raw_args.include?('--verbose')
    end

    # rubocop:disable Metrics/MethodLength
    def parse_arguments(raw_args, args)
      opts = OptionParser.new
      opts.banner = banner
      opts.separator ''
      opts.separator 'Options:'

      opts.on('-v', '--[no-]verbose', 'Show verbose output') do |value|
        args.verbose = value
      end

      opts.on('--version', 'Print version information and exit') do
        args.version = true
        puts BlueprintToSwift::VERSION
      end

      opts.on('-h', '--help', 'Show this message and exit') do
        args.help = true
      end

      opts.separator ''
      opts.separator "Use the `-h' flag for help."

      opts.parse!(raw_args)
      opts
    end
    # rubocop:enable Metrics/MethodLength

    def handle_arguments(args)
      return true if args.version

      if args.help || input_file.nil?
        print_usage
        true
      else
        false
      end
    end

    def banner
      @banner ||= "Usage: blueprint-to-swift [options] <input_file>\n" \
        "Version: #{BlueprintToSwift::VERSION}"
    end

    def print_usage
      puts option_parser.to_s
    end
  end
end
