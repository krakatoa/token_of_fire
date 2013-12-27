require 'celluloid'

module TokenOfFire
  Event = Struct.new(:name, :scope, :payload)

  class EventBus
    include Celluloid
    exclusive :subscribe

    def initialize
      @subscriptions = TokenOfFire::Subscriptions.new
      self
    end

    def scope(filter={})
      TokenOfFire::Scope.new(Celluloid::Actor.current, filter, true)
    end
    
    def subscribe(event_name, scope, handler, handler_method)
      uuid = @subscriptions.subscribe(event_name, scope, handler, handler_method)
      # $stdout.puts "-- Subscribe event_name: #{event_name} #{uuid}"
      uuid
    end

    def unsubscribe(uuid)
      # $stdout.puts "-- Unsubscribe uuid:#{uuid}"
      @subscriptions.unsubscribe(uuid)
    end

    def subscriptions
      @subscriptions.get_subscriptions
    end
  
    def trigger(event)
      subscriptions = @subscriptions.get_subscriptions(event.name, event.scope)
      if subscriptions and subscriptions.size > 0
        subscriptions.each_value do |subscription|
          subscription[:handler].send(subscription[:method_name], event.payload)
        end
      else
        # $stdout.puts "No subscriptions found for: scope: #{event.scope}, event_name: #{event.name}"
      end
    end

    def perform(event_name, scope, payload, sync_type)
      event = make_event(event_name, scope, payload)
      case sync_type
        when :async
          async.trigger(event)
        when :sync
          trigger(event)
      end
    end

    def fire(event_name, scope, payload)
      perform(event_name, scope, payload, :async)
    end

    def fire_sync(event_name, scope, payload)
      perform(event_name, scope, payload, :sync)
    end
    
    def make_event(event_name, scope, payload)
      TokenOfFire::Event.new(event_name, scope, payload)
    end
  end
end
