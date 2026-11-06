module PowerOffice
  module Resources
    # The client's posted transactions, filtered by date (`fromDate:`,
    # `toDate:`), account (`accountNos:`) and voucher type (`voucherTypes:`).
    class AccountTransactions < Resource
      protected

      def resource_path
        "/AccountTransactions"
      end
    end
  end
end
