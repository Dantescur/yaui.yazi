# Yazi Plugin Manager UI

**Yazi Plugin Manager UI** is an intuitive and user-friendly interface designed to manage plugins within the Yazi file manager . With this plugin manager, you can easily install, update, remove, and configure plugins without leaving the comfort of your terminal-based file manager.

## Features

- Plugin Installation : Quickly install new plugins from a curated list or custom repositories.
- Plugin Updates : Keep all your plugins up-to-date with a single command.
- Plugin Removal : Safely remove unwanted plugins to declutter your setup.
- Configuration Management : Easily toggle plugin settings and customize behavior.
- Search Functionality : Search for plugins by name or description to find what you need fast.
- Status Indicators : View the status of each plugin (installed, outdated, etc.) at a glance.

## Installation

### Prerequisites

- Ensure you have Yazi installed on your system.
- Make sure you have a working Rust environment if you plan to build from source.
- Steps to Install
  - Clone the Repository
    ```
     git clone https://github.com/yourusername/yazi-plugin-manager-ui.git
    ```

cd yazi-plugin-manager-ui
Build and Install
cargo build --release
cp target/release/yazi-plugin-manager ~/.config/yazi/plugins/
Enable the Plugin in Yazi
Add the following line to your Yazi configuration file (~/.config/yazi/config.toml):
toml
[plugins]
enabled = ["plugin-manager"]
Restart Yazi
Restart Yazi to load the plugin manager UI.
Usage
Once installed, you can access the plugin manager UI by pressing the designated keybinding (default: p) while inside Yazi. From there, you can:

Navigate Plugins : Use arrow keys to browse through the list of available plugins.
Install/Update/Remove : Select a plugin and press the corresponding key to perform actions.
Configure Settings : Toggle settings and save changes directly from the UI.
Search Plugins : Press / to search for specific plugins by name or description.
Keybindings
Enter
Open selected plugin
i
Install selected plugin
u
Update selected plugin
r
Remove selected plugin
/
Search for plugins
q
Quit the plugin manager

Configuration
You can further customize the behavior of the plugin manager by editing the ~/.config/yazi/plugins/plugin-manager.toml file. Here are some common options:

toml
[general]
auto_update = true # Automatically check for updates on startup
show_status = true # Show plugin status indicators
Contributing
We welcome contributions from the community! Whether it's bug reports, feature requests, or code improvements, your input is valuable.

How to Contribute
Fork the repository.
Create a new branch (git checkout -b feature/your-feature-name).
Commit your changes (git commit -am 'Add some feature').
Push to the branch (git push origin feature/your-feature-name).
Open a pull request.
Code Style
Please follow the existing code style and ensure your code passes all tests before submitting a PR.

License
This project is licensed under the MIT License - see the LICENSE file for details.

Acknowledgments
Thanks to the Yazi team for creating such a powerful file manager.
Special thanks to all contributors who have helped improve this plugin manager.
