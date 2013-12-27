require 'set'

module TokenOfFire
  class Subscriptions

    def initialize(subscriptions={})
      @subscriptions = subscriptions

      @subscriptions_by_event_name = {}
    end

    def subscriptions
      @subscriptions
    end

    def subscribe(event_name, scope, handler, method_name)
      gen_uuid = SecureRandom.uuid
      @subscriptions[gen_uuid] ||= {}
      @subscriptions[gen_uuid] = {
        :event_name => event_name,
        :scope => scope,
        :handler => handler,
        :method_name => method_name
      }
      # $stdout.puts "subscription added: #{@subscriptions[gen_uuid]}"

      @subscriptions_by_event_name[event_name] ||= []
      @subscriptions_by_event_name[event_name] << gen_uuid

      gen_uuid
    end

    def unsubscribe(uuid)
      @subscriptions.reject! { |k| k == uuid }
      @subscriptions_by_event_name.each do |s_by_event_name|
        s_by_event_name.reject! { |v| v == uuid }
      end
    end

    def get_subscriptions(event_name=nil, scope=nil)
      # $stdout.puts "---\nSearching for: #{event_name}"
      # $stdout.puts "  scope: #{scope}"
      uuids = @subscriptions_by_event_name[event_name]
      return [] if not uuids
      @subscriptions.select { |k| uuids.include? k }.select { |k, v|
        # $stdout.puts "  check match: #{v[:scope]}"
        s1 = Set.new(scope)
        s2 = Set.new(v[:scope])
        value = s1.subset? s2
        # $stdout.puts "    #{value}"
        value
      }
    end
  end
end
