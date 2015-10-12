module Powernode
  module EncryptionExtensions
    extend ActiveSupport::Concern

    def encryption_key
      self.account.present? ? self.account.encryption_key + Powernode.config.key_pepper : nil
    end
  end

  module UUIDExtensions
    extend ActiveSupport::Concern

    def uuid
      UUIDTools::UUID.parse(id)
    end
  end

  module PostgreSQLQuoting
    extend ActiveSupport::Concern

    def nilify(value)
      !value || !value.is_a?(String) || value.length != 36 ? (return nil) : value
    end

    included do
      def quote_with_visiting(value, column = nil)
        value = nilify(value) if column && column.type == :uuid
        quote_without_visiting(value, column)
      end

      def type_cast_with_visiting(value, column = nil)
        value = nilify(value) if column && column.type == :uuid
        type_cast_without_visiting(value, column)
      end

      alias_method_chain :quote, :visiting
      alias_method_chain :type_cast, :visiting
    end
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send :include, Powernode::PostgreSQLQuoting if defined? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
