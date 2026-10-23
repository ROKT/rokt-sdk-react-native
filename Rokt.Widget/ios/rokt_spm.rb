# Swift Package Manager mode for the Rokt iOS SDK, the default (see README › Swift Package Manager).
#
# rokt-react-native-sdk.podspec loads this file on every `pod install` and turns the mode on unless the
# Podfile opts out. React Native and this package still install with CocoaPods; the Rokt iOS SDK is a
# Swift package linked into the app target. Podfile settings, all optional, set before the first
# `target` block, which evaluates the podspec:
#
#   $RNRoktSPMVersion = '5.5.5'                    # exact Rokt iOS SDK version
#   $RNRoktSPMPackages = ['RoktPaymentExtension']  # optional Rokt packages, at the same version
#   $RNRoktDisableSPM = true                       # take the SDK from CocoaPods instead
#
# On each `pod install` in this mode:
#   1. Before CocoaPods validates the targets, it stops the install if a pod would add a second copy of
#      the Rokt SDK. Mixing pods and Swift packages builds and archives silently, then misbehaves at
#      runtime.
#   2. After the Podfile's post_install hook, it links the Rokt iOS SDK and each listed package, pinned
#      to an exact version, into every iOS app, App Clip and app extension target that uses this pod.
#      The target owns the only copy. It unlinks the optional packages the Podfile does not list.
# With the opt-out, it only warns when an app target still links the Rokt Swift packages.
require 'xcodeproj'

module RNRoktSPM
  POD_NAME = 'rokt-react-native-sdk'.freeze
  # Keep this URL byte-identical to the one the mParticle Rokt kit uses, so an app with both gets one
  # package identity (rokt-sdk-ios), not two. No `.git` suffix.
  SDK_URL = 'https://github.com/ROKT/rokt-sdk-ios'.freeze
  SDK_PRODUCT = 'Rokt-Widget'.freeze
  # Default version when the Podfile sets none. Bump with each tested native release.
  DEFAULT_VERSION = '5.5.5'.freeze
  # Optional packages by their CocoaPods name. They are released with the Rokt iOS SDK, at its version.
  PACKAGES = {
    'RoktPaymentExtension' => { url: 'https://github.com/ROKT/rokt-payment-extension-ios', product: 'RoktPaymentExtension' }
  }.freeze
  # The packages this file links, and unlinks when the Podfile no longer lists them.
  MANAGED_URLS = [SDK_URL, *PACKAGES.values.map { |pkg| pkg[:url] }].freeze
  CONFLICTING_PODS = /\A(Rokt-Widget|RoktContracts|RoktUXHelper|DcuiSchema|RoktPaymentExtension)\z/.freeze
  # Apps, App Clips and app extensions (widgets included) link this pod's code, so each needs the SDK.
  SDK_PRODUCT_TYPES = %w[com.apple.product-type.application com.apple.product-type.app-extension].freeze

  def self.enabled?
    !(defined?($RNRoktDisableSPM) && $RNRoktDisableSPM)
  end

  def self.version
    (defined?($RNRoktSPMVersion) && $RNRoktSPMVersion) || DEFAULT_VERSION
  end

  # The Rokt iOS SDK plus $RNRoktSPMPackages, as { url:, product:, version: } hashes.
  def self.packages
    names = Array(defined?($RNRoktSPMPackages) ? $RNRoktSPMPackages : nil).uniq
    unknown = names - PACKAGES.keys
    unless unknown.empty?
      raise Pod::Informative,
            "[Rokt] $RNRoktSPMPackages: unknown package #{unknown.map(&:inspect).join(', ')}. " \
            "Known packages: #{PACKAGES.keys.join(', ')}."
    end
    [{ url: SDK_URL, product: SDK_PRODUCT, version: version }] +
      names.map { |name| PACKAGES[name].merge(version: version) }
  end

  # Package URLs that differ only by case, scheme (https, http, ssh, git@host:), a trailing slash or a
  # `.git` suffix are the same package, so a hand-added reference is reused rather than added twice. A
  # repository under another owner, such as a fork, is a different package.
  def self.same_url?(left, right)
    normalize = lambda do |url|
      url.to_s.downcase.chomp('/').delete_suffix('.git')
         .sub(%r{\A[a-z+]+://}, '').sub(%r{\A[^/@]+@}, '').sub(%r{\A([^/:]+):(?!\d)}, '\\1/')
    end
    normalize.call(left) == normalize.call(right)
  end

  def self.managed?(url)
    MANAGED_URLS.any? { |managed| same_url?(managed, url) }
  end

  def self.guard!(installer)
    conflicts = installer.pod_targets.map(&:pod_name).uniq.grep(CONFLICTING_PODS)
    return if conflicts.empty?

    raise Pod::Informative,
          '[Rokt] This package takes the Rokt iOS SDK from Swift Package Manager, but these pods would ' \
          "add a second copy: #{conflicts.sort.join(', ')}. Either remove them (and their entries in any " \
          'pre_install dynamic-framework hook), listing RoktPaymentExtension in $RNRoktSPMPackages instead, ' \
          'or set $RNRoktDisableSPM = true at the top of the Podfile to stay on CocoaPods. Another package ' \
          'that installs the Rokt SDK with CocoaPods, such as react-native-mparticle on CocoaPods, adds ' \
          'these pods too: move it to Swift Package Manager as well, or opt out here.'
  end

  # Only iOS targets that use this pod: other targets in the same Podfile must not get the SDK.
  def self.sdk_targets(installer)
    aggregates = installer.aggregate_targets.select do |aggregate|
      aggregate.platform.name == :ios && aggregate.pod_targets.any? { |pod| pod.pod_name == POD_NAME }
    end
    aggregates.flat_map do |aggregate|
      aggregate.user_targets
               .select { |t| t.product_type.to_s.start_with?(*SDK_PRODUCT_TYPES) }
               .map { |t| [aggregate.user_project, t] }
    end.uniq { |project, target| [project.path.to_s, target.uuid] }
  end

  def self.add_package(project, target, url:, product:, version:)
    ref = project.root_object.package_references.find do |r|
      r.is_a?(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference) && same_url?(r.repositoryURL, url)
    end
    unless ref
      ref = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
      ref.repositoryURL = url
      project.root_object.package_references << ref
    end
    requirement = { 'kind' => 'exactVersion', 'version' => version }
    changed = ref.requirement != requirement
    ref.requirement = requirement

    # A product linked from a package this file does not manage, such as a fork, stays as it is.
    dep = target.package_product_dependencies.find { |d| d.product_name == product }
    if dep
      linked_url = dep.package.respond_to?(:repositoryURL) ? dep.package.repositoryURL : 'a local package'
      unless dep.package == ref || managed?(linked_url)
        raise Pod::Informative,
              "[Rokt] #{target.name} already links #{product} from #{linked_url}, but this package takes " \
              "it from #{url}. Remove it from the target in Xcode, or set $RNRoktDisableSPM = true."
      end
      changed ||= dep.package != ref
      dep.package = ref
      return changed
    end

    dep = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
    dep.package = ref
    dep.product_name = product
    target.package_product_dependencies << dep
    build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
    build_file.product_ref = dep
    target.frameworks_build_phase.files << build_file
    true
  end

  def self.unlink_unlisted(target, products)
    unlisted = target.package_product_dependencies.select do |dep|
      dep.package.respond_to?(:repositoryURL) && managed?(dep.package.repositoryURL) &&
        !products.include?(dep.product_name)
    end
    unlisted.each do |dep|
      target.build_phases.each do |phase|
        phase.files.select { |file| file.product_ref == dep }.each(&:remove_from_project)
      end
      dep.remove_from_project
      Pod::UI.puts "[Rokt] #{target.name} -x #{dep.product_name} (not in $RNRoktSPMPackages)".yellow
    end
  end

  # Keeps a package another target still links.
  def self.remove_unused_references(project)
    used = project.objects.grep(Xcodeproj::Project::Object::XCSwiftPackageProductDependency).map(&:package)
    project.root_object.package_references.select do |ref|
      ref.respond_to?(:repositoryURL) && managed?(ref.repositoryURL) && !used.include?(ref)
    end.each do |ref|
      Pod::UI.puts "[Rokt] Removed the unused Swift package #{ref.repositoryURL}".yellow
      ref.remove_from_project
    end
  end

  def self.link_packages(installer)
    packages = self.packages
    touched = {}
    sdk_targets(installer).each do |project, target|
      packages.each do |pkg|
        added = add_package(project, target, **pkg)
        Pod::UI.puts "[Rokt] #{target.name} <- #{pkg[:product]} #{pkg[:version]}".green if added
      end
      unlink_unlisted(target, packages.map { |pkg| pkg[:product] })
      touched[project.path.to_s] = project
    end
    touched.each_value do |project|
      remove_unused_references(project)
      project.save
    end
  end

  # With the opt-out, the CocoaPods SDK and any leftover Swift package would both be linked.
  def self.warn_leftover_packages(installer)
    products = [SDK_PRODUCT, *PACKAGES.values.map { |pkg| pkg[:product] }]
    sdk_targets(installer).each do |_, target|
      leftover = target.package_product_dependencies.map(&:product_name) & products
      next if leftover.empty?

      Pod::UI.warn "[Rokt] $RNRoktDisableSPM is set, but #{target.name} still links the Swift packages " \
                   "#{leftover.join(', ')}. Remove them from the target, or the app contains two copies of the SDK."
    end
  end

  # Prepended to Pod::Installer when the Podfile evaluates the podspec (React Native's
  # use_native_modules! does), before the install starts, so no Podfile hook is needed.
  module InstallerHooks
    private

    def validate_targets
      if RNRoktSPM.enabled?
        RNRoktSPM.guard!(self)
        RNRoktSPM.packages
      end
      super
    end

    def run_podfile_post_install_hooks
      super
      if RNRoktSPM.enabled?
        # A Podfile that integrates its targets itself (integrate_targets: false) expects no project
        # edits.
        RNRoktSPM.link_packages(self) if installation_options.integrate_targets?
      else
        RNRoktSPM.warn_leftover_packages(self)
      end
    end
  end
end

if defined?(Pod::Installer) && !Pod::Installer.ancestors.include?(RNRoktSPM::InstallerHooks)
  Pod::Installer.prepend(RNRoktSPM::InstallerHooks)
end
