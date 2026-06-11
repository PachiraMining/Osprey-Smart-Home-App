# Thêm target OspreyWidgetExtension (WidgetKit) vào Runner.xcodeproj.
# Chạy: ruby scripts/add_widget_target.rb   (idempotent — chạy lại an toàn)
require 'xcodeproj'

PROJECT_PATH = File.expand_path('../ios/Runner.xcodeproj', __dir__)
TARGET_NAME = 'OspreyWidgetExtension'
BUNDLE_ID = 'io.dracaena.curtainai.OspreyWidget'
TEAM_ID = 'FJU9H2Z6H8'
DEPLOYMENT_TARGET = '17.0'

project = Xcodeproj::Project.open(PROJECT_PATH)

if project.targets.any? { |t| t.name == TARGET_NAME }
  puts "Target #{TARGET_NAME} đã tồn tại — bỏ qua."
  exit 0
end

runner = project.targets.find { |t| t.name == 'Runner' }
abort 'Không tìm thấy target Runner' unless runner

# Target extension
target = project.new_target(:app_extension, TARGET_NAME, :ios, DEPLOYMENT_TARGET)

# Group + source files (đường dẫn tương đối từ ios/)
group = project.main_group.new_group('OspreyWidget', 'OspreyWidget')
source_refs = %w[OspreyWidgetBundle.swift OspreyCurtainWidget.swift].map do |f|
  group.new_file(f)
end
group.new_file('Info.plist')
group.new_file('OspreyWidget.entitlements')
target.add_file_references(source_refs)

target.build_configurations.each do |config|
  bs = config.build_settings
  bs['PRODUCT_BUNDLE_IDENTIFIER'] = BUNDLE_ID
  bs['PRODUCT_NAME'] = 'OspreyWidget'
  bs['SWIFT_VERSION'] = '5.0'
  bs['DEVELOPMENT_TEAM'] = TEAM_ID
  bs['CODE_SIGN_STYLE'] = 'Automatic'
  bs['INFOPLIST_FILE'] = 'OspreyWidget/Info.plist'
  bs['GENERATE_INFOPLIST_FILE'] = 'NO'
  bs['CODE_SIGN_ENTITLEMENTS'] = 'OspreyWidget/OspreyWidget.entitlements'
  bs['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT_TARGET
  bs['TARGETED_DEVICE_FAMILY'] = '1,2'
  bs['MARKETING_VERSION'] = '1.0'
  bs['CURRENT_PROJECT_VERSION'] = '1'
  bs['SKIP_INSTALL'] = 'YES'
  bs['LD_RUNPATH_SEARCH_PATHS'] =
    '$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks'
end

# Nhúng extension vào Runner (PlugIns)
embed = runner.copy_files_build_phases.find { |p| p.name == 'Embed Foundation Extensions' }
if embed.nil?
  embed = runner.new_copy_files_build_phase('Embed Foundation Extensions')
  embed.dst_subfolder_spec = '13' # PlugIns
  embed.dst_path = ''
end
build_file = embed.add_file_reference(target.product_reference)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
runner.add_dependency(target)

project.save
puts "Đã thêm target #{TARGET_NAME} (#{BUNDLE_ID}, iOS #{DEPLOYMENT_TARGET})."
