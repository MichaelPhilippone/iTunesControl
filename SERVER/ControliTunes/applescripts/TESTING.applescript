tell application "System Events" to set appCount to the count of (processes whose name is "iTunes")

if appCount = 0 then
	tell application "iTunes" to activate
end if

tell application "iTunes" to pause