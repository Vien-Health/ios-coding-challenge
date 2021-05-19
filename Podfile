source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/goinstant/pods-specs-public'

inhibit_all_warnings!

#
# Syft
#

def pod_list
    platform :ios, "13.0"
    use_frameworks!

    # Pods for Countries
    pod "Alamofire", "= 5.0.0-rc.2"
    pod "AlamofireObjectMapper"
    pod "INSPersistentContainer"
    pod "MBProgressHUD"
 
end

target "Countries" do

    pod_list

end

post_install do |installer|

  # Try to fix @IBDesignable
  installer.pods_project.targets.each do |target|
    # add this line
    target.new_shell_script_build_phase.shell_script = "mkdir -p \"$PODS_CONFIGURATION_BUILD_DIR/#{target.name}\""
        target.build_configurations.each do |config|
            config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
        end
    end
end
