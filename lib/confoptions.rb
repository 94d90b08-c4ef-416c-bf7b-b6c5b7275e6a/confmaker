module ConfOptions
    class Standard < Hash
        def initialize init_hash
            merge! init_hash
        end
        def to_pair
            [self[:name],self[:value]]
        end
        def get
            if self[:getter].is_a? Proc
                self[:getter].call self
            else
                default_getter
            end
        end
        def to_s
            get.collect { |k,v|
                k.to_s.capitalize.gsub('_',' ') + ': ' + v.to_s
            }.join "\n"
        end
    end
    class String < Standard
        def validate! context = ConfSources::Default.new
            self[:validator].call(self,context) if self[:validator].is_a? Proc
            default_validator if self[:check_regexp]
        end
        def get
            if self[:getter].is_a? Proc
                self[:getter].call self
            elsif self[:env_names].is_a? ::Array and self[:check_regexp].is_a? Regexp
                default_getter
            else
                [ to_pair ].to_h
            end
        end
    private
        def default_getter
            (self[:env_names].zip (self[:check_regexp].match self[:value]).to_a).to_h
        end
        def default_validator
            raise RuntimeError, "Option #{self[:name]} become #{self[:value].class} during validation" unless self[:value].is_a? ::String or self[:value].kind_of? Numeric
            raise ArgumentError, "#{self[:desc]} (#{self[:value].to_s}) must satisfy #{self[:check_regexp].to_s}" unless
                self[:value].to_s.match self[:check_regexp]
        end
    end
    class Bool < Standard
        def validate! context = ConfSources::Default.new
            default_validator
            self[:validator].call(self,context) if self[:validator].is_a? Proc
        end
        def to_s
            self[:name].to_s.capitalize.gsub('_',' ') + ': ' + self[:value].to_s
        end
    private
        def default_getter
            { (self[:env_name] ? self[:env_name] : self[:name] ) => (self[:value] ? "true" : "") }
        end
        def default_validator
            unless self[:value].is_a? TrueClass or self[:value].is_a? FalseClass
                raise ArgumentError, "Value #{self[:name]} is not boolean, but #{self[:value].class}" 
            end
        end
    end
    class Array < Standard
        def validate! context = ConfSources::Default.new
            default_validator
            self[:validator].call(self,context) if self[:validator].is_a? Proc
        end
    private
        def default_validator
            if self[:value].is_a? ::String
                unless self[:separator].is_a? ::String and self[:separator].length == 1
                    raise ArgumentError, "#{self[:name]} is a String, but :separator is not 1 symbol length String"
                end
                self[:value] = self[:value].split self[:separator]
            end
            unless self[:value].is_a? ::Array
                raise ArgumentError, "#{self[:name]} should be Array, but #{self[:value].class}"
            end
            if self[:check_regexp]
                self[:value].each {|el|
                    raise ArgumentError, "Array element #{el} sould satisfy #{self[:check_regexp]}, but is not" unless
                        el.to_s.match self[:check_regexp]
                }
            end 
        end
        def default_getter
            if self[:env_names]
                (self[:env_names].zip (self[:value])).to_h
            elsif self[:env_name]
                { self[:env_name] => self[:value].join(self[:separator]) }
            else
                { self[:name].to_s => self[:value].join(self[:separator]) }
            end
        end
    end
end
