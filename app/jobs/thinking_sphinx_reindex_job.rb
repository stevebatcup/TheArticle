class ThinkingSphinxReindexJob < ApplicationJob
  queue_as :thinking_sphinx

  def perform
  	exec	'bundle exec rake ts:rt:index'
  end
end
