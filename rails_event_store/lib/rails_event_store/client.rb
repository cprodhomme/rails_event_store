module RailsEventStore
  class Client < RubyEventStore::Client
    attr_reader :request_metadata

    def initialize(repository: RailsEventStoreActiveRecord::EventRepository.new,
                   mapper: RubyEventStore::Mappers::Default.new,
                   broker: RubyEventStore::PubSub::Broker.new(
                     dispatcher: ActiveJobDispatcher.new),
                   request_metadata: default_request_metadata,
                   page_size: PAGE_SIZE)
      super(repository: repository,
            mapper: mapper,
            broker: broker,
            page_size: page_size)
      @request_metadata = request_metadata
    end

    def with_request_metadata(env, &block)
      with_metadata(request_metadata.call(env)) do
        block.call
      end
    end

    private
    def default_request_metadata
      ->(env) do
        request = ActionDispatch::Request.new(env)
        {
          remote_ip:  request.remote_ip,
          request_id: request.uuid
        }
      end
    end
  end
end
