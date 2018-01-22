describe Fastlane::Actions::JiraSetFixVersionAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The jira_set_fix_version plugin is working!")

      Fastlane::Actions::JiraSetFixVersionAction.run(nil)
    end
  end
end
