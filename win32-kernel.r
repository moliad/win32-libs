REBOL [
	; -- Core Header attributes --
	title: "Win32 system platform development."
	file: %win32-kernel.r
	version: 1.0.1
	date: 2016-09-16
	author: "Maxim Olivier-Adlhoch"
	purpose: "stubs for kernel32.dll"
	web: http://www.revault.org/modules/win32-kernel.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'win32-kernel
	slim-version: 1.2.7
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
	sys-lib:	slim/open/expose 'utils-syslib none [struct-array struct-address? address-to-string get-memory ]

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
	
	;--------------------------
	;-         wideCharsBeyondRange?:
	;
	; this is set globally by the fromWideString() function to tell us if it had any issues.
	;
	; if you check this value just after calling fromWideString, it will be none when all is ok,
	; and true if it had issues with the conversion.
	;--------------------------
	wideCharsBeyondRange?: none
	
	;--------------------------
	;-     display-extended-error-in-console?:
	;
	; set to true if you wish to see more details in some functions,
	;
	; note that this may FORCE the console to open even if vprint is set to OFF!
	;
	; you should only use this in console-minded applications (as you cannot close it after,
	; which is annoying in GUI apps)
	;--------------------------
	display-extended-error-in-console?: false
	
	
	


	;-     FourGB:
	FourGB:	(power 2 32)

	;-     TwoGB:
	TwoGB:	(power 2 31)
	
	


	
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
	
	
	MAX_PATH:	260  ; (allows for 256 chars + C:\ + NUL,  where C: can be any drive letter)
	
	
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
	
	
	;-----
	; file attributes: ( https://msdn.microsoft.com/en-us/library/windows/desktop/gg258117(v=vs.85).aspx )
	FILE_ATTRIBUTE_NORMAL:  	128				; A file that does not have other attributes set. This attribute is valid only when used alone.
	FILE_ATTRIBUTE_ARCHIVE: 	32				; A file or directory that is an archive file or directory. Applications typically use this attribute to mark files for backup or removal . 
	FILE_ATTRIBUTE_COMPRESSED:	2048			; A file or directory that is compressed. For a file, all of the data in the file is compressed. For a directory, compression is the default for newly created files and subdirectories.
	FILE_ATTRIBUTE_DEVICE: 		64				; This value is reserved for system use.
	FILE_ATTRIBUTE_DIRECTORY:	16				; The handle that identifies a directory.
	FILE_ATTRIBUTE_ENCRYPTED:	16384			; A file or directory that is encrypted. For a file, all data streams in the file are encrypted. For a directory, encryption is the default for newly created files and subdirectories.
	FILE_ATTRIBUTE_HIDDEN:		2				; The file or directory is hidden. It is not included in an ordinary directory listing.
	FILE_ATTRIBUTE_NOT_CONTENT_INDEXED: 8192	; The file or directory is not to be indexed by the content indexing service.
	FILE_ATTRIBUTE_READONLY:			1		; A file that is read-only. Applications can read the file, but cannot write to it or delete it. This attribute is not honored on directories. 
	FILE_ATTRIBUTE_REPARSE_POINT:		1024	; A file or directory that has an associated reparse point, or a file that is a symbolic link.
	FILE_ATTRIBUTE_SPARSE_FILE:			512		; A file that is a sparse file.
	FILE_ATTRIBUTE_SYSTEM:				4		; A file or directory that the operating system uses a part of, or uses exclusively.
	FILE_ATTRIBUTE_TEMPORARY:			256		; A file that is being used for temporary storage. File systems avoid writing data back to mass storage if sufficient cache memory is available, because typically, an application deletes a temporary file after the handle is closed. In that scenario, the system can entirely avoid writing the data. Otherwise, the data is written after the handle is closed.
	FILE_ATTRIBUTE_VIRTUAL:				65536	; This value is reserved for system use.
	
	
	
	
	
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
	
	;--------------------------------------
	;-      -codepage encodings
	;--------------------------------------
	; see https://msdn.microsoft.com/en-us/library/dd317756(v=vs.85).aspx for specific encodings
	;---
	CP_ACP:			0 		; The system default Windows ANSI code page
	CP_OEMCP:		1		; default to OEM  code page
	CP_MACCP:		2		; default to MAC  code page
	CP_THREAD_ACP:	3		; current thread's ANSI code page
	CP_SYMBOL:		42		; SYMBOL translations
	CP_UTF7:		65000	; UTF-7 translation
	CP_UTF8:		65001	; UTF-8 translation
	


	



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
	;-     -used for various file attribute ops
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
	
	
	
	;-     WIN32_FIND_DATA [...]
	; used for directory listing and file browsing. (yeah, real good name!)
	; (sizeof: 318)
	WIN32_FIND_DATA: compose [
  		FileAttributes [integer!]
		; FILETIME
			CreationTime.low [integer!]
			CreationTime.high [integer!]
		; FILETIME
			LastAccessTime.low [integer!]
			LastAccessTime.high [integer!]
		; FILETIME
			LastWriteTime.low [integer!]
			LastWriteTime.high [integer!]
		Size.High 	[integer!]
		Size.Low 	[integer!]
		
		Reserved0 	[integer!]
		Reserved1 	[integer!]
		
		; we need the following, only to get proper space.  we'll actually use utils-syslib to load the string later.
		; the (rebol) struct-relative memory offset of this is: 45
		(struct-array 'Fname char! MAX_PATH)
		
		; the (rebol) struct-relative memory offset of this is: 305
		(struct-array 'AltFname char! 14)
	] none

	WIN32_FIND_DATA_W: compose [
  		FileAttributes [integer!]
		; FILETIME
			CreationTime.low [integer!]
			CreationTime.high [integer!]
		; FILETIME
			LastAccessTime.low [integer!]
			LastAccessTime.high [integer!]
		; FILETIME
			LastWriteTime.low [integer!]
			LastWriteTime.high [integer!]
		Size.High 	[integer!]
		Size.Low 	[integer!]
		
		Reserved0 	[integer!]
		Reserved1 	[integer!]
		
		; we need the following, only to get proper space.  we'll actually use utils-syslib to load the string later.
		; the (rebol) struct-relative memory offset of this is: 45
		(struct-array 'Fname char! (MAX_PATH * 2 ) ); wide chars are two bytes (* 2)
		
		; the (rebol) struct-relative memory offset of this is: 305
		(struct-array 'AltFname char!     14 * 2 ) ; wide chars are two bytes (* 2)
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
	;- DE-STRUCT SPECS
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
	;- STRING ENCODING ROUTINES
	;
	;-----------------------------------------------------------------------------------------------------------


	;--------------------------
	;-     MultiByteToWideChar()
	;--------------------------
	MultiByteToWideChar: make routine! [
		CodePage		[integer!]
		dwFlags			[integer!]
		lpMultiByteStr	[string!]	; Pointer to the character string to convert.
		cbMultiByte		[integer!]	; Size, in bytes, of the string indicated by the lpMultiByteStr parameter
		lpWideCharStr	[string!]	; Pointer to a buffer that receives the converted string
		cchWideChar		[integer!]	; Size, in characters, of the buffer indicated by lpWideCharStr. If this value is 0, the function returns the required buffer size, in characters, including any terminating null character, and makes no use of the lpWideCharStr buffer.
		
;		_In_      UINT   CodePage,
;		_In_      DWORD  dwFlags,
;		_In_      LPCSTR lpMultiByteStr,
;		_In_      int    cbMultiByte,
;		_Out_opt_ LPWSTR lpWideCharStr,
;		_In_      int    cchWideChar
		return: 		[integer!]
	] kernel32.dll "MultiByteToWideChar"


		
	;--------------------------
	;-     WideCharToMultiByte()
	;--------------------------
	; defines for this method:
	WC_NO_BEST_FIT_CHARS:	to-integer #{00000400}
	WC_ERR_INVALID_CHARS:	to-integer #{00000080}
	WC_DEFAULTCHAR:			to-integer #{00000040}
	
	WideCharToMultiByte: make routine! [
		CodePage		[integer!]	; usually use CP_ACP
		dwFlags			[integer!]
		lpWideCharStr	[string!]	; Pointer to a buffer that receives the converted string
		cchWideChar		[integer!]	; Size, in characters, of the buffer indicated by lpWideCharStr. If this value is 0, the function returns the required buffer size, in characters, including any terminating null character, and makes no use of the lpWideCharStr buffer.
		lpMultiByteStr	[string!]	; Pointer to the character string to convert.
		cbMultiByte		[integer!]	; Size, in bytes, of the string indicated by the lpMultiByteStr parameter
		
		lpDefaultChar		[string!]	; string (char) to use for defaults chars, when a wide character doesn't fit in codepage.
 		lpUsedDefaultChar	[string!]   ; when set, will become true if some chars where replaced by default char.
  
		return: 			[integer!]  ; size of converted buffer
	] kernel32.dll "WideCharToMultiByte"
	
	
	;--------------------------
	;-     toWideString()
	;--------------------------
	; purpose:  takes a normal rebol string and converts it to a Wide char encoded string.
	;
	; inputs:   /terminate : Adds a wide char NULL termination!!
	;
	; notes:    -Adds a wide char NULL termination!!
	;--------------------------
	toWideString: funcl [
		str [string!]
		/terminate "Adds a wide char NULL termination (two nul bytes), this is useful for many C functions which expect NULL terminated strings!!"
	][
		;vin "toWideString()"
		len: (length? str)
		if terminate [
			len: len + 1
		]
		size:  MultiByteToWideChar 0 0  str len "" 0 
		;v?? size
		rval: head insert/dup  copy ""  "^@^@"  size
		fsize: MultiByteToWideChar 0 0  str len rval ( size  )
		;v?? fsize
		;vout
		rval
	]
	
	
	;--------------------------
	;-     fromWideString()
	;--------------------------
	; purpose:  take a wide string and returns a normal rebol string.
	;--------------------------
	fromWideString: funcl [
		str [string! binary!]
		/default defchar [char!]
		/extern wideCharsBeyondRange?
	][
		;vin "fromWideString()"
		
		wideCharsBeyondRange?: none  ; all good by default.
		
		;v?? str
		defchar: any [
			defchar
			#"?"
		]
		
		size: ( length? str)
		chars: (size - 1) / 2 + 1
		;v?? size
		;v?? chars
		rval: head insert/dup copy "" "^@" chars
		;v?? rval
		defchar: to-string defchar
		
		WideCharToMultiByte 0 0 str (size / 2) rval chars defchar default-used?: copy #{00000000}
		;v?? rval
		
		if default-used? <> #{00000000} [
			vprobe "fromWideString(): some characters coudn't be mapped to default windows encoding"
			wideCharsBeyondRange?: true
		]
		
		;vout
		rval
	]
	
	
	;--------------------------
	;-     copyWideStr()
	;--------------------------
	; purpose:  given a string! or binary! memory block, copies the string UP TO the first wide NULL character it finds.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    -Will properly detect the wide null character based on memory alignment
	;           -if no NULL termination is found, we return the whole buffer.
	;			-ALWAYS copies the input buffer, even if we find no NULL termination.
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	copyWideStr: funcl [
		buffer [string! binary!]
		/terminate "Include the NULL termination in result"
	][
		;vin "copyWideStr()"
		substr: none
		buffer: as-binary buffer
		length? buffer
		until [
			all [
				substr: find buffer #{0000}
				buffer: next substr ; this offsets the next search in case we aren't properly mem aligned.
				odd? index? substr  ; remember rebol is 1-based indexed, so the ODD index? are the first chars of a wide char.
				substr: copy/part head buffer substr
				break
			]
		
			none? substr
		]
		if terminate [
			append substr #{0000}
		]
		rval: any [
			substr
			copy head buffer
		]
		if terminate [
			append rval #{0000}
		]
		;v?? rval
		;vout
		rval
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
		return: [integer!]             ; 0 if there is an error (use get-last-error)
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
		return:						[integer!] ; returns a file handle
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



	;---
	; these are used for file lists.
	;---

	;--------------------------
	;-     FindFirstFile()
	;
	; Searches a directory for a file or subdirectory with a name that matches a specific name (or partial name if wildcards are used).
	;--------------------------
	FindFirstFile: make routine! compose/deep/only [
		lpFileName			[string!]						; MUST INCLUDE "*.*" as part of path !!
		lpFindFileData		[struct! (WIN32_FIND_DATA)]		; A struct which will have all file information filled up by function.
		return:				[integer!] 						; returns a file handle (hFindFile)
	] kernel32.dll "FindFirstFileA"
	
	
	;--------------------------
	;-     FindFirstFileWide()
	;
	; Searches a directory for a file or subdirectory with a name that matches a specific name (or partial name if wildcards are used).
	;--------------------------
	FindFirstFileWide: make routine! compose/deep/only [
		lpFileName			[string!]						; MUST INCLUDE "*.*" as part of path !!
		lpFindFileData		[struct! (WIN32_FIND_DATA_W)]		; A struct which will have all file information filled up by function.
		return:				[integer!] 						; returns a file handle (hFindFile)
	] kernel32.dll "FindFirstFileW"
	
	
	;--------------------------
	;-     FindNextFile()
	;
	; Searches a directory for a file or subdirectory with a name that matches a specific name (or partial name if wildcards are used).
	;--------------------------
	FindNextFile: make routine! compose/deep/only [
		hFindFile			[integer!]						; The file search handle
		lpFindFileData		[struct! (WIN32_FIND_DATA)]		; A struct which will have all file information filled up by function.
		return:				[integer!] 						; returns a file handle
	] kernel32.dll "FindNextFileA"
	
	
	;--------------------------
	;-     FindNextFileWide()
	;
	; Searches a directory for a file or subdirectory with a name that matches a specific name (or partial name if wildcards are used).
	;--------------------------
	FindNextFileWide: make routine! compose/deep/only [
		hFindFile			[integer!]						; The file search handle
		lpFindFileData		[struct! (WIN32_FIND_DATA_W)]		; A struct which will have all file information filled up by function.
		return:				[integer!] 						; returns a file handle
	] kernel32.dll "FindNextFileW"
	
	
	;--------------------------
	;-     FindClose()
	;
	; Searches a directory for a file or subdirectory with a name that matches a specific name (or partial name if wildcards are used).
	;--------------------------
	FindClose: make routine! compose/deep/only [
		hFindFile			[integer!]						; The file search handle
		return:				[integer!] 						; If the function fails, the return value is zero. To get extended error information, call GetLastError.
	] kernel32.dll "FindClose"
	


	
	
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
	;-     win32-file-info()
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
	win32-file-info: funcl [
		path [file!]
	][
		;vin "win32-file-info()"
		handle: createFile  to-local-file path  FILE_ACCESS_META  FILE_SHARE_ALL  NULL  FILE_OPEN_EXISTING  FILE_ATTRIBUTE_NORMAL  NULL
		
		either handle = INVALID_HANDLE_VALUE [
			to-error rejoin ["ERROR! win32-file-info(): unable to open file win32 handle for : " to-local-file path ]
		][
			info: (make struct! BY_HANDLE_FILE_INFORMATION none)
			
			result: GetFileInformationByHandle handle info
			CloseHandle handle
			
			v?? info
			
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
					rval/created/zone: rval/created - rval/created-utc
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
					rval/accessed/zone: rval/accessed - rval/accessed-utc
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
					rval/changed/zone: rval/changed - rval/changed-utc
				]
			]
		]
		;vout
		rval
	]


	;--------------------------
	;-     fileFromFindStruct()
	;--------------------------
	; purpose:  return the filename from hFindFile
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
	fileFromFindStruct: funcl [
		handle [struct!]
	][
		;vin "fileFromFindStruct()"
		
		addr: struct-address? handle
		fname-addr: addr + 44
		fname: address-to-string fname-addr
		
		;vout
		fname
	]


	;--------------------------
	;-     fileFromFindStructWide()
	;--------------------------
	; purpose:  return the filename from within WIN32_FIND_DATA_W
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
	fileFromFindStructWide: funcl [
		handle [struct!]
	][
		;vin "fileFromFindStructWide()"
		
		addr: struct-address? handle
		fname-addr: addr + 44
		fname: get-memory fname-addr (MAX_PATH * 2)  ; * because these are wide chars
		
		;v?? fname
		fname: copyWideStr fname
		
		;vout
		fname
	]



	;--------------------------
	;-     win32-list-folder()
	;--------------------------
	; purpose:  low-level folder list
	;
	; inputs:   file path to browse
	;			/details  also include file details within a grid (no inner blocks)
	;
	; returns:  a block! when all is good, an error otherwise
	;
	; notes:    - None transparent, a none input is not an error, IT RETURNS NONE!
	;           - We try not to crash.  if we can't get file info we just fill block with none values.
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	win32-list-folder: funcl [
		path [file! none!]
		/details "will add many extra details in the result, like a grid. each file is a block of data."
		/recursive "enter subdirs"
		;/depth "do not go deeper than this number of subfolders"
		/dirs "also list directories in result"
		;/rootpath rpath [file!] "used with rootpath to remember the"
		/absolute "return absolute paths"
		/into intoblk [block!] "Give the block in which we accumulate all file data. use internally by /recursive"
		/ospath "Write all filepaths in OS local format."
		/opt options [block!] "alternate for refinements"
	][
		vin "win32-list-folder()"
		
		if file? path [
			; make sure given file exists, and is a folder!
			unless dir? path [
				vout
				to-error "win32-list-folder(): invalid path, doesn't exist or is not a folder."
			]
			
			
			;--------------------------------------------
			;-      setup options
			;--------------------------------------------
			if opt [
				details: any [ details ]
			]		
			
			srchpath: join path "*.*"
			srchpath: to-local-file srchpath
			
			;v?? path
			; create struct in memory for callbacks
			fdata: make struct! WIN32_FIND_DATA none

			; get handle to folder node
			handle: FindFirstFile srchpath fdata
			
			if handle = INVALID_HANDLE_VALUE [
				vout
				to-error rejoin[ "win32-list-folder(): unable to open folder ." path]
			]
				
			rval: any [
				intoblk
				copy []
			]
			until [
				subpath: fileFromFindStruct fdata
				;v?? path
				
				;----
				; iterate on each file in folder
				; skip "." and ".." paths
				unless any [
					subpath = "."
					subpath = ".."
				][
					v?? subpath
					either folder?: 0 <> (fdata/FileAttributes AND FILE_ATTRIBUTE_DIRECTORY) [
						append subpath #"/"
						subpath: to-file subpath
						
						if absolute [
							subpath: join path subpath
						]
						
						;--------------------------------------------
						;-      FOLDER
						;--------------------------------------------
						; we don't list folders by default
						
						if dirs [
							either ospath [
								append rval to-local-file 
							][
								append rval to-file subpath
							]
	
							if details [
								append rval [#[none] #[none] #[none] ] ; size,  date, utcDate
							]
						]

						if recursive [
						
						]
						
						
					][
						;--------------------------------------------
						;-      FILE
						;--------------------------------------------
						append rval to-file subpath

						if details [
							
							;---- manage size
							either any [
								fdata/size.high > 0 
								fdata/size.low < 0
							][
								size:	  (FourGB * fdata/size.high) 
											+ ( TwoGB * (shift/logical fdata/size.low 31 ) ) 
											+ (fdata/size.low AND to-integer #{7FFFFFFF})
							][
								size: fdata/size.low
							]
							
							append rval size
							
							v?? size
							
							
							;---- manage various dates
							systime: 	make struct! SYSTEMTIME none
							tz-systime: make struct! SYSTEMTIME none
							
							; creation time 
							success?: FileTimeToSystemTime make struct! FILETIME reduce [fdata/CreationTime.low fdata/CreationTime.high ] systime
							if success? <> 0 [
								created-utc: make date! reduce [ systime/wYear systime/wMonth systime/wDay ]
								;rval/created-utc/time: make time! reduce [systime/wHour systime/wMinute   round/to (to-decimal rejoin ["" systime/wSecond "." systime/wMilliseconds]) 0.001]
								created-utc/time: make time! reduce [systime/wHour systime/wMinute   round/to (to-decimal rejoin ["" systime/wSecond "." systime/wMilliseconds]) 0.01]
								
								success?: SystemTimeToTzSpecificLocalTime 0 systime tz-systime
								if success? <> 0 [
									created: make date! reduce [ tz-systime/wYear tz-systime/wMonth tz-systime/wDay ]
									created/time: make time! reduce [tz-systime/wHour tz-systime/wMinute   round/to (to-decimal rejoin ["" tz-systime/wSecond "." tz-systime/wMilliseconds]) 0.01]
									created/zone: created/time - created-utc/time
								]
							]
							append rval created
							v?? created
							
							append rval created-utc
							v?? created-utc
						]
					]
				]
				
				0 = FindNextFile handle fdata 
			]	
			
			; in all cases
			; release folder
			
			FindClose handle
			
		]
	
		vout
		rval
	]








	;--------------------------
	;-      win32-Copyfile()
	;--------------------------
	; purpose:  platform agnostic version of file copy (using os path data).
	;
	; returns:  0 when all is good, != 0  on error.
	;--------------------------
	win32-Copyfile: funcl [
		src [string!]
		dst [string!]
		/overwrite
	][
		overwrite: either overwrite  [ 0 ][ 1 ]
		if (rval: CopyFile src dst overwrite) = 0 [
			err: get-last-error
			if display-extended-error-in-console? [
				?? src
				?? dst
			]
			to-error rejoin ["slim/win32-kernel.r/win32-Copyfile(): file copy (" err/code":"err/msg ")^/src:" src "^/dest:" dst]
		]
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

