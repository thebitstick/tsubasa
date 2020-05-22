#!/usr/bin/env fish

# Tsubasa
# Script for sharing screenshots and/or status updates using [McKael/madonctl](https://github.com/McKael/madonctl)

set basename (basename (status -f))
set arg
set message
set verbosity 0
set fullname

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

if ! command -q notify-send
	echo "$basename: notify-send not found in PATH. optional, but needed for notifications"
end

if ! command -q xdg-user-dir
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
	set location (xdg-user-dir PICTURES)
	set sublocation "Tsubasa/"(date '+%Y-%m')
	set filename "screenshot-"(date '+%Y-%m-%d-%H-%M-%S')".png"
	set fullname "$location/Screenshots/$sublocation/$filename"

	if test ! -d $location
		check_verbosity "mkdir -p '$location'"
		mkdir -p "$location"
		echo "$basename: xdg pictures directory defined but doesn't exist. creating $location"
	end

	if test ! -d $location/Screenshots/$sublocation
		check_verbosity "mkdir -p '$location/Screenshots/$sublocation'"
		mkdir -p "$location/Screenshots/$sublocation"
		echo "$basename: tsubasa directory under xdg pictures directory doesn't exist. creating $location/Screenshots/$sublocation"
	end

	if test "$DISPLAY" = ""
		echo "$basename: no X or Wayland display detected"
		exit 1
	end

	if ! command -q gnome-screenshot
		echo "$basename: gnome-screenshot not found in PATH. needed for screenshots"
		exit 1
	end

	if test "$arg" = ""
		check_verbosity "gnome-screenshot --file='$fullname' --clipboard"
		gnome-screenshot --file="$fullname" --clipboard
	else
		check_verbosity "gnome-screenshot --$arg --file='$fullname' --clipboard"
		gnome-screenshot --"$arg" --file="$fullname" --clipboard
	end

	if test ! -f $fullname
		echo "$basename: file not saved"
		exit 1
	else
		if command -q notify-send
			check_verbosity "notify-send --icon='$fullname' --expire-time=5000 \
				'$basename: Screenshot Saved' 'Saved to $fullname'"
			notify-send --icon="$fullname" --expire-time=5000 \
				"$basename: Screenshot Saved" "Saved to $fullname"
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

check_verbosity "message=(zenity --title='Share to Fediverse' --ok-label=Send \
	--cancel-label=Cancel --text-info --editable --width=350 --height=250)"
zenity --title='Share to Fediverse' --ok-label=Send --cancel-label=Cancel \
	--text-info --editable --width=350 --height=250 | read -z message

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
	if command -q notify-send
		check_verbosity "notify-send --expire-time=5000 '$basename' 'Unable to post status'"
		notify-send --expire-time=5000 "$basename" "Unable to post status"
	end
	exit 1
else
	echo "$basename: status post successful"
	if command -q notify-send
		check_verbosity "notify-send --expire-time=5000 '$basename' 'Status Post Successful'"
		notify-send --expire-time=5000 "$basename" "Status Post Successful"
	end
end

exit 0
