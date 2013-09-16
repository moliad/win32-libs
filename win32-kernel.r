REBOL [
	; -- Core Header attributes --
	title: "Win32 system platform development."
	file: %win32-kernel.r
	version: 1.0.0
	date: 2013-9-13
	author: "Maxim Olivier-Adlhoch"
	purpose: "stubs for kernel32.dll"
	web: http://www.revault.org/modules/win32-kernel.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'win32-kernel
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/win32-kernel.r

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
			-First public release
}
	;-  \ history

	;-  / documentation
	documentation: ""
	;-  \ documentation
]



;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'win32-kernel
;
;--------------------------------------

slim/register [
	;-----------------------------------------------------------------------------------------------------------
	;
	;- LIBS
	;
	;-----------------------------------------------------------------------------------------------------------
	kernel32.dll: load/library %kernel32.dll

	slim/open/expose 'utils-strings none [make-mem-buffer]


	;-----------------------------------------------------------------------------------------------------------
	;
	;- MODULE GLOBALS
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-     last-win32-error:
	;
	; this is set when get-last-error() is called.
	;--------------------------
	last-win32-error: none
	
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
	
	;---
	; message formatint
	FORMAT_MESSAGE_FROM_SYSTEM:	    int #{00001000}
	FORMAT_MESSAGE_IGNORE_INSERTS:  int #{00000200}

	;-----------------------------------------------------------------------------------------------------------
	;
	;- STRUCTS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	STARTUP_INFO_STRUCT: make struct! startup-info-spec: [
		cb 				[integer!]
		lpReserved 		[integer!]
		lpDesktop		[integer!]
		lpTitle			[integer!]
		dwX				[integer!]
		dwY				[integer!]
		dwXSize			[integer!]
		dwYSize			[integer!]
		dwXCountChars 	[integer!]
		dwYCountChars 	[integer!]
		dwFillAttribute	[integer!]
		dwFlags			[integer!]
		wShowWindow		[short]
		cbReserved2		[short]
		lpReserved2		[integer!]
		hStdInput		[integer!]
		hStdOutput		[integer!]
		hStdError		[integer!]
	] none
	
	PROCESS_INFORMATION_STRUCT: make struct! process-info-spec: [
		hProcess	[integer!]
		hThread 	[integer!]
		dwProcessID	[integer!]
		dwThreadID	[integer!]
	] none

	

	;-----------------------------------------------------------------------------------------------------------
	;
	;- FILE ROUTINES
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;-     GetCurrentDirectory()
	;--------------------------
	GetCurrentDirectory: make routine! [
		nBufferLength 	[integer!]
		lpBuffer		[string!]
		return: 		[integer!]
	] kernel32.dll "GetCurrentDirectoryA"
	

	;--------------------------
	;-     SetCurrentDirectory()
	;--------------------------
	SetCurrentDirectory: make routine! [
		lpPathName	[string!]
		return: 	[integer!]
	] kernel32.dll "SetCurrentDirectoryA"

	
	;--------------------------
	;-     CloseHandle()
	;--------------------------
	CloseHandle: make routine! [
		hObject	[integer!]
		return: [integer!]
	] kernel32.dll "CloseHandle"
	
	
	;-----------------------------------------------------------------------------------------------------------
	;
	;- ERROR MANAGEMENT ROUTINES
	;
	;-----------------------------------------------------------------------------------------------------------

	;--------------------------
	;-     GetLastError()
	;--------------------------
	GetLastError: make routine! [
		return: [integer!]
	] kernel32.dll "GetLastError"
	

	;--------------------------
	;-     SetLastError()
	;--------------------------
	SetLastError: make routine! [
		code: [integer!]
	;	return: [integer!]
	] kernel32.dll "SetLastError"
	

	;--------------------------
	;-     FormatMessage()
	;--------------------------
	FormatMessage: make routine! [
		dwFlags		 [integer!]
		lpSource	 [integer!]
		dwMessageId  [integer!]
		dwLanguageId [integer!]
		lpBuffer	 [string!]
		nSize		 [integer!]
		Arguments	 [integer!]
		return:		 [integer!]
	] kernel32.dll "FormatMessageA"
	
	
	
	;-----------------------------------------------------------------------------------------------------------
	;
	;- PROCESS MANAGEMENT ROUTINES
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-     CreateProcess()
	;--------------------------
	CreateProcess: make routine! compose/deep [
		lpApplicationName	 [integer!]
		lpCommandLine		 [string!]	
		lpProcessAttributes	 [struct! [a [integer!] b [integer!] c [integer!]]]
		lpThreadAttributes	 [struct! [a [integer!] b [integer!] c [integer!]]]
		bInheritHandles		 [char!]
		dwCreationFlags		 [integer!]
		lpEnvironment		 [integer!]
		lpCurrentDirectory	 [integer!]
		lpStartupInfo		 [struct! [(startup-info-spec)]]
		lpProcessInformation [struct! [(process-info-spec)]]
		return:				 [integer!]
	] kernel32.dll "CreateProcessA"


	;--------------------------
	;-     GetCommandLine()
	;--------------------------
	GetCommandLine: make routine! [
		return: [string!]
	] kernel32.dll "GetCommandLineA"
	
	
	;-----------------------------------------------------------------------------------------------------------
	;
	;- ENVIRONMENT ROUTINES
	;
	;-----------------------------------------------------------------------------------------------------------
	

	;--------------------------
	;-     _setenv()
	;--------------------------
	_setenv: make routine! [
		name	[string!]
		value	[string!]
		return: [integer!]
	] kernel32.dll "SetEnvironmentVariableA"
	

	;--------------------------
	;-     _getenv()
	;--------------------------
	_getenv: make routine! [
		lpName	 [string!]
		lpBuffer [string!]
		nSize	 [integer!]
		return:	 [integer!]
	] kernel32.dll "GetEnvironmentVariableA"
	

	;-----------------------------------------------------------------------------------------------------------
	;
	;- CLASSES
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-     !win32-error [...]
	;
	; the base win32 error we build.
	;--------------------------
	!win32-error: context [
		win32-error?: true
		code: 0
		msg: "Unknown win32 error"
	]
	
	


	;-----------------------------------------------------------------------------------------------------------
	;
	;- HELPER FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;-     get-last-error()
	;--------------------------
	; purpose:  using the last generated win32 error number, build the error message string, and return it
	;
	; inputs:   
	;
	; returns:  a !win32-error object  OR none, when win32's GetLastError returns 0
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	get-last-error: funcl [
		/extern last-win32-error
	][
		vin "get-last-error()"
		; we may be in a state where there is no error, in this case, we return none instead of an object.
		error: none
		last-win32-error: vprobe GetLastError ; when last-win32-error is 0,  DO [ win32-error? last-win32-error ]  will return false
		
		v?? last-win32-error
		
		; we really had an error message
		if last-win32-error <> 0 [
			out: get-error-string last-win32-error
			
			;----
			; build an error object for use with other funcs of this module
			error: make !win32-error [
				code: last-win32-error
				msg: copy out
			]
		]
		
		last-win32-error: error
		
		
		out: none
		
		
		vout/return
		error
	]
	
	
	
	;--------------------------
	;-     get-error-string()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	get-error-string: funcl [
		code [integer!]
	][
		vin "get-error-string()"
		v?? code
		out: make-mem-buffer 256
		FormatMessage ( FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS ) 0 code 0 out 256 0
		vout
		out
	]
	
	
	
	
	;--------------------------
	;-     do-win32()
	;--------------------------
	; purpose:  runs a single function, wrapping it within win32 a SetError and GetError pair
	;
	; inputs:   
	;
	; returns:  a pair of values: 
	;               a) The original return value (0 is converted to none)
	;               b) The error code, when it is generated .
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	do-win32: funcl [
		routine [routine!]
		args [block!]
	][
		vin "do-win32()"
		
		do compose [
			; SetLastError 0 ; this seems to crash windows randomly!
			rval: routine (args)
			err: GetLastError
		]
		
		if rval = 0 [
			rval: none
		]
		if err = 0 [
			err: none
		]
		
		vout
		reduce [rval err]
	]
	
	
	
	
	

	;--------------------------
	;-     win32-error?()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	win32-error?: funcl [
		data [any-type!]
	][
		all [
			object? get/any 'data ; survives unset! input
			
			#[true] = get in data 'win32-error?
			
			integer? get in data 'code
			in data 'msg
		]
	]
	
]

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

