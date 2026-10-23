module PowerOffice
  module Resources
    class Departments < Resource
      include Retrievable

      protected

      def resource_path
        "/Departments"
      end
    end
  end
end
