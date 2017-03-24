REBOL [
	; -- Core Header attributes --
	title: "Win32 system platform development."
	file: %win32-shell.r
	version: 1.0.0
	date: 2015-05-25
	author: "Maxim Olivier-Adlhoch"
	purpose: "stubs for shell32.dll"
	web: http://www.revault.org/modules/win32-2015-05-25.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'win32-shell
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/win32-kernel.r

	; -- Licensing details  --
	copyright: "Copyright © 2015 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2015 Maxim Olivier-Adlhoch

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
		v1.0.0 - 2015-05-25
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
	shell32.dll: load/library %shell32.dll



	;--------------------------
	;-     SHFileOperation()
	;
	; the standard SHell oriented file manipulation function.
	;
	; by default this function pops up a 
	;--------------------------
	SHFileOperation: make routine! [
		lpFileName	[string!]    ; _In_ LPCTSTR lpFileName
		return: [integer!]        ; If the function fails, the return value is zero (0). To get extended error information, call GetLastError.
	] shell32.dll "SHFileOperationA"
	
	
	
;	typedef struct _SHFILEOPSTRUCT {
;	  HWND         hwnd;
;	  UINT         wFunc;
;	  PCZZTSTR     pFrom;
;	  PCZZTSTR     pTo;
;	  FILEOP_FLAGS fFlags;
;	  BOOL         fAnyOperationsAborted;
;	  LPVOID       hNameMappings;
;	  PCTSTR       lpszProgressTitle;
;	} SHFILEOPSTRUCT, *LPSHFILEOPSTRUCT;

	FO_MOVE:     0001
	FO_COPY:     0002
	FO_DELETE:   0003
	FO_RENAME:   0004

	SHFILEOPSTRUCT-spec: [
		hwnd  [integer!] ; A window handle to the dialog box to display information about the status of the file operation.
		wFunc [integer!] ; A value that indicates which operation to perform. One of the following values:
						; FO_COPY
						;    Copy the files specified in the pFrom member to the location specified in the pTo member.
						;
						; FO_DELETE
						;    Delete the files specified in pFrom.
						;
						; FO_MOVE
						;    Move the files specified in pFrom to the location specified in pTo.
						;
						; FO_RENAME
						;    Rename the file specified in pFrom. You cannot use this flag to rename multiple files with a single function call. Use FO_MOVE instead.
		pFrom [string!] ; double NULL terminated string 
		pTo   [string!] ; double NULL terminated string 
		fFlags [integer!]
		fAnyOperationsAborted [integer!]
		hNameMappings [integer!]
		lpszProgressTitle [string!] 
	]

]

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

