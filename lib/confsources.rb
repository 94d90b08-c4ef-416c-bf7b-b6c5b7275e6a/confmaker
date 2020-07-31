#Sources is the raw-data config
#It imay not valid, but can parse itself to hash
module ConfSources
    require 'securerandom'
    require 'fileutils'
    require 'ipaddr'
    require 'yaml'
    require 'thor'
    
    def self.is_option_exist? opt_name
        ! ConfMaker::get_options.select{ |opt| opt[:name] == opt_name }.empty?
    end
    
    class Default
        attr_reader :options
        def initialize
            @options = ConfMaker::get_options.collect{|e| e.clone }
            #Some default options may be not valid
            #validate!
        end
        def merge other_one
            options = @options.collect { |el| (other_one.is_defined? el[:name]) ? other_one[el[:name]] : el }
            Clone.new options
        end
        def merge! other_one
            @options.collect! { |el| (other_one.is_defined? el[:name]) ? other_one[el[:name]].clone : el }
        end
        def [] arg
            @options.select{ |opt| opt[:name] == arg }.first
        end
        def validate!
            @options.each { |el|
                unless @options.select{ |opt| opt[:name] == el[:name] }.count == 1
                    raise ArgumentError, "Options with name #{el[:name]} duplicated"
                end
                unless @options.select{ |opt| opt[:name] == el[:name] }.count == 1
                    raise ArgumentError, "Option #{el[:name]} duplicates aliases with #{opt[:name]}"
                end
                el.validate! Clone.new(self)
            }
        end
        #array of option hashes (including names, desc and so on)
        def to_a
            @options.collect{ |opt| opt.to_h }
        end
        #hash with parsed values
        def to_h
            @options.inject({}){|rez,opt| rez.merge opt.get}
        end
        #:name => :value hash
        def to_pairs
            @options.collect{ |opt| opt.to_pair }.to_h
        end
        #Export into bash environment script
        def export_to file
            ::File.open(file,"w+") { |f|
                @options.each { |opt|
                    opt.get.each_pair { |k,v|
                        f.puts "#{k.to_s}='#{v.to_s}'"
                    }
                }
            }
        end
        #Human-readable description
        def to_s
            ("Configuration:\n" + @options.collect {|opt| opt.to_s}.join("\n")).gsub("\n","\n\t")
        end
        def is_defined? opt_name
            self[opt_name].kind_of? ConfOptions::Standard
        end
    end
    
    class Clone < Default
        def initialize other
            if other.kind_of? Default
                @options = other.options.collect {|el|el.clone}
            elsif other.is_a? Array
                @options = other.collect {|el| el.clone}
            else
                raise RuntimeError, "Can't clone configuration sorce from #{other.class}"
            end
        end
    end
    
    class File < Default
        def initialize conf_file
            loaded_yaml = YAML.load_file conf_file
            if loaded_yaml.is_a? Hash
                @options = loaded_yaml.select { |k,v| ConfSources::is_option_exist? k.to_sym and not v.nil?
                }.collect { |k,v|
                    candidate = ConfMaker::get_options.select{|e|e[:name] == k.to_sym}.first.clone
                    candidate[:value] = v
                    candidate
                }
            else
                @options = []
            end
        end
    end
    
    class CommandLine < Default
        class Wrapper < Thor
            desc "", ConfMaker::get_desc
            ConfMaker.get_options.each { |opt|
                class_option opt[:name], :type => opt[:cmdline_type],
                    :desc => opt[:desc],
                    :aliases => opt[:aliase],
                    :banner => opt[:example]
            }
            def execute
                options.to_h
            end
            default_task :execute
        end
        def initialize
            result = Wrapper.start
            unless result.is_a? Hash
                exit 0
            end
            @options = result.collect { |k,v|
                candidate = ConfMaker::get_options.select{|e|e[:name] == k.to_sym}.first.clone
                candidate[:value] = v
                candidate
            }
        end
    end
    
end
