require 'fastlane/action'
require_relative '../helper/jira_set_fix_version_helper'

module Fastlane
  module Actions
    module SharedValues
      CREATE_JIRA_VERSION_VERSION_ID = :CREATE_JIRA_VERSION_VERSION_ID
    end
    class JiraSetFixVersionAction < Action
      def self.run(params)
        Actions.verify_gem!('jira-ruby')
        require "jira-ruby"

        site         = params[:url]
        context_path = ""
        auth_type    = :basic
        username     = params[:username]
        password     = params[:password]
        project_name = params[:project_name]
        name         = params[:name]
        description  = params[:description]
        archived     = params[:archived]
        released     = params[:released]
        start_date   = params[:start_date]

        options = {
          username:     username,
          password:     password,
          site:         site,
          context_path: context_path,
          auth_type:    auth_type,
          read_timeout: 120
        }

        client = JIRA::Client.new(options)

        unless project_name.nil?
          project = client.Project.find(project_name)
          project_id = project.id
        end

        if start_date.nil?
          start_date = Date.today.to_s
        end

        version = project.versions.find { |version| version.name == name }
        if version.nil?
          version = client.Version.build
          version.save!({
            "description" => description,
            "name" => name,
            "archived" => archived,
            "released" => released,
            "startDate" => start_date,
            "projectId" => project_id
          })
        end
        Actions.lane_context[SharedValues::CREATE_JIRA_VERSION_VERSION_ID] = version.id

        if Actions.lane_context[SharedValues::FL_CHANGELOG].nil?
          changelog_configuration = FastlaneCore::Configuration.create(Actions::ChangelogFromGitCommitsAction.available_options, {})
          Actions::ChangelogFromGitCommitsAction.run(changelog_configuration)
        end
        issue_ids = Actions.lane_context[SharedValues::FL_CHANGELOG].scan(/#{project_name}-\d+/i).uniq
        issue_ids.each do |issue_id|
          begin
            issue = client.Issue.find(issue_id)
            fixVersions = [version]
            issue.save({"fields"=>{ "fixVersions" => fixVersions }})
          rescue JIRA::HTTPError
            "Skipping issue #{issue_id}"
          end
        end
        version.id
      end

      def self.description
        "Tags all Jira issues mentioned in git changelog with with a fix version from parameter :name"
      end

      def self.authors
        ["Tommy Sadiq Hinrichsen"]
      end

      def self.return_value
        "Return the name of the created Jira version"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "This action requires jira-ruby gem.

        Usage:
        lane :update_jira do
            version_number = get_version_number
            build_number = get_build_number
            lane = lane_context[SharedValues::LANE_NAME].split[-1]
            jira_set_fix_version(
              name: \"#{lane} #{version_number} (#{build_number})\"
            )
        end

        Thank you to https://github.com/valeriomazzeo/fastlane-plugin-jira_transition and https://github.com/valeriomazzeo/fastlane-plugin-jira_transition for inspiration.
        "
      end

      def self.available_options
          [
            FastlaneCore::ConfigItem.new(key: :url,
                                        env_name: "FL_CREATE_JIRA_VERSION_SITE",
                                        description: "URL for Jira instance",
                                        type: String,
                                        verify_block: proc do |value|
                                          UI.user_error!("No url for Jira given, pass using `url: 'url'`") unless value and !value.empty?
                                        end),
            FastlaneCore::ConfigItem.new(key: :username,
                                         env_name: "FL_CREATE_JIRA_VERSION_USERNAME",
                                         description: "Username for JIRA instance",
                                         type: String,
                                         verify_block: proc do |value|
                                           UI.user_error!("No username given, pass using `username: 'jira_user'`") unless value and !value.empty?
                                         end),
            FastlaneCore::ConfigItem.new(key: :password,
                                         env_name: "FL_CREATE_JIRA_VERSION_PASSWORD",
                                         description: "Password for Jira",
                                         type: String,
                                         verify_block: proc do |value|
                                           UI.user_error!("No password given, pass using `password: 'T0PS3CR3T'`") unless value and !value.empty?
                                         end),
            FastlaneCore::ConfigItem.new(key: :project_name,
                                         env_name: "FL_CREATE_JIRA_VERSION_PROJECT_NAME",
                                         description: "Project ID for the JIRA project. E.g. the short abbreviation in the JIRA ticket tags",
                                         type: String,
                                         optional: true,
                                         conflicting_options: [:project_id],
                                         conflict_block: proc do |value|
                                           UI.user_error!("You can't use 'project_name' and '#{project_id}' options in one run")
                                         end,
                                         verify_block: proc do |value|
                                           UI.user_error!("No Project ID given, pass using `project_id: 'PROJID'`") unless value and !value.empty?
                                         end),
            FastlaneCore::ConfigItem.new(key: :name,
                                         env_name: "FL_CREATE_JIRA_VERSION_NAME",
                                         description: "The name of the version. E.g. 1.0.0",
                                         type: String,
                                         verify_block: proc do |value|
                                           UI.user_error!("No version name given, pass using `name: '1.0.0'`") unless value and !value.empty?
                                         end),
            FastlaneCore::ConfigItem.new(key: :description,
                                         env_name: "FL_CREATE_JIRA_VERSION_DESCRIPTION",
                                         description: "The description of the JIRA project version",
                                         type: String,
                                         optional: true,
                                         default_value: ''),
            FastlaneCore::ConfigItem.new(key: :archived,
                                         env_name: "FL_CREATE_JIRA_VERSION_ARCHIVED",
                                         description: "Whether the version should be archived",
                                         optional: true,
                                         default_value: false),
            FastlaneCore::ConfigItem.new(key: :released,
                                         env_name: "FL_CREATE_JIRA_VERSION_CREATED",
                                         description: "Whether the version should be released",
                                         optional: true,
                                         default_value: false),
            FastlaneCore::ConfigItem.new(key: :start_date,
                                         env_name: "FL_CREATE_JIRA_VERSION_START_DATE",
                                         description: "The date this version will start on",
                                         type: String,
                                         is_string: true,
                                         optional: true,
                                         default_value: Date.today.to_s)
          ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
