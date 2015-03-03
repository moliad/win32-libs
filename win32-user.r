REBOL [
	; -- Core Header attributes --
	title: "Win32 user/logon functions."
	file: %win32-user.r
	version: 1.0.0
	date: 2013-9-13
	author: "Maxim Olivier-Adlhoch"
	purpose: "stubs for user32.dll windows funcs."
	web: http://www.revault.org/modules/win32-user.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'win32-user
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/win32-user.r

	; -- Licensing details  --
	copyright: "Copyright © 2013 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2013 Maxim Olivier-Adlhoch

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.}

	;-  / history
	history: {
		v1.0.0 - 2013-09-13
			-first public  release}
	;-  \ history

	;-  / documentation
	documentation: ""
	;-  \ documentation
]



slim/register [
	;-----------------------------------------------------------------------------------------------------------
	;
	;- LIBS
	;
	;-----------------------------------------------------------------------------------------------------------
	user32.dll: load/library %user32.dll

	
	;-----------------------------------------------------------------------------------------------------------
	;
	;- ALIASES
	;
	;-----------------------------------------------------------------------------------------------------------
	int: :to-integer

	
	;-----------------------------------------------------------------------------------------------------------
	;
	;- DEFINES
	;
	;-----------------------------------------------------------------------------------------------------------
	
	; http://msdn.microsoft.com/en-us/library/windows/desktop/ms645505.aspx
	
	;---
	; button setups
	MB_ABORTRETRYIGNORE:	int #{00000002}
	MB_CANCELTRYCONTINUE:	int #{00000006}
	MB_HELP: 				int #{00004000} ; not supported by rebol!
	MB_OK: 					int #{00000000}
	MB_OKCANCEL: 			int #{00000001}
	MB_RETRYCANCEL: 		int #{00000005}
	MB_YESNO: 				int #{00000004}
	MB_YESNOCANCEL: 		int #{00000003}
	
	;---
	; images
	MB_ICONEXCLAMATION: int #{00000030}
	MB_ICONWARNING: 	int #{00000030}
	MB_ICONINFORMATION: int #{00000040}
	MB_ICONASTERISK: 	int #{00000040}
	MB_ICONQUESTION: 	int #{00000020}
	MB_ICONSTOP: 		int #{00000010}
	MB_ICONERROR:		int #{00000010}
	MB_ICONHAND: 		int #{00000010}
	
	;---
	; default button
	MB_DEFBUTTON1: int #{00000000}
	MB_DEFBUTTON2: int #{00000100}
	MB_DEFBUTTON3: int #{00000200}
	MB_DEFBUTTON4: int #{00000300}

	;---
	; modality of the dialog box
	MB_APPLMODAL: 	int #{00000000}
	MB_SYSTEMMODAL: int #{00001000}
	MB_TASKMODAL: 	int #{00002000}
	
	
	;---
	; other options
	MB_DEFAULT_DESKTOP_ONLY:	int #{00020000}
	MB_RIGHT:	int #{00080000}
	MB_RTLREADING:	int #{00100000}
	MB_SETFOREGROUND:	int #{00010000}
	MB_TOPMOST:	int #{00040000}
	MB_SERVICE_NOTIFICATION:	int #{00200000}
	
	;---
	; return values
	IDABORT: 3
	IDCANCEL: 2
	IDCONTINUE: 11 
	IDIGNORE: 5
	IDNO: 7
	IDOK: 1
	IDRETRY: 4
	IDTRYAGAIN: 10
	IDYES: 6
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- STRUCTS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;-     RECT [ ... ]
	;--------------------------
	!RECT: [
		left	[integer!]
		top		[integer!]
		right	[integer!]
		bottom	[integer!]
	] 
	
	

	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- STUB ROUTINES
	;
	; (in alphabetical order)
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;-     FindWindow()
	;--------------------------
	FindWindow: make routine! [
		lpClassName  [integer!]   ; DO NOT USE (address of string of Windows Registered Class Name )
		lpWindowName [string!]    ; string of window title
		return:		 [integer!]   ; pointer to an HWnd
	] user32.dll "FindWindowA"
	
	;--------------------------
	;-     GetWindowRect()
	;--------------------------
	GetWindowRect: make routine! compose/only/deep [
		hWnd [integer!]
		lpRect [struct! (!RECT)]
	] user32.dll "GetWindowRect"
	
	;--------------------------
	;-     MessageBox()
	;--------------------------
	MessageBox: make routine! [
		hWnd		[integer!]
		lpText		[string!]
		lpCaption	[string!]
		uType		[integer!]
		return: 	[integer!]
	] user32.dll "MessageBoxA"
	
	;--------------------------
	;-     MoveWindow()
	;--------------------------
	MoveWindow: make routine! [
		hWnd		[integer!]
		x			[integer!]
		y			[integer!]
		w			[integer!]
		h			[integer!]
		repaint 	[integer!]
		return: 	[integer!]
	] user32.dll "MoveWindow"
	
	;--------------------------
	;-     SetWindowText()
	;--------------------------
	SetWindowText: make routine! [
		hWnd		[integer!]
		lpString	[string!]
		return: 	[integer!]
	] user32.dll "SetWindowTextA"
	
	
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- DIALOGS
	;
	;-----------------------------------------------------------------------------------------------------------
	

	;--------------------------
	;-     os-message()
	;--------------------------
	; purpose:  show a system-built message to the user
	;
	; returns:  nothing
	;--------------------------
	os-message: funcl [
		title [string!]
		msg [string!]
	][
		vin "os-message()"
		MessageBox 0 msg title MB_SETFOREGROUND
		vout
	]
	
	
	
	;--------------------------
	;-     os-alert()
	;--------------------------
	; purpose:  show a system-built alert to the user (single "OK" button)
	;
	; returns:  nothing
	;--------------------------
	os-alert: funcl [
		title [string!]
		msg [string!]
	][
		vin "os-alert()"
		MessageBox 0 msg title  ( MB_ICONWARNING or MB_SETFOREGROUND )
		vout
	]
	
	
	;--------------------------
	;-     os-confirm()
	;--------------------------
	; purpose:  show a system-built confim dialog
	;
	; inputs:   
	;
	; returns:  true or false
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	os-confirm: funcl [
		title
		msg
	][
		vin "os-confirm()"
		set [ rval err ] MessageBox 0 msg title  ( MB_OKCANCEL or MB_ICONEXCLAMATION or MB_SETFOREGROUND )
		vout
		
		(rval = 1)
	]
	


	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- WINDOW MANAGEMENT
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-         find-window()
	;--------------------------
	; purpose:  Gets a window handle (as a pointer)
	;
	; inputs:   window title name
	;
	; returns:  pointer required in many other win32 calls.
	;--------------------------
	find-window: funcl [
		[catch]
		window-name [string!]
	][
		vin "find-window()"
		;?? window-name
		handle: FindWindow 0 window-name
		;?? handle
		if handle = 0 [
			throw make error! rejoin [ {win32-user/find-window() no window named "} window-name {" found} ]
		]
		vout
		handle
	]
	
	;--------------------------
	;-         set-window-title()
	;--------------------------
	; purpose:  sets the title of a window directly via win32
	;
	; inputs:   a window handle, and new title text
	;
	; returns:  success as a logic!
	;
	; notes:    use find-window() to get the handle
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	set-window-title: funcl [
		[catch]
		hWnd [integer!]
		new-title  [string!]
	][
		vin "set-window-title()"
		; this protects agains GC
		tdata: make struct! [[save] str [string!] ] reduce [new-title]
		
		SetWindowText hWnd tdata/str
	
		vout
	]
	
	
	
	;--------------------------
	;-         get-window-rect()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  object with offset / size
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	get-window-rect: funcl [
		hWnd [integer!]
	][
		vin "get-window-rect()"
		GetWindowRect hWnd w-rect: make struct! !RECT none
		rect: context [
			offset: to-pair reduce [ w-rect/left  w-rect/top ]
			size:   to-pair reduce [ (w-rect/right - w-rect/left)  (w-rect/bottom -  w-rect/top)]
		]
		vout
		rect 
	]
	
	
	;--------------------------
	;-         move-window()
	;--------------------------
	; purpose:  move any window to a new position, keeping size.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	move-window: funcl [
		hWnd [integer!]
		pos [pair!]
		/size sz [pair!]
	][
		vin "move-window()"
		coords: get-window-rect hWnd
		;probe coords
		
		sz: any [
			sz
			coords/size
		]
		
		MoveWindow hWnd pos/x pos/y sz/x sz/y 1
		vout
	]
	
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- REBOL SPECIFIC APPLICATIONS OF WIN32 STUBS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	
	;--------------------------
	;-     setup-console()
	;--------------------------
	; purpose:  takes the console, if opened, and moves it... if it hasn't been renamed yet.
	;
	; inputs:   
	;
	; returns:  the console's hWnd, in case you want to manipulate it again.
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	setup-console: funcl [
		"Allows you to manipulate the console window"
		offset [pair!]
		size   [pair!]
		/title label [string!] "set console window's title title"
	][
		vin "setup-console()"
		hWnd: find-window "REBOL/View"
		move-window/size hWnd offset size

		if label [
			set-window-title hWnd label
		]
		vout
		hWnd
	]
	
	
	
	
]