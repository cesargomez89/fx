require "fx/function"

module Fx
  module Adapters
    class Postgres
      # Fetches defined functions from the postgres connection.
      # @api private
      class Functions
        # The SQL query used by F(x) to retrieve the functions considered
        # dumpable into `db/schema.rb`.
        FUNCTIONS_WITH_DEFINITIONS_QUERY = <<-EOS.freeze
        SELECT routine_name as name, routine_definition as definition
        FROM INFORMATION_SCHEMA.Routines
        WHERE ROUTINE_SCHEMA != 'sys'
        ORDER by datetime_precision;
        EOS

        # Wraps #all as a static facade.
        #
        # @return [Array<Fx::Function>]
        def self.all(*args)
          new(*args).all
        end

        def initialize(connection)
          @connection = connection
        end

        # All of the functions that this connection has defined.
        #
        # @return [Array<Fx::Function>]
        def all
          functions_from_postgres.map { |function| to_fx_function(function) }
        end

        private

        attr_reader :connection

        def functions_from_postgres
          connection.execute(FUNCTIONS_WITH_DEFINITIONS_QUERY)
        end

        def to_fx_function(result)
          Fx::Function.new(result)
        end
      end
    end
  end
end
