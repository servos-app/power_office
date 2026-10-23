module PowerOffice
  module Resources
    class Projects < Resource
      include Retrievable

      protected

      def resource_path
        "/Projects"
      end
    end
  end
end
