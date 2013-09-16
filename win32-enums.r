REBOL [
	; -- Core Header attributes --
	title: {Enums from Win32 api which aren't specifically in any of the other win32 api slim libs.}
	file: %win32-enums.r
	version: 1.0.0
	date: 2013-9-13
	author: "Maxim Olivier-Adlhoch"
	purpose: {A storage place for randomly collected win32 enum values.}
	web: http://www.revault.org/modules/win32-enums.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'win32-enums
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/win32-enums.r

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
	documentation: {
		This is the generic place to put win32 library enums for use in any rebol app.
		some other libs might deal in specific APIs.
	}
	;-  \ documentation
]



;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'win32-enums
;
;--------------------------------------

slim/register [
	
	;-----------------------------------------------------------------------------------------------------------
	;
	;- LIBS
	;
	;-----------------------------------------------------------------------------------------------------------
	slim/open/expose 'win32-core none [int]
	

	;-----------------------------------------------------------------------------------------------------------
	;
	;- ERROR and dialog management for WIN32
	;
	;-----------------------------------------------------------------------------------------------------------

	
	error-codes: context [
		ERROR_ACCESS_DENIED: 	int #{00000005}
		
	]
		
		
	CSIDL: context [
		DESKTOPDIRECTORY:		int #{00000010}
		COMMON_APPDATA:			int #{00000023}
	]		
	
	
	SHGFP: context [
		SHGFP_TYPE_CURRENT:				0
	]		
		
		
	FORMAT_MESSAGE: context [
		FROM_SYSTEM:	    int #{00001000}
		IGNORE_INSERTS:  	int #{00000200}
	]
	
	
	SYSTEM_ERRORS: reduce [
		int #{8000FFFF}	"Unexpected failure"
		int #{80004001}	"Not implemented"
		int #{8007000E}	"Failed to allocate necessary memory"
		int #{80070057}	"One or more arguments are invalid"
		int #{80004002}	"No such interface supported"
		int #{80004003}	"Invalid pointer"
		int #{80070006}	"Invalid handle"
		int #{80004004}	"Operation aborted"
		int #{80004005}	"Unspecified failure"
		int #{80070005}	"General access denied error"
	]
]

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

