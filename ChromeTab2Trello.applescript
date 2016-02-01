on log_err(message)
  -- display notification message
  log message
end log_err

on run
	set the standard_characters to "abcdefghijklmnopqrstuvwxyz0123456789 " -- shortcut to filter out characters that wont survive

	try
    tell application "Google Chrome"
        set thePage to URL of active tab of first window
        set theName to name of active tab of first window
    end tell
	on error errmsg
    my log_err("Could not get current tab: " & errmsg)
	end try

  -- get the list ID from trello
  try
    tell script "TrelloLibrary"
      set listId to getListId()
    end tell
	on error errmsg
	  my log_err("Could not get list ID: " & errmsg)
  end try

  -- Post the Trello card now
	try
    -- XXX Would like to remove anything after " -" in the name
    set itemName to "Review " & theName
    set itemDesc to "URL: " & thePage

    try
      tell script "TrelloLibrary"
        set curlOutput to postCard(listId, itemName, itemDesc)
      end tell
    on error errmsg
      my log_err("Could not get list ID: " & errmsg)
    end try
	on error errmsg
	  my log_err("Could not post card: " & errmsg)
	end try

  try
    tell application "JSON Helper"
      set jsonString to read JSON from curlOutput 
      set outputURL to shortUrl of jsonString
      display notification "At " & outputURL with title "Saved '" & theName & "'"
      delay 1 --> allow time for the notification to trigger
    end tell
	on error errmsg
		my log_err("Could not not process info: " & errmsg)
	end try
    
-- Disabled because I found this annoying, but it opens the new task in Chrome
--   try
--     tell application "Google Chrome"
--     	activate
--     	if (count every window) = 0 then
--     		make new window
--     	end if
--     	tell window 1 to make new tab with properties {URL:outputURL}
--     end tell
-- 	on error errmsg
-- 		tell application "Finder" to display dialog "Could not open URL: " & errmsg
-- 	end try
end run
