

###############
# compiz scale
###############
gconftool-2 --set --type string /apps/compiz-1/plugins/scale/screen0/options/initiate_all_key "<Shift><Alt>F4"

###############
# gnomeをemacs風に
###############
gconftool-2 --set --type string /desktop/gnome/interface/gtk_key_theme "Emacs"

# ###############
# # emacs
# ###############
# gconftool-2 --set --type string /apps/metacity/keybinding_commands/command_1 "/usr/bin/wmctrl -a emacs@ || emacs23"
# gconftool-2 --set --type string /apps/metacity/global_keybindings/run_command_1 "<Shift><Control>F13"

# ###############
# # firefox
# ###############
# gconftool-2 --set --type string /apps/metacity/keybinding_commands/command_2 "/usr/bin/wmctrl -a firefox || firefox"
# gconftool-2 --set --type string /apps/metacity/global_keybindings/run_command_2 "<Shift><Control>F14"

# ###############
# # terminal
# ###############
# gconftool-2 --set --type string /apps/metacity/keybinding_commands/command_3 "/usr/bin/wmctrl -a Terminal || gnome-terminal"
# gconftool-2 --set --type string /apps/metacity/global_keybindings/run_command_3 "<Shift><Control>F15"

