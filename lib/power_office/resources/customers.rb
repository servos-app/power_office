module PowerOffice
  module Resources
    class Customers < Resource
      include Retrievable

      protected

      def resource_path
        "/Customers"
      end
    end
  end
end
