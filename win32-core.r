REBOL [
	; -- Core Header attributes --
	title: "Win32 api re-usable tools"
	file: %win32-core.r
	version: 1.0.0
	date: 2013-9-13
	author: "Maxim Olivier-Adlhoch"
	purpose: "Core functionality for all other win32 libs."
	web: http://www.revault.org/modules/win32-core.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'win32-core
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/win32-core.r

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
; test-enter-slim 'win32-core
;
;--------------------------------------

slim/register [
	;-----------------------------------------------------------------------------------------------------------
	;
	;- HELPER FUNCS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	
	;--------------------------
	;-     int()
	;--------------------------
	; C-style type cast... shortcut for to-integer
	;--------------------------
	int: :to-integer


	
	;--------------------------
	;-     attempt-win32()
	;--------------------------
	; purpose:  execute a block of code, expecting a non-zero return value.
	;
	; inputs:   
	;
	; returns:  none when the win32 call returns 0.
	;
	; notes:    when we return none, there usually is an error waiting within  win32-kernel.r/get-last-error()
	;
	; tests:    
	;--------------------------
	attempt-win32: funcl [
		body [block!]
	][
		vin "attempt-win32()"
		
		
		vprobe body
		res: attempt body
		
		v?? res
		
		;---
		; a 0 result is an error, in our case, we substitute none for it.
		;
		; this is because 0 is a true value in REBOL
		if zero? res [
			res: none
		]
		
		vout
		
		res
	]
	
	
	
]

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

