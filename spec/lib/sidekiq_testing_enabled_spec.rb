require 'spec_helper'
require 'sidekiq/worker'
require "sidekiq-unique-jobs"
require 'sidekiq-unique-jobs/testing'
require 'sidekiq/scheduled'
require 'sidekiq-unique-jobs/middleware/server/unique_jobs'
require 'rspec-sidekiq'

describe "When Sidekiq::Testing is enabled" do
  before do
    SidekiqUniqueJobs.reset_redis_mock
  end

  describe 'when set to :fake!', sidekiq: :fake do
    context "with unique worker" do
      let(:param) { 'work' }
      before do
        UniqueWorker.perform_async(param)
        UniqueWorker.perform_async(param)
      end

      it "does not push duplicate messages" do
        expect(UniqueWorker.jobs.size).to eq(1)
      end

      it "enques the job" do
        expect(UniqueWorker).to have_enqueued_job(param)
      end

      it "adds the unique_hash to the message" do
        hash = SidekiqUniqueJobs::PayloadHelper.get_payload(UniqueWorker, :working, [param])
        expect(UniqueWorker.jobs.first['unique_hash']).to eq(hash)
      end
    end

    context "with non-unique worker" do
      it "pushes duplicates messages" do
        param = 'work'
        expect(MyWorker.jobs.size).to eq(0)
        MyWorker.perform_async(param)
        expect(MyWorker.jobs.size).to eq(1)
        expect(MyWorker).to have_enqueued_job(param)
        MyWorker.perform_async(param)
        expect(MyWorker.jobs.size).to eq(2)
      end
    end
  end
end
