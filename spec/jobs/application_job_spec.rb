# require 'rails_helper'

# RSpec.describe ApplicationJob, type: :job do
#   describe "retrying deadlocked jobs" do
#     it "should automatically retry jobs that encountered a deadlock" do
#       # Arrange
#       job = ApplicationJob.new

#       # Act
#       allow(job).to receive(:retry_job)

#       # Assert
#       expect {
#         job.rescue_from(ActiveRecord::Deadlocked) { }
#       }.to change { job }.to have_received(:retry_job)
#     end
#   end

#   describe "discarding deserialization errors" do
#     it "should discard jobs when deserialization error occurs" do
#       # Arrange
#       job = ApplicationJob.new

#       # Act
#       allow(job).to receive(:discard_job)

#       # Assert
#       expect {
#         job.rescue_from(ActiveJob::DeserializationError) { }
#       }.to change { job }.to have_received(:discard_job)
#     end
#   end
# end
#
#
require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  describe 'enqueuing the job' do
    it 'can be enqueued' do
      expect {
        ApplicationJob.perform_later
      }.to have_enqueued_job(ApplicationJob)
    end

    it 'is in the default queue' do
      expect(ApplicationJob.new.queue_name).to eq('default')
    end

    # Add more tests for enqueueing scenarios if needed
  end

end
