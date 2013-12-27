module TokenOfFire
  class Token
    def initialize(event_bus, scope, unique=false)
      @event_bus = event_bus
      @scope = scope
      @uuid = SecureRandom.uuid
      @unique = unique
      subscribe_to_all
    end

    def filter
      filter = @scope.filter.dup
      filter.merge!(:uuid => @uuid) if @unique
      filter
    end

    def fire(event_name, payload)
      @event_bus.fire(event_name, filter, payload)
    end

    def fire_sync
      @event_bus.fire_sync(event_name, filter, payload)
    end

    def release
      @subscription_uuids.each do |uuid|
        @event_bus.unsubscribe(uuid)
      end
    end

    private
    def subscribe_to_all
      @subscription_uuids = @scope.subscriptions.collect do |subscription|
        @event_bus.subscribe(
          subscription[:event_name], filter, subscription[:handler], subscription[:method_name]
        )
      end
    end
  end
end
