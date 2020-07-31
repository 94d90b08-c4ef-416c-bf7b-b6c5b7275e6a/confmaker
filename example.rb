#!/usr/bin/env ruby

puts "A lot of useful comments inside!"

#requrie gem into your application
require_relative 'lib/confmaker'
#require 'confmaker'

#define application description for command line hint
ConfMaker::define_desc "It is example of ConMaker usage" +
            "\nNotes:" +
            "\n\t- first note" +
            "\n\t- second one"

#define default options - used as basic list to determine option exist or not
#Array
config = ConfMaker::define_options [
#Single option
        ConfOptions::String.new(
            :name           => :version,
            :desc           => "current version",
            :aliase         => :v,
            :example        => "7.11.42",
            #default value here
            :value          => "0.0.0.1",
            :cmdline_type   => :string,
            :check_regexp   => /^\d+(\.\d+)*$/,
            :env_names      => [:main_version]
        #so, get method return {:main_version => 0.0.0.1} instead of {:version => 0.0.0.1}
        ),
#Other one String
        ConfOptions::String.new(
            :name           => :parent,
            :desc           => "default parent for tree",
            :aliase         => :p,
            :example        => "/1/2/3",
            :value          => "/",
            :cmdline_type   => :string,
            #there is no check_regexp, but custom validator
            :validator      => ->(obj,context){
                                    #ananlyze context
                                    if context.is_defined? :version
                                        obj[:value] = (obj[:value].match context[:version][:check_regexp]) ? obj[:value] : '/' + context[:version][:value].gsub('.','/')
                                    else
                                        raise RuntimeError, "version option required for #{obj[:name]} initialization"
                                    end
                                },
            #also, getter may be specified explicitely
            :getter         => ->(obj){
                                    {:tree_default_parent => obj[:value]}
                                }
        ),
#Array-like option
        ConfOptions::Array.new(
            :name           => :names,
            :desc           => "child names",
            :aliase         => :c,
            :example        => "one,other,ugly_one",
            :value          => "default,basic,custom",
            :cmdline_type   => :string,
            :env_names       => [1,2,:third],
            :separator      => ','
        ),
#Boolean option
        ConfOptions::Bool.new(
            :name           => :join_them,
            :desc           => "key to include some childs into tree",
            :value          => true,
            :cmdline_type   => :boolean,
            :env_name       => :is_to_join_childs
        )
    ]

#override defaults with command line
config.merge! ConfSources::CommandLine.new
#validation - can be called if all merged
config.validate!
#get option with name :names
p config[:names].get
#get and merge each option into single hash
config.to_h
#or just single raw value
p config[:join_them][:value]
#get array of hashed options (contains types, validator, getter and so on)
config.to_a
#Human-readable representation
puts config.to_s

