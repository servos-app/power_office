module PowerOffice
  module Retrievable
    def retrieve(id)
      client.get("#{resource_path}/#{id}")
    end
  end
end
