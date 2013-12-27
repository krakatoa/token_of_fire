module TokenOfFire
  class Scope
    def initialize(event_bus, filter={})
      @event_bus = event_bus
      raise RuntimeError, "Provide hash please" unless filter.is_a? Hash
      @filter = filter
      @subscriptions = []
    end

    def attach_subscriptions(list)
      list.each do |t|
        attach(t[0], t[1], t[2])
      end
    end

    def attach(event_name, handler, method_name)
      @subscriptions.push({
        :event_name => event_name,
        :handler => handler,
        :method_name => method_name
      })
      @subscriptions
    end

    def scope(filter={})
      TokenOfFire::Scope.new(@event_bus, @filter.merge(filter))
    end

    def subscriptions
      @subscriptions
    end
    # alias attach_subscription()

    # def dettach(:name_of_event)
    # @scope_a.dettach(:name_of_event)

    def token
      TokenOfFire::Token.new(@event_bus, self)
      #  starts with all subscriptions previously attached to a scope
    end
    
    def unique_token
      TokenOfFire::Token.new(@event_bus, self, true)
    end

    def filter
      @filter
    end
  end
end
