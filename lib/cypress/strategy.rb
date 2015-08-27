module Cypress
  module Strategy
    # HACK!
    class Transaction
      def in
        ActiveRecord::Base.connection.execute('BEGIN')
      end

      def out
        ActiveRecord::Base.connection.execute('ROLLBACK')
      end
    end

    class DbCleaner
      def in
        ::DatabaseCleaner.start
      end

      def out
        ::DatabaseCleaner.clean
      end
    end
  end
end
