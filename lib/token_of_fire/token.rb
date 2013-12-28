module TokenOfFire
  class Token
    def initialize(event_bus, scope, unique=false)
      @event_bus = event_bus
      @scope = scope
      @uuid = SecureRandom.uuid
      @unique = unique
      @subscription_uuids = []
      subscribe_to_all
    end

    def filter
      filter = @scope.filter.dup
      filter.merge!(:uuid => @uuid) if @unique
      filter
    end

    def fire(event_name, payload)
      @event_bus.fire(event_name, payload, filter)
    end

    def fire_sync(event_name, payload)
      @event_bus.fire_sync(event_name, payload, filter)
    end

    def release
      @subscription_uuids.each do |uuid|
        @event_bus.unsubscribe(uuid)
      end
    end

    def attach_subscriptions(list)
      list.each do |t|
        attach(t[0], t[1], t[2])
      end
    end

    def attach(event_name, handler, method_name)
      @subscription_uuids << @event_bus.subscribe(event_name, filter, handler, method_name)
    end

    private
    def subscribe_to_all
      @scope.subscriptions.each do |subscription|
        attach(subscription[:event_name], subscription[:handler], subscription[:method_name])
      end
    end
  end
end
