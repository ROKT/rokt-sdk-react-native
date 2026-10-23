# Tests how Rokt.Widget/ios/rokt_spm.rb links the Rokt Swift packages into an app's .xcodeproj.
# Needs the cocoapods gem: ruby .github/scripts/rokt_spm_test.rb
require 'cocoapods'
require 'minitest/autorun'
require 'tmpdir'
require_relative '../../Rokt.Widget/ios/rokt_spm'

class RNRoktSPMTest < Minitest::Test
  Installer = Struct.new(:aggregate_targets, :pod_targets)
  Aggregate = Struct.new(:platform, :pod_targets, :user_targets, :user_project)
  Platform = Struct.new(:name)
  PodTarget = Struct.new(:pod_name)

  SDK = [RNRoktSPM::SDK_URL, RNRoktSPM::SDK_PRODUCT].freeze
  PAYMENT = [RNRoktSPM::PACKAGES['RoktPaymentExtension'][:url], 'RoktPaymentExtension'].freeze
  HAND_ADDED = ['https://github.com/example/other-package', 'Other'].freeze
  FORK = ['https://github.com/example/rokt-sdk-ios-fork', 'Rokt-Widget'].freeze

  def setup
    Pod::Config.instance.silent = true
    @dir = Dir.mktmpdir
    @path = File.join(@dir, 'App.xcodeproj')
    project = Xcodeproj::Project.new(@path)
    project.new_target(:application, 'App', :ios)
    # An app target that does not use rokt-react-native-sdk.
    project.new_target(:application, 'Other', :ios)
    project.save
  end

  def teardown
    FileUtils.remove_entry(@dir)
    $RNRoktSPMPackages = nil
    $RNRoktSPMVersion = nil
  end

  # Runs the helper as `pod install` would, then reopens the saved project.
  def install(packages, version: nil, targets: %w[App])
    $RNRoktSPMPackages = packages
    $RNRoktSPMVersion = version
    project = Xcodeproj::Project.open(@path)
    user_targets = project.targets.select { |target| targets.include?(target.name) }
    aggregate = Aggregate.new(Platform.new(:ios), [PodTarget.new(RNRoktSPM::POD_NAME)], user_targets, project)
    RNRoktSPM.link_packages(Installer.new([aggregate], []))
    Xcodeproj::Project.open(@path)
  end

  def link_by_hand(target_name, (url, product))
    project = Xcodeproj::Project.open(@path)
    target = project.targets.find { |t| t.name == target_name }
    RNRoktSPM.add_package(project, target, url: url, product: product, version: '1.0.0')
    project.save
  end

  def linked(project, target_name)
    target = project.targets.find { |t| t.name == target_name }
    deps = target.package_product_dependencies.map { |dep| [dep.package.repositoryURL, dep.product_name] }
    frameworks = target.frameworks_build_phase.files.map(&:product_ref).compact.map(&:product_name)
    assert_equal deps.map(&:last).sort, frameworks.sort, 'each linked product has one framework build file'
    deps.sort
  end

  def references(project)
    project.root_object.package_references.map(&:repositoryURL).sort
  end

  def versions(project)
    project.root_object.package_references.to_h { |ref| [ref.repositoryURL, ref.requirement['version']] }
  end

  def pbxproj
    File.read(File.join(@path, 'project.pbxproj'))
  end

  # The hooks override private CocoaPods methods. If CocoaPods renames one, the guard and the
  # linking would silently stop running, so fail here instead.
  def test_cocoapods_still_has_the_hooked_methods
    %i[validate_targets run_podfile_post_install_hooks installation_options].each do |name|
      assert_includes Pod::Installer.private_instance_methods, name
    end
    assert_includes Pod::Installer.ancestors, RNRoktSPM::InstallerHooks
  end

  def test_links_the_sdk_at_the_default_version
    project = install(nil)
    assert_equal [SDK], linked(project, 'App')
    assert_equal({ SDK.first => RNRoktSPM::DEFAULT_VERSION }, versions(project))
    assert_empty linked(project, 'Other')
  end

  def test_links_app_clips_and_app_extensions_that_use_this_pod
    project = Xcodeproj::Project.open(@path)
    project.new_target(:application, 'Clip', :ios).product_type =
      'com.apple.product-type.application.on-demand-install-capable'
    project.new_target(:app_extension, 'Widget', :ios)
    project.new_target(:unit_test_bundle, 'Tests', :ios)
    project.save
    project = install(nil, targets: %w[App Clip Widget Tests])
    %w[App Clip Widget].each { |name| assert_equal [SDK], linked(project, name), name }
    assert_empty linked(project, 'Tests')
    assert_empty linked(project, 'Other')
  end

  def test_installing_again_changes_nothing
    install(['RoktPaymentExtension'])
    before = pbxproj
    project = install(['RoktPaymentExtension'])
    assert_equal before, pbxproj
    assert_equal [SDK, PAYMENT].sort, linked(project, 'App')
  end

  def test_removing_a_package_unlinks_it
    install(['RoktPaymentExtension'])
    project = install([])
    assert_equal [SDK], linked(project, 'App')
    assert_equal [SDK.first], references(project)

    before = pbxproj
    install([])
    assert_equal before, pbxproj
  end

  def test_changing_the_version_pins_every_package_to_it
    install(['RoktPaymentExtension'])
    project = install(['RoktPaymentExtension'], version: '5.6.0')
    assert_equal({ SDK.first => '5.6.0', PAYMENT.first => '5.6.0' }, versions(project))
  end

  def test_reuses_a_reference_added_by_hand_with_a_git_suffix
    link_by_hand('App', ["#{RNRoktSPM::SDK_URL}.git", 'Rokt-Widget'])
    project = install(nil)
    assert_equal ["#{RNRoktSPM::SDK_URL}.git"], references(project)
    assert_equal [["#{RNRoktSPM::SDK_URL}.git", 'Rokt-Widget']], linked(project, 'App')
    assert_equal RNRoktSPM::DEFAULT_VERSION, versions(project)["#{RNRoktSPM::SDK_URL}.git"]
  end

  def test_reuses_a_reference_added_by_hand_over_ssh
    ssh = 'git@github.com:ROKT/rokt-sdk-ios.git'
    link_by_hand('App', [ssh, 'Rokt-Widget'])
    project = install(nil)
    assert_equal [ssh], references(project)
    assert_equal [[ssh, 'Rokt-Widget']], linked(project, 'App')
  end

  def test_matches_other_spellings_of_the_sdk_url_but_not_another_owner
    %w[ssh://git@github.com/ROKT/rokt-sdk-ios http://github.com/rokt/rokt-sdk-ios/].each do |url|
      assert RNRoktSPM.same_url?(RNRoktSPM::SDK_URL, url), url
    end
    refute RNRoktSPM.same_url?(RNRoktSPM::SDK_URL, 'https://github.com/example/rokt-sdk-ios')
  end

  def test_keeps_hand_added_packages_and_references_other_targets_use
    link_by_hand('App', HAND_ADDED)
    link_by_hand('Other', PAYMENT)
    install(['RoktPaymentExtension'])
    project = install([])
    assert_equal [SDK, HAND_ADDED].sort, linked(project, 'App')
    assert_equal [PAYMENT], linked(project, 'Other')
    assert_equal [SDK.first, PAYMENT.first, HAND_ADDED.first].sort, references(project)
  end

  def test_stops_instead_of_replacing_a_hand_added_package_with_the_same_product
    link_by_hand('App', FORK)
    before = pbxproj
    error = assert_raises(Pod::Informative) { install(nil) }
    assert_includes error.message, FORK.first
    assert_equal before, pbxproj
  end

  def test_a_package_listed_twice_is_linked_once
    $RNRoktSPMPackages = %w[RoktPaymentExtension RoktPaymentExtension]
    assert_equal [SDK.last, PAYMENT.last], RNRoktSPM.packages.map { |pkg| pkg[:product] }
  end

  def test_rejects_an_unknown_package
    $RNRoktSPMPackages = ['RoktSomethingElse']
    error = assert_raises(Pod::Informative) { RNRoktSPM.packages }
    assert_includes error.message, 'RoktSomethingElse'
  end

  def test_stops_when_a_pod_would_add_a_second_copy
    installer = Installer.new([], [PodTarget.new('Rokt-Widget'), PodTarget.new('RoktContracts'), PodTarget.new('React-Core')])
    error = assert_raises(Pod::Informative) { RNRoktSPM.guard!(installer) }
    assert_includes error.message, 'Rokt-Widget, RoktContracts'
    refute_includes error.message, 'React-Core'
  end

  def test_allows_pods_that_do_not_contain_the_sdk
    RNRoktSPM.guard!(Installer.new([], [PodTarget.new('React-Core'), PodTarget.new(RNRoktSPM::POD_NAME)]))
  end
end
