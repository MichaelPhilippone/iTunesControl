tell application "System Events" to set appCount to the count of (processes whose name is "iTunes")

if appCount > 0 then
	tell application "iTunes"
		
		if player state is playing then
			set tk_track to current track			
			set tk_artist to (get artist of tk_track)
			set tk_title to (get name of tk_track)
			set tk_album to (get album of tk_track)
			set tk_position_RAW to (get player position)
			set tk_volume to (get sound volume) 
			set tk_progPercent to round ((((get player position) / (get duration of tk_track)) * 100)) as text
			
			set tid to AppleScript's text item delimiters
			set AppleScript's text item delimiters to "."
			set tk_duration to ((text item 1 of (((get duration of tk_track) / 60) as text)) as text) & ":" & ((text item 1 of (((get duration of tk_track) mod 60) as text)) as text)
			set tk_position to ((text item 1 of ((tk_position_RAW / 60) as text)) as text) & ":" & ((text item 1 of ((tk_position_RAW mod 60) as text)) as text)
			set AppleScript's text item delimiters to tid
			
			"{\"ARTIST\":\"" & tk_artist & "\" , \"TITLE\":\"" & tk_title & "\" , \"ALBUM\":\"" & tk_album & "\" , \"DURATION\":\"" & tk_duration & "\" , \"POSITION\":\"" & tk_position & "\" , \"VOLUME\":\"" & tk_volume & "\", \"PERCENT\":\"" & tk_progPercent & "\"}"
		end if		
	end tell
else
	"{\"ARTIST\":\"\" , \"TITLE\":\"\" , \"ALBUM\":\"\" , \"DURATION\":\"\" , \"POSITION\":\"\" , \"VOLUME\":\"\", \"PERCENT\":\"\"}"	
end if



