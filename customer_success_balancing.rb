require 'minitest/autorun'
require 'timeout'
require_relative './validations'


class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  def execute
    validate
    filter_eligible_customer_success!
    order_customer_success_by_score!

    @customer_success.each do |customer_success|
      initial_size = @customers.size
      @customers.reject! { |customer| customer[:score] <= customer_success[:score] }
      customer_success[:customers] = initial_size - @customers.size
    end

    customer_success_with_most_customers = @customer_success.max_by { |hash| hash[:customers] }
    
    return 0 if has_tie?(customer_success_with_most_customers)
    customer_success_with_most_customers[:id]
  end

  private 

  def validate
    Validations::CustomerSuccessValidation.new(@customer_success, @away_customer_success).validate
    Validations::CustomerValidation.new(@customers).validate
  end

  def filter_eligible_customer_success!
    @customer_success.reject! { |cs| @away_customer_success.include?(cs[:id]) }
  end
  
  def order_customer_success_by_score!
    @customer_success.sort_by! { |cs| cs[:score] }
  end

  def has_tie?(manager_with_most_customers)
    @customer_success.any? { |cs| cs[:id] != manager_with_most_customers[:id] && cs[:customers] == manager_with_most_customers[:customers] }
  end
end