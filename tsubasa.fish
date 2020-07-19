#!/usr/bin/env fish

# Tsubasa
# Script for sharing screenshots and/or status updates using [ihabunek/toot](https://github.com/ihabunek/toot)

set SWAY_ENABLED 0
set basename (basename (status -f))
set arg
set message
set verbosity 0
set fullname
set uname (uname)

function check_verbosity
	if test $verbosity -eq 1
		echo "$argv" 
	end
end

function usage
	echo "Usage:"
	echo "$basename [OPTION...] <command>"
	echo ""
	echo "Help Options:"
	echo "	-h,--help	Show help options"
	echo "	-v,--verbose	Print debug logging"
	echo ""
	echo "Application Commands:"
	echo "	nothing		(default) Saves a screenshot to the XDG Pictures directory and shares to Fediverse via toot"
	echo "	window		Saves a screenshot of the current window to the XDG Pictures directory and shares to Fediverse via toot"
	echo "	area		Saves a screenshot of a selected region to the XDG Pictures directory and shares to Fediverse via toot"
	echo "	text		Share a status update to Fediverse via toot"
	echo ""
end

if ! command -q toot
	echo "$basename: toot not found in PATH. needed to send status updates"
	exit 1
end

if ! command -q zenity
	echo "$basename: zenity not found in PATH. needed for gui dialog"
	exit 1
end

if ! command -q notify-send && test "$uname" != "Darwin"
	echo "$basename: notify-send not found in PATH. optional, but needed for notifications"
end

if ! command -q terminal-notifier && test "$uname" == "Darwin"
	echo "$basename: terminal-notifier not found in PATH. optional, but needed for notifications"
end

if ! command -q xdg-user-dir && test "$uname" != "Darwin"
	echo "$basename: freedesktop non-compliance detected"
	exit 2
end

for item in $argv
	switch $item
		case "-h" "--help"
			usage
			exit 0
		case "-v" "--verbose"
			set verbosity 1
		case '*'
			if test "$item" != "-v" || test "$item" != "--verbose"
				set arg $item
			end
	end
end

function screenshot
	if test "$uname" != "Darwin"
		set location (xdg-user-dir PICTURES)
	else
		if test "$DARWIN_PHOTOS" = ""
			echo "$basename: please set DARWIN_PHOTOS variable to desired save directory. example (/Volumes/Photos)"
			exit 3
		else
			set location $DARWIN_PHOTOS
		end
	end
	set sublocation "Tsubasa/"(date '+%Y-%m')
	set filename "screenshot-"(date '+%Y-%m-%d-%H-%M-%S')".png"
	set fullname "$location/Screenshots/$sublocation/$filename"

	if test ! -d $location
		check_verbosity "mkdir -p '$location'"
		mkdir -p "$location"
		echo "$basename: pictures directory defined but doesn't exist. creating $location"
	end

	if test ! -d $location/Screenshots/$sublocation
		check_verbosity "mkdir -p '$location/Screenshots/$sublocation'"
		mkdir -p "$location/Screenshots/$sublocation"
		echo "$basename: tsubasa directory under pictures directory doesn't exist. creating $location/Screenshots/$sublocation"
	end

	if test "$DISPLAY" = "" && test "$uname" != "Darwin"
		echo "$basename: no X or Wayland display detected"
		exit 1
	end

	if ! command -q screencapture && test "$uname" = "Darwin"
		echo "$basename: screencapture not found in PATH. needed for screenshots"
		exit 1
	end

	# GNOME/Sway are the only supported Linux desktops.
	# macOS is also supported.
	if test "$uname" != "Darwin"
		if test "$XDG_SESSION_DESKTOP" = "sway"
			set SWAY_ENABLED 1
			if ! command -q grimshot
				echo "$basename: grimshot not found in PATH. needed for screenshots"
				exit 1
			end
		else if ! command -q gnome-screenshot
			echo "$basename: gnome-screenshot not found in PATH. needed for screenshots"
			exit 1
		end

		if test "$arg" = "" && test "$SWAY_ENABLED" -eq 0
			check_verbosity "gnome-screenshot --file='$fullname'"
			gnome-screenshot --file="$fullname"
		else if test "$SWAY_ENABLED" -eq 0
			check_verbosity "gnome-screenshot --$arg --file='$fullname'"
			gnome-screenshot --"$arg" --file="$fullname"
		else if test "$arg" = "" && test "$SWAY_ENABLED" -eq 1
			check_verbosity "grimshot save screen '$fullname'"
			grimshot save screen "$fullname"
		else if test "$SWAY_ENABLED" -eq 1
			if test "$arg" = "window"
				check_verbosity "grimshot save win '$fullname'"
				grimshot save win "$fullname"
			else
				check_verbosity "grimshot save area '$fullname'"
				grimshot save area "$fullname"
			end
		end
	else if test "$uname" = "Darwin"
		if test "$arg" = ""
			check_verbosity "screencapture '$fullname'"
			screencapture "$fullname"
		else if test "$arg" = "window"
			check_verbosity "screencapture -w '$fullname'"
			screencapture -w "$fullname"
		else
			check_verbosity "screencapture -i '$fullname'"
			screencapture -i "$fullname"
		end
	end
	
	if test ! -f $fullname
		echo "$basename: file not saved"
		exit 1
	else
		if command -q notify-send && test "$uname" != "Darwin"
			check_verbosity "notify-send --icon='$fullname' --expire-time=5000 \
				'$basename: Screenshot Saved' 'Saved to $fullname'"
			notify-send --icon="$fullname" --expire-time=5000 \
				"$basename: Screenshot Saved" "Saved to $fullname"
		else if command -q terminal-notifier && test "$uname" = "Darwin"
			check_verbosity "terminal-notifier -title 'Tsubasa' -contentImage '$fullname' \
				-subtitle '$basename: Screenshot Saved' -message 'Saved to $fullname' \
				-group '$basename' -open '$fullname'"
			terminal-notifier -title "Tsubasa" -contentImage "$fullname" \
				-subtitle "$basename: Screenshot Saved" \
				-message "Saved to $fullname" -group "$basename" -open "file://$fullname"
		end
	end
end

if test "$arg" = ""
	screenshot
else if test "$arg" = "window" || test "$arg" = "area"
	screenshot "$arg"
else if test "$arg" != "text"
	echo "$basename: unknown command"
	usage
	exit 1
end

if test "$uname" != "Darwin"
	check_verbosity "message=(zenity --title='Share to Fediverse' --ok-label=Send \
		--cancel-label=Cancel --text-info --editable --width=350 --height=250)"
	zenity --title='Share to Fediverse' --ok-label=Send --cancel-label=Cancel \
		--text-info --editable --width=350 --height=250 | read -z message
else if test "$uname" = "Darwin"
	check_verbosity "message=(env GTK_THEME=Adwaita:dark zenity --title='Share to Fediverse' --ok-label=Send \
		--cancel-label=Cancel --text-info --editable --width=350 --height=250)"
	env GTK_THEME=Adwaita:dark zenity --title='Share to Fediverse' --ok-label=Send --cancel-label=Cancel \
		--text-info --editable --width=350 --height=250 | read -z message
end

if test $pipestatus[1] -eq 1
	echo "$basename: cancelled by user"
	exit 1
end

if test "$arg" = "" || test "$arg" = "window" || test "$arg" = "area"
	check_verbosity "toot post --media='$fullname' '$message'"
	echo $message | toot post --media="$fullname"
else
	check_verbosity "toot post '$message'"
	echo $message | toot post
end

if test $status -eq 1
	echo "$basename: unable to post status"
	if command -q notify-send && test "$uname" != "Darwin"
		check_verbosity "notify-send --expire-time=5000 '$basename' 'Unable to post status'"
		notify-send --expire-time=5000 "$basename" "Unable to post status"
	else if command -q terminal-notifier && test "$uname" = "Darwin"
		check_verbosity "terminal-notifier -title 'Tsubasa' \
			-message 'Unable to post status' -group '$basename'"
		terminal-notifier -title "Tsubasa" -message "Unable to post status" -group "$basename"
	end
	exit 1
else
	echo "$basename: status post successful"
	if command -q notify-send && test "$uname" != "Darwin"
		check_verbosity "notify-send --expire-time=5000 '$basename' 'Status Post Successful'"
		notify-send --expire-time=5000 "$basename" "Status Post Successful"
	else if command -q terminal-notifier && test "$uname" = "Darwin"
		check_verbosity "terminal-notifier -title 'Tsubasa' \
			-message 'Status Post Successful' -group '$basename'"
		terminal-notifier -title "Tsubasa" -message "Status Post Successful" -group "$basename"
	end
end

exit 0

