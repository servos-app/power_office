module PowerOffice
  # Filters are endpoint-specific and passed through under PowerOffice's own
  # names (`customerNos:`, `lastChangedDateTimeOffsetGreaterThan:`).
  class Resource
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def list(page_number: nil, page_size: nil, **filters)
      get_page(resource_path, page_number: page_number, page_size: page_size, **filters)
    end

    protected

    def resource_path
      raise NotImplementedError, "Subclass must implement #resource_path"
    end

    def get_page(path, page_number: nil, page_size: nil, **filters)
      client.get(path, params: {PageNumber: page_number, PageSize: page_size, **filters}.compact)
    end
  end
end
