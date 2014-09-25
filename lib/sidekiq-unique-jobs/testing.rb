require 'mock_redis'
module SidekiqUniqueJobs
  def self.redis_mock
     @redis_mock ||= MockRedis.new
  end

  def self.reset_redis_mock
    @redis_mock = nil
  end
end
