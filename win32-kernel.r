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

	slim/open/expose 'utils-strings none [ make-mem-buffer ]
	slim/open/expose 'utils-codecs  none [ bit to-binary ]
	struct-lib: slim/open/expose 'utils-structs none [de-struct]


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


	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     TYPEDEFS
	;
	;-----------------------------------------------------------------------------------------------------------
	; Win32 typedefs
	;---
	BOOL: char!
	BOOLEAN: integer!


	;-----------------------------------------------------------------------------------------------------------
	;
	;- DEFINES
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;---
	; message formatint
	FORMAT_MESSAGE_FROM_SYSTEM:	    int #{00001000}
	FORMAT_MESSAGE_IGNORE_INSERTS:  int #{00000200}

	FILE_ACCESS_GENERIC_ALL:      bit 29
	FILE_ACCESS_GENERIC_EXECUTE:  bit 30
	FILE_ACCESS_GENERIC_WRITE:    bit 31
	FILE_ACCESS_GENERIC_READ:     bit 32
	FILE_ACCESS_META:             0       ; only allow access to some file information.
	
	FILE_SHARE_DELETE:	4
	FILE_SHARE_READ:	1
	FILE_SHARE_WRITE:	2
	FILE_SHARE_ALL:     FILE_SHARE_DELETE  OR  FILE_SHARE_READ  OR  FILE_SHARE_WRITE
	
	FILE_CREATE_ALWAYS:		2
	FILE_CREATE_NEW:		1
	FILE_OPEN_ALWAYS:		3
	FILE_OPEN_EXISTING:		4
	FILE_TRUNCATE_EXISTING:	5
	
	FILE_ATTRIBUTE_NORMAL:  128
	
	FILE_INFO_BY_HANDLE_CLASS: FIBHC: enum 'FIBHC [
		BasicInfo                   = 0
		StandardInfo                = 1
		NameInfo                    = 2
		RenameInfo                  = 3
		DispositionInfo             = 4
		AllocationInfo              = 5
		EndOfFileInfo               = 6
		StreamInfo                  = 7
		CompressionInfo             = 8
		AttributeTagInfo            = 9
		IdBothDirectoryInfo         = 10 ; // 0xA
		IdBothDirectoryRestartInfo  = 11 ; // 0xB
		IoPriorityHintInfo          = 12 ; // 0xC
		RemoteProtocolInfo          = 13 ; // 0xD
		FullDirectoryInfo           = 14 ; // 0xE
		FullDirectoryRestartInfo    = 15 ; // 0xF
		StorageInfo                 = 16 ; // 0x10
		AlignmentInfo               = 17 ; // 0x11
		IdInfo                      = 18 ; // 0x12
		IdExtdDirectoryInfo         = 19 ; // 0x13
		IdExtdDirectoryRestartInfo  = 20 ; // 0x14
		max-FIBHC	
	]
	
	
	
	
	INVALID_HANDLE_VALUE:           int #{ffffffff}
	
	NULL: 0

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
	;- STRUCT SPECS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;---
	;- used for various file attribute ops
	LARGE_INTEGER: [
		low		[integer!] ; note, the top bit has to be treated manually.
		high	[integer!] ; 
	]
	
	BY_HANDLE_FILE_INFORMATION: [
  		Attributes [integer!]
		; FILETIME
			CreationTime.low [integer!]
			CreationTime.high [integer!]
		; FILETIME
			LastAccessTime.low [integer!]
			LastAccessTime.high [integer!]
		; FILETIME
			LastWriteTime.low [integer!]
			LastWriteTime.high [integer!]
		VolumeSerialNumber [integer!]
		Size.High 	[integer!]
		Size.Low 	[integer!]
		NumberOfLinks	[integer!]
		uid.High	[integer!]
		uid.Low	[integer!]
	] none
	
	SYSTEMTIME: [
		wYear			[short]
		wMonth			[short]
		wDayOfWeek		[short]
		wDay			[short]
		wHour			[short]
		wMinute			[short]
		wSecond			[short]
		wMilliseconds	[short]
	]
	
	FILETIME: [
		low		[integer!] ; note, the top bit has to be treated manually.
		high	[integer!] ; 
	]

; 	; --- not used by any function atm
;	FILE_STANDARD_INFO:  [
;		AllocationSize [struct! [
;			low		[integer!] ; note: the top (sign) bit has to be treated manually. this is an unsigned value.
;			high	[integer!] ; 
;		]]
;		EndOfFile [ struct! [
;			low		[integer!] ; note: the top (sign) bit has to be treated manually. this is an unsigned value.
;			high	[integer!] ; 
;		]]
;		NumberOfLinks	[integer!]
;		DeletePending	[char!]
;		Directory		[char!]
;	] none
	


	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     DE-STRUCT SPECS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	_BY_HANDLE_FILE_INFORMATION: [
		DWORD    dwFileAttributes;
		FILETIME ftCreationTime;
		FILETIME ftLastAccessTime;
		FILETIME ftLastWriteTime;
		DWORD    dwVolumeSerialNumber;
		DWORD    nFileSizeHigh;
		DWORD    nFileSizeLow;
		DWORD    nNumberOfLinks;
		DWORD    nFileIndexHigh;
		DWORD    nFileIndexLow;
	]

		
	;-                                                                                                       .
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
	;-     CopyFile()
	;
	; Copies an existing file to a new file. (path is limited to 255 chars.)
	;--------------------------
	CopyFile: make routine! [
		lpExistingFileName	[string!]  ; _In_ LPCTSTR lpExistingFileName,
		lpNewFileName	[string!]      ; _In_ LPCTSTR lpNewFileName,
		bFailIfExists	[integer!]     ; If this parameter is TRUE and the new file specified by lpNewFileName already exists, 
		                               ; the function fails. 
		                               ;
		                               ; If this parameter is FALSE and the new file already exists, 
		                               ; the function overwrites the existing file and succeeds.
		return: [integer!]             
	] kernel32.dll "CopyFileA"
	
	
	;--------------------------
	;-     CreateFile()
	;
	; open a file, device or other resource to read write or access meta.  superseeds the OpenFile() function
	;--------------------------
	CreateFile: make routine! [
  		lpFileName 					[string!]  ; 
		dwDesiredAccess				[integer!] ; The requested access to the file or device, which can be summarized as read, write, both or neither (zero). when zero, you can still get some meta attributes
		dwShareMode					[integer!] ; The requested sharing mode of the file or device
		lpSecurityAttributes		[integer!] ; A pointer to a SECURITY_ATTRIBUTES structure ,   for most most purposes this can be null(0)
		dwCreationDisposition		[integer!] ; An action to take on a file or device that exists or does not exist.
		dwFlagsAndAttributes		[integer!] ; The file or device attributes and flags, FILE_ATTRIBUTE_NORMAL being the most common default value for files.
		hTemplateFile				[integer!] ; A valid handle to a template file with the GENERIC_READ access right. The template file supplies file attributes and extended attributes for the file that is being created.
		return:						[integer!] ; 
	] kernel32.dll "CreateFileA"

	
	;--------------------------
	;-     CloseHandle()
	;
	; open a file, device or other resource to read write or access meta.  superseeds the OpenFile() function
	;--------------------------
	CloseHandle: make routine! [
		hObject     [integer!] ; an opened handle
		return: 	[integer!]
	] kernel32.dll "CloseHandle"
	
	
	
	
	;--------------------------
	;-     DeleteFile()
	;
	; deletes a single file from the system, expecting a filename. (path is limited to 255 chars.)
	;--------------------------
	DeleteFile: make routine! [
		lpFileName	[string!]    ; _In_ LPCTSTR lpFileName
		return: [integer!]        ; If the function fails, the return value is zero (0). To get extended error information, call GetLastError.
	] kernel32.dll "DeleteFileA"
	
	
	;--------------------------
	;-     GetFileInformationByHandle()
	;
	; get the information about a file.
	;--------------------------
	GetFileInformationByHandle: make routine! compose/deep/only [
		hFile				[integer!]
		lpFileInformation	[struct! (BY_HANDLE_FILE_INFORMATION)]
		return: [char!]
	] kernel32.dll "GetFileInformationByHandle"
	
	;--------------------------
	;-     GetFileInformationByHandleBin()
	;
	; get the information about a file.
	;--------------------------
	GetFileInformationByHandleBin: make routine! compose/deep/only [
		hFile				[integer!]
		lpFileInformation	[string!] ; this is actually an allocated binary with enough space for all params.
		return: [char!]
	] kernel32.dll "GetFileInformationByHandle"
	
	
	;-                                                                                                       .
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
	
	
	
	;-                                                                                                       .
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


	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- SYSTEM TIME ROUTINES
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-     FileTimeToSystemTime()
	;--------------------------
	FileTimeToSystemTime: make routine! compose/deep/only [
		FileTime	[struct! (FILETIME)  ]
		SystemTime	[struct! (SYSTEMTIME)]
		return: 	[char!]
	] kernel32.dll "FileTimeToSystemTime"
	
	
	;--------------------------
	;-     SystemTimeToTzSpecificLocalTime()
	;--------------------------
	SystemTimeToTzSpecificLocalTime: make routine! compose/deep/only [
		lpTimeZone	[integer!] ; should always be NULL in this code. (no need to support complex tz specs.)
		utcTime		[struct! (SYSTEMTIME)]
		lclTime		[struct! (SYSTEMTIME)]
		return: 	[char!]
	] kernel32.dll "SystemTimeToTzSpecificLocalTime"
	
	
	;-                                                                                                       .
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
	

	;-                                                                                                       .
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
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- FILEOPS STUB FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-         win32-file-info()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    filesize may be integer or decimal, when it's decimal, it is larger than 2GB
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	FourGB:	(power 2 32)
	TwoGB:	(power 2 31)
	
	win32-file-info: funcl [
		path [file!]
	][
		;vin "win32-file-info()"
		handle: createFile  to-local-file path  FILE_ACCESS_META  FILE_SHARE_ALL  NULL  FILE_OPEN_EXISTING  FILE_ATTRIBUTE_NORMAL  NULL
		
		if handle <> INVALID_HANDLE_VALUE [
			info: (make struct! BY_HANDLE_FILE_INFORMATION none)
			
			result: GetFileInformationByHandle handle info
			CloseHandle handle
			
			rval: context [
				attributes:		none   ; will be a sub-object.
				size:			0     ; is a decimal! when > 2GB
				created-utc:	none
				created:		none
				accessed:		none
				accessed-utc:	none
				changed:		none
				changed-utc:	none
				volume-id:		none
				file-uid:		none ; can theoretically change at any moment.
				links:			1
			]

			;---- manage size
			either any [
				info/size.high > 0 
				info/size.low < 0
			][
				rval/size:	  (FourGB * info/size.high) 
							+ ( TwoGB * (shift/logical info/size.low 31 ) ) 
							+ (info/size.low AND to-integer #{7FFFFFFF})
			][
				rval/size: info/size.low
			]
			
			;---- manage various dates
			systime: 	make struct! SYSTEMTIME none
			tz-systime: make struct! SYSTEMTIME none
			
			; creation time 
			success?: FileTimeToSystemTime make struct! FILETIME reduce [info/CreationTime.low info/CreationTime.high ] systime
			if success? <> 0 [
				rval/created-utc: make date! reduce [ systime/wYear systime/wMonth systime/wDay ]
				;rval/created-utc/time: make time! reduce [systime/wHour systime/wMinute   round/to (to-decimal rejoin ["" systime/wSecond "." systime/wMilliseconds]) 0.001]
				rval/created-utc/time: make time! reduce [systime/wHour systime/wMinute   round/to (to-decimal rejoin ["" systime/wSecond "." systime/wMilliseconds]) 0.01]
				
				success?: SystemTimeToTzSpecificLocalTime 0 systime tz-systime
				if success? <> 0 [
					rval/created: make date! reduce [ tz-systime/wYear tz-systime/wMonth tz-systime/wDay ]
					rval/created/time: make time! reduce [tz-systime/wHour tz-systime/wMinute   round/to (to-decimal rejoin ["" tz-systime/wSecond "." tz-systime/wMilliseconds]) 0.01]
					rval/created/zone: rval/created/time - rval/created-utc/time
				]
			]
			
			; accessed time 
			success?: FileTimeToSystemTime make struct! FILETIME reduce [info/LastAccessTime.low info/LastAccessTime.high ] systime
			if success? <> 0 [
				rval/accessed-utc: make date! reduce [ systime/wYear systime/wMonth systime/wDay ]
				rval/accessed-utc/time: make time! reduce [systime/wHour systime/wMinute   round/to (to-decimal rejoin ["" systime/wSecond "." systime/wMilliseconds]) 0.01]
				
				success?: SystemTimeToTzSpecificLocalTime 0 systime tz-systime
				if success? <> 0 [
					rval/accessed: make date! reduce [ tz-systime/wYear tz-systime/wMonth tz-systime/wDay ]
					rval/accessed/time: make time! reduce [tz-systime/wHour tz-systime/wMinute   round/to (to-decimal rejoin ["" tz-systime/wSecond "." tz-systime/wMilliseconds]) 0.01]
					rval/accessed/zone: rval/accessed/time - rval/accessed-utc/time
				]
			]
			
			; changed time 
			success?: FileTimeToSystemTime make struct! FILETIME reduce [info/LastWriteTime.low info/LastWriteTime.high ] systime
			if success? <> 0 [
				rval/changed-utc: make date! reduce [ systime/wYear systime/wMonth systime/wDay ]
				rval/changed-utc/time: make time! reduce [systime/wHour systime/wMinute  round/to (to-decimal rejoin ["" systime/wSecond "." systime/wMilliseconds] ) 0.01 ]
				
				success?: SystemTimeToTzSpecificLocalTime 0 systime tz-systime
				if success? <> 0 [
					rval/changed: make date! reduce [ tz-systime/wYear tz-systime/wMonth tz-systime/wDay ]
					rval/changed/time: make time! reduce [tz-systime/wHour tz-systime/wMinute   round/to (to-decimal rejoin ["" tz-systime/wSecond "." tz-systime/wMilliseconds]) 0.01]
					rval/changed/zone: rval/changed/time - rval/changed-utc/time
				]
			]
		]
		;vout
		rval
	]


	;--------------------------
	;-         win32-Copyfile()
	;--------------------------
	; purpose:  platform agnostic version of file copy (using os path data).
	;--------------------------
	win32-Copyfile: funcl [
		src [string!]
		dst [string!]
	][
		CopyFile src dst 0
	]

	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- ROUTINE STUBS FUNCTIONS
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

