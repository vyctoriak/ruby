require 'minitest/autorun'
require 'timeout'
require_relative './customer_success_balancing'
require_relative './validations'

class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 20, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    balancer = CustomerSuccessBalancing.new(
      build_scores([11, 21, 31, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..999)),
      build_scores(Array.new(10_000, 998)),
      [999]
    )
    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(
      build_scores([1, 2, 3, 4, 5, 6]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 2, 3, 6, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6]
    )
    assert_equal 3, balancer.execute
  end

  def test_scenario_eight
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 40, 95, 75]),
      build_scores([90, 70, 20, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_customer_success_with_same_score
    balancer = CustomerSuccessBalancing.new(
      build_scores([50, 50, 50, 50]),
      build_scores([60, 70, 80, 90]),
      []
    )
    assert_equal 0, balancer.execute
  end
end

class ValidationsTest < Minitest::Test
  def test_customer_success_size
    exception = assert_raises(StandardError) do
      balancer = CustomerSuccessBalancing.new(
        build_scores(Array(1..1500)),
        build_scores(Array(1..200)),
        []
      )
      balancer.execute
    end
    assert_equal Validations::ERROR_INVALID_CUSTOMER_SUCCESS_SIZE, exception.message
  end

  def test_customer_success_score
    exception = assert_raises(StandardError) do
      balancer = CustomerSuccessBalancing.new(
        build_scores([10_500, 400, 700]),
        build_scores([800, 400, 700, 500, 600]),
        []
      )
      balancer.execute
    end
    assert_equal Validations::ERROR_INVALID_CUSTOMER_SUCCESS_SCORE, exception.message
  end

  def test_customer_sucess_ids
    exception = assert_raises(StandardError) do
      balancer = CustomerSuccessBalancing.new(
        [{ id: 1001, score: 600 }, { id: 1002, score: 500 }, { id: 1003, score: 400 }],
        build_scores([50, 100, 200]),
        []
      )
      balancer.execute
    end
    assert_equal Validations::ERROR_INVALID_CUSTOMER_SUCCESS_IDS, exception.message
  end

  def test_customer_size
    customers = []
    1_000_100.times do
      customers << { id: 1, score: 10 }
    end
    exception = assert_raises(StandardError) do
      balancer = CustomerSuccessBalancing.new(
        build_scores(Array(1..500)),
        customers,
        []
      )
      balancer.execute
    end
    assert_equal Validations::ERROR_INVALID_CUSTOMER_SIZE, exception.message
  end

  def test_customer_score
    exception = assert_raises(StandardError) do
      balancer = CustomerSuccessBalancing.new(
        build_scores(Array(1..200)),
        build_scores(Array(50_000..120_000)),
        []
      )
      balancer.execute
    end
    assert_equal Validations::ERROR_INVALID_CUSTOMER_SCORE, exception.message
  end

  def test_customer_ids
    exception = assert_raises(StandardError) do
      balancer = CustomerSuccessBalancing.new(
        build_scores([50, 100, 200]),
        [{ id: 1_000_005, score: 600 }],
        []
      )
      balancer.execute
    end
    assert_equal Validations::ERROR_INVALID_CUSTOMER_IDS, exception.message
  end

  def test_excessive_away_customer_success
    exception = assert_raises(StandardError) do
      balancer = CustomerSuccessBalancing.new(
        build_scores([60, 70, 80]),
        build_scores([10, 20, 30, 40, 50]),
        [1, 2, 3]
      )
      balancer.execute
    end
    assert_equal Validations::ERROR_EXCESSIVE_AWAY_CUSTOMER_SUCCESS, exception.message
  end
end

def build_scores(scores)
  scores.map.with_index do |score, index|
    { id: index + 1, score: score }
  end
end
