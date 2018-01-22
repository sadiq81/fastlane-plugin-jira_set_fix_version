# jira_set_fix_version plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-jira_set_fix_version)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-jira_set_fix_version`, add it to your project by running:

```bash
fastlane add_plugin jira_set_fix_version
```

## About jira_set_fix_version

Tags all Jira issues mentioned in git changelog with with a fix version from parameter :name

Usage:

```ruby
lane :update_jira do
    version_number = get_version_number
    build_number = get_build_number
    lane = lane_context[SharedValues::LANE_NAME].split[-1]
    jira_set_fix_version(
      name: "#{lane} #{version_number} (#{build_number})"
    )
end
```

Thank you to https://github.com/valeriomazzeo/fastlane-plugin-jira_transition and https://github.com/valeriomazzeo/fastlane-plugin-jira_transition for inspiration.

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane update_jira`.

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
