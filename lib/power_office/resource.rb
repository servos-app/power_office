module PowerOffice
  # Filters are endpoint-specific and passed through under PowerOffice's own
  # names (`customerNos:`, `lastChangedDateTimeOffsetGreaterThan:`).
  class Resource
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def list(page_number: nil, page_size: nil, **filters)
      client.get(resource_path, params: {PageNumber: page_number, PageSize: page_size, **filters}.compact)
    end

    protected

    def resource_path
      raise NotImplementedError, "Subclass must implement #resource_path"
    end
  end
end
