module PowerOffice
  module Resources
    class Products < Resource
      include Retrievable

      protected

      def resource_path
        "/Products"
      end
    end
  end
end
