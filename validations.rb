module Validations
  ERROR_INVALID_CUSTOMER_SUCCESS_SIZE = 'Invalid customer success size'
  ERROR_INVALID_CUSTOMER_SUCCESS_SCORE = 'Invalid customer success score'
  ERROR_INVALID_CUSTOMER_SUCCESS_IDS = 'Invalid customer success IDs'
  ERROR_INVALID_CUSTOMER_SIZE = 'Invalid customer size'
  ERROR_INVALID_CUSTOMER_SCORE = 'Invalid customer score'
  ERROR_INVALID_CUSTOMER_IDS = 'Invalid customer IDs'
  ERROR_EXCESSIVE_AWAY_CUSTOMER_SUCCESS = 'Excessive away customer success'

  class CustomerSuccessValidation
    def initialize(customer_success, away_customer_success)
      @customer_success = customer_success
      @away_customer_success = away_customer_success
    end

    def validate
      valid_customer_success_size
      valid_customer_success_scores
      valid_customer_success_ids
      valid_excessive_away_customer_success
    end

    private

    def valid_customer_success_size
      return if @customer_success.size >= 0 && @customer_success.size <= 1000

      raise StandardError, ERROR_INVALID_CUSTOMER_SUCCESS_SIZE
    end

    def valid_customer_success_scores
      return if @customer_success.all? { |cs| !(cs[:score] < 0) && !(cs[:score] > 10_000) }

      raise StandardError, ERROR_INVALID_CUSTOMER_SUCCESS_SCORE
    end

    def valid_customer_success_ids
      return if @customer_success.all? { |cs| !(cs[:id] < 0) && !(cs[:id] > 1000) }

      raise StandardError, ERROR_INVALID_CUSTOMER_SUCCESS_IDS
    end

    def valid_excessive_away_customer_success
      return unless @away_customer_success.size > @customer_success.size / 2

      raise StandardError, ERROR_EXCESSIVE_AWAY_CUSTOMER_SUCCESS
    end
  end

  class CustomerValidation
    def initialize(customers)
      @customers = customers
    end

    def validate
      valid_customer_size
      valid_customer_scores
      valid_customer_ids
    end

    private

    def valid_customer_size
      return if @customers.size > 0 && @customers.size < 1_000_000

      raise StandardError, ERROR_INVALID_CUSTOMER_SIZE
    end

    def valid_customer_scores
      return if @customers.all? { |customer| !(customer[:score] < 0) && !(customer[:score] > 100_000) }

      raise StandardError, ERROR_INVALID_CUSTOMER_SCORE
    end

    def valid_customer_ids
      return if @customers.all? { |customer| !(customer[:id] < 0) && !(customer[:id] > 1_000_000) }

      raise StandardError, ERROR_INVALID_CUSTOMER_IDS
    end
  end
end
