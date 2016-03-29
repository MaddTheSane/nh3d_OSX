tell application "Finder"
	set current_path to container of (path to me) as text
	set stuff to (current_path & "nh3dSounds") as alias
	set stuff to stuff as text
	set NewPlace to (choose folder with prompt "Dest Folder?") as text
	set NewPlace to (reverse of rest of reverse of characters of NewPlace) as string --lose the ":"
	set TheList to list folder stuff without invisibles
	repeat with ThisOne in TheList
		duplicate item (stuff & ThisOne) to NewPlace
	end repeat
end tell

