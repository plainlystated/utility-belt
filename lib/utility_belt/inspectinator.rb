%w{rubygems platform net/http}.each {|library| require library}

UtilityBelt.equip(:clipboard)

module UtilityBelt
  module Inspectinator
    def inspect!(object)
      post_url = "http://www.inspectinator.com/parse.xml"
      response = Net::HTTP.post_form(URI.parse(post_url), {"i" => object.inspect}).body

      if response =~ /<token>(.*)<\/token>/
        show_url = "http://www.inspectinator.com/show/#{$1}"
        case Platform::IMPL
        when :macosx
          Kernel.system("open #{show_url}")
        when :mswin
          Kernel.system("start #{show_url}")
        else
          $stdout.puts "Sorry, don't know how to open an URL from the command line on your platform"
        end
      else
        $stdout.puts "Sorry, there seems to have been an error\n#{response}"
      end
    end
  end
end

class Object
  include UtilityBelt::Inspectinator
end if Object.const_defined? :IRB
