const path = require('path');

// Get the resource path, handling both FiveM and standalone environments
const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : 
    path.join(__dirname, '..');

// Export the settings
const settingsjson = require(path.join(resourcePath, 'settings.js'));

module.exports = {
    resourcePath,
    settingsjson
}; 