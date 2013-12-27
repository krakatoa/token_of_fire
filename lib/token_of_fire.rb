require "token_of_fire/event_bus"
require "token_of_fire/scope"
require "token_of_fire/subscriptions"
require "token_of_fire/token"
require "token_of_fire/version"

module TokenOfFire
  def self.bus
    TokenOfFire::EventBus.new
  end
end
