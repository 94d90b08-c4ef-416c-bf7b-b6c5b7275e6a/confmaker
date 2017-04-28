# confmaker
Gem to make configuration options scope  
Gem get config from code (default), command line and YAML file(s) and
provide way to use it in code as cooked objects  


## It allows
- describe multiple options with default values, validators and parsers (getters)

> only String, Bool and Array-like options supported

- use regular expression to split options into parts and get it
- make default config, file-based config and command line config
- merge them all in any sequence to produce clear config as result
- export config into bash environment script or use it in ruby

## It canT
- add options not mentioned in code (defaults)
- parse too complex options (hash, file, io, ...)
- use other sources than code, file and command line

##Example
See example.rb  

## Option fields
Each option just a hash, so here describes keys that expected in it
- :name - option name (symbol expects)
- :desc - option description for some messages
- :aliase - single-character alias for command line
- :value - current value
- :check_regexp - regular expression for value checking/parsing. behaviour depends on type
- :example - value example/hint
- :cmdline_type - type for thor command line option. may not depends on option type
- :env_name(s) - key(s) to map value on it/them
- :validator - lambda that get *obj* (self) and context (all options) that used to check and/or transform obj[:value] to some (see example)
- :getter - lambda that should return meaningful value instead of **:value** if needed

> **:validator** not required if defautl validation all that needed  
> **:getter** not require if no needed to cook :value when return it  
> other type-specific fields above  

##Option Types
Option used to cook from raw value from files, command line in some in-code usable  
### Standard
- it just a prototype - not usable in most cases
- it is a hash. you may specify any field and use it in validator and getter
- it can return name, value array - **to_pair** method
- it can return meaningful values - **get** method
- it can return string that describes current parsed values - **to_s** method
### String
- it validate value by using **:validator** if provided
- then it check result by **:check_regexp** if defined
- it joins **:env_names** array with **:check_regexp** match to split **:value** string into meaningful parts

### Bool
- TrueClass of FalseClass expected by default
- it validate value by using **:validator** if provided
- **get** return "true" or "" by default (for bash)

### Array
- elements should be string
- if **:value** is a string (drops from command line) it splits by **:separator** into array
- **:check_regexp** used to check each element
- **get** return result depending on specified:
  + **:env_names** - join that array with values
  + **:env_name**  - joined **:value** mapped to **:env_name**
  + **:name** mapper to value


