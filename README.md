# FHM

FHM is an addon for World of Warcraft designed to assit players on the four horsemen boss in naxxramas. This addon is compatible with Wow 1.12 (vanilla and vanilla+).

### Features

    Feature 1: Select the strat applied by your guild , your role and attribution
    Feature 2: Display during the fight where you should be.

### Installation
Method 1: Github Addon manager

    Open the Github Addon manager app.
    Add a new addon
    Paste the git url
    Click “Install”
    you can see more at https://turtle-wow.fandom.com/wiki/Addons
    in the following section:
    How to Install Addons


Method 2: Manual

    Download the latest version of FHM from GitHub or CurseForge.
    Extract the folder into World of Warcraft/_retail_/Interface/AddOns/.
    Ensure the folder name is FHM.
    Restart World of Warcraft, then enable the addon in the addon manager.

### Usage

Once installed and enabled, FHM should function automatically. Here are some useful commands and options:

    /fhm: Opens the addon's configuration window.
    /fhm help: Lists all available commands.
    /fhm config: Opens the addon's configuration window.
    /fhm enable : disable the functionnalities of the addon.
    /fhm disable : enable the functionnalities of the addon.
    /fhm reset : reset frame position and values.
    /fhm stop : stop current fight and frame and values. Do not reset frame position
    /fhm test : after configuring with /fhm or /fhm config, this will simulate a start of a fight with the 4 horsemen

The M means movable and U means unmovable on the top right button of the frame.

If you are a DPS , put 1 in the attrib number. For tanks and healers, raid leader should check the excel in this repo to attrib you the number.

### Configuration

The addon includes a configuration interface accessible via the options menu (or the /youraddon command). Here, you can customize settings such as:

    Enable/disable notifications
    Change alert colors
    Set custom keybindings for addon features

### Contribution

Contributions are welcome! Here’s how to help with the development:

    Fork this repository.
    Clone your fork locally: git clone https://github.com/NOo0B1/fhm.git.
    Create a branch for your feature or fix: git checkout -b my-new-feature.
    Make your changes, then commit them: git commit -m "Add new feature".
    Push to your fork: git push origin my-new-feature.
    Open a Pull Request in the main repository.

### Support and Feedback

This addon has been self made inspired by existing addons such as bigwigs lootres and a few others designed for turtle wow.

To report a bug, suggest an improvement, or get help, please use the Issues section on GitHub.

### License

This project is licensed under the MIT License. See the LICENSE file for more details.


### TODO list


- [x] Create addon
- [x] Put addon on github
- [x] Make the definition of the player role
- [x] Put a listener to catch four horsemen starting fight
- [x] better UI/UX
- [x] Put attributed strategy for tanks
- [x] Put attributed strategy for healers
- [x] Put attributed strategy for MDPS
- [x] Put attributed strategy for RDPS
- [x] Display a widow at the start of the fight the show a text of where the player is expected to be according to attributed strategy
- [x] Add a way to close the window
- [ ] Start mark 1 when mark 1 is detected and then start the count for 15 sec (but keep the 0.5 ongoing separatly)
- [ ] Implement a death detection and change strat accordingly
- [ ] Add a map that could track player position according to current situation or at least just pin point where/ what he should be doing


Enjoy and happy gaming!