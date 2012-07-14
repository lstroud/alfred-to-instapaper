set iconfile to "file:///Users/someuser/Documents/instapaper.png" --downloaded an instapaper icon
set authinfo to "'userid:password'" --need the single quotes if your username as an @

tell application "System Events"
	set growlIsRunning to (count of (every process whose bundle identifier is "com.Growl.GrowlHelperApp")) > 0
	if growlIsRunning then
		set allNotificationsList to {"Success", "Authentication Error", "Other Error"}
		set enabledNotificationsList to {"Success", "Authentication Error", "Other Error"}
		tell application id "com.Growl.GrowlHelperApp"
			register as application "Instapaper" all notifications allNotificationsList default notifications enabledNotificationsList icon of application "Alfred"
		end tell
	end if
end tell

tell application "System Events"
	set front_app to name of first application process whose frontmost is true
end tell

tell application "System Events"
	if front_app = "Safari" then
		tell application "Safari"
			set theurl to get URL of front document
			set thetitle to get name of front document
		end tell
		
	else if front_app = "Google Chrome" then
		tell application "Google Chrome"
			set theurl to get URL of active tab of first window
			set thetitle to get title of active tab of first window
		end tell
	else
		--default to safari, but notify me that it was a little strange
		if growlIsRunning then
			tell application id "com.Growl.GrowlHelperApp"
				notify with name Â
					"Other Error" title Â
					"Unrecognized App" description Â
					"Safari or Chrome were not your front most apps.  Selecting Safari as the URL source." application name "Instapaper"
			end tell
		end if
		tell application "Safari"
			set theurl to get URL of front document
			set thetitle to get name of front document
		end tell
	end if
end tell

set statuscode to do shell script "curl -s --user " & authinfo & " --data-urlencode url=" & theurl & " https://www.instapaper.com/api/add"

if growlIsRunning then
	tell application id "com.Growl.GrowlHelperApp"
		if statuscode = "201" then
			notify with name Â
				"Success" title Â
				"Instapaper" description Â
				"'" & thetitle & "' was sent to Instapaper successfully." application name Â
				"Instapaper" image from location iconfile
			
		else if statuscode = "400" then
			notify with name Â
				"Other Error" title Â
				"Instapaper " description Â
				"Error: bad request." application name Â
				"Instapaper" image from location iconfile
			
		else if statuscode = "403" then
			notify with name Â
				"Authentication Error" title Â
				"Instapaper " description Â
				"Error: authenticaion failed." application name Â
				"Instapaper" image from location iconfile
			
		else
			notify with name Â
				"Other Error" title Â
				"Instapaper " description Â
				"The article could not be saved." application name Â
				"Instapaper" image from location iconfile
		end if
	end tell
end if