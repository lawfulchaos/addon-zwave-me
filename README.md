# Z-Wave.Me add-on for Home Assistant


<!--

Notes to developers after forking or using the github template feature:
- While developing comment out the 'image' key from 'zwave_me/config.yaml' to make the supervisor build the addon
  - Remember to put this back when pushing up your changes.
- When you merge to the 'main' branch of your repository a new build will be triggered.
  - Make sure you adjust the 'version' key in 'zwave_me/config.yaml' when you do that.
  - Make sure you update 'zwave_me/CHANGELOG.md' when you do that.
  - The first time this runs you might need to adjust the image configuration on github container registry to make it public
- Adjust the 'image' key in 'zwave_me/config.yaml' so it points to your username instead of 'home-assistant'.
  - This is where the build images will be published to.
- Rename the zwave_me directory.
  - The 'slug' key in 'zwave_me/config.yaml' should match the directory name.
- Adjust all keys/url's that points to 'home-assistant' to now point to your user/fork.
- Share your repository on the forums https://community.home-assistant.io/c/projects/9
- Do awesome stuff!
 -->

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
