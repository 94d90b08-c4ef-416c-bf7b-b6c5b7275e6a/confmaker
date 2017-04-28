module ConfMaker
    require_relative 'confoptions'
    def self.define_desc desc
        @@desc = desc
    end
    def self.get_desc
        @@desc
    end
    def self.define_options options
        @@options = options
        require_relative 'confsources'
        ConfSources::Default.new
    end
    def self.get_options
        @@options
    end

end
