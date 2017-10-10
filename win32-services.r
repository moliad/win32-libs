REBOL [
	Title:		"Win32 Service control manager (SCM) interface."
	version: 	1.0.0
	date:		2012-08-30 
	File:		%win32-services.r
	Author:		"Maxim Olivier-Adlhoch"
	Rights:		{Copyright ©2012, Maxim Olivier-Adlhoch.}

	slim-name: 'win32-services
	slim-version: 1.0.0
	
	
	
	license-type: 'MIT
	license:      {Copyright © 2012 Maxim Olivier-Adlhoch.

		Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
		and associated documentation files (the "Software"), to deal in the Software without restriction, 
		including without limitation the rights to use, copy, modify, merge, publish, distribute, 
		sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
		is furnished to do so, subject to the following conditions:
		
		The above copyright notice and this permission notice shall be included in all copies or 
		substantial portions of the Software.}
		
	disclaimer: {THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
		INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
		PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
		FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ]
		ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
		THE SOFTWARE.}
		
		
		
		
	notes: {
		This code uses fling so it expects you to have some level of catch installed.
	
		Fling use should be described in function headers.	
	}
		
]


slim/register [
	;-----------------------------------------------------------------------------------------------------------
	;
	;- LIBS
	;
	;-----------------------------------------------------------------------------------------------------------
	if not advapi32.dll: load/library %advapi32.dll [
		ask "ERROR MISSING LIBRARY! advapi32.dll"
	
	
	]

	slim/open/expose 'win32-core   none [ int attempt-win32 ]
	slim/open/expose 'win32-kernel none [  do-win32 get-last-error GetLastError SetLastError win32-error? get-error-string]
	user32: slim/open/expose 'win32-user none [os-alert os-message os-confirm]
	slim/open/expose 'utils-errors none [ fling ]
	
	;slim/open/expose 'utils [ get-application-title ]
	slim/open/expose 'utils-strings none [ make-mem-buffer ]
	slim/open/expose 'utils-script none [ get-application-title ]
	slim/open/expose 'win32-enums none [ec: error-codes]
	
	
	;-----------------------------------------------------------------------------------------------------------
	;
	;- MODULE GLOBALS
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-     dll-path:
	;
	; this path is setup by default and usually works with unlinked code.
	;
	; when you are running encapped, you might want to change this path before opening your service.
	;
	; note that the init function will try to open the dll if its not already done.
	; once opened, the dll is reused in all service calls.
	;
	; also note that the dll is ONLY required when your app is the service itself.
	; you can do ALL service management without the dll.
	;--------------------------
	dll-path: clean-path %service.dll
	
	
	;--------------------------
	;-     service.dll:
	;
	; the loaded dll handle
	;--------------------------
	service.dll: none
	
	
	
	;-----------------------------------------------------------------------------------------------------------
	;
	;- DEFINES
	;
	;-----------------------------------------------------------------------------------------------------------
	
	
	SC_MANAGER_ALL_ACCESS:		 int #{000F003F}
	SERVICE_ALL_ACCESS:			 int #{000F01FF}
	SERVICE_WIN32_OWN_PROCESS:	 int #{00000010}
	SERVICE_ERROR_NORMAL:		 int #{00000001}
	SERVICE_AUTO_START: 		 int #{00000002}
	SERVICE_DEMAND_START:		 int #{00000003}
	SERVICE_DELETE:				 int #{00010000}
	SERVICE_CONTROL_STOP:		 int #{00000001}
	SERVICE_CONTROL_INTERROGATE: int #{00000004}
	SERVICE_RUNNING:			 int #{00000004}
	SERVICE_START_PENDING:		 int #{00000002}
	SERVICE_CONTINUE_PENDING:	 int #{00000005}
	
	ERROR_SERVICE_DOES_NOT_EXIST: 1060
	
	
	
	
	;-----------------------------------------------------------------------------------------------------------
	;
	;- STRUCT DEFINITIONS
	;
	;-----------------------------------------------------------------------------------------------------------
	SERVICE_ANY_RUNNING: reduce [
		SERVICE_RUNNING 
		SERVICE_START_PENDING
		SERVICE_CONTINUE_PENDING
	]
	
	
	SERVICE_STATUS: make struct! struct-service-status: [
		dwServiceType			  [integer!]
		dwCurrentState			  [integer!]
		dwControlsAccepted 		  [integer!]
		dwWin32ExitCode			  [integer!]
		dwServiceSpecificExitCode [integer!]
		dwCheckPoint			  [integer!]
		dwWaitHint				  [integer!]
	] none
	

	;-----------------------------------------------------------------------------------------------------------
	;
	;- STUB FUNCS
	;
	;-----------------------------------------------------------------------------------------------------------
	

	;--------------------------
	;-     OpenSCManager()
	;--------------------------
	OpenSCManager: make routine! [
		lpMachineName	[integer!]
		lpDatabaseName	[integer!]
		dwDesiredAccess	[integer!]
		return:   		[integer!]
	] advapi32.dll "OpenSCManagerA"



	;--------------------------
	;-     CreateService()
	;--------------------------
	CreateService: make routine! [
		hSCManager   		[integer!]
		lpServiceName		[string!]
		lpDisplayName   	[string!]
		dwDesiredAccess		[integer!]
	  	dwServiceType		[integer!]
		dwStartType			[integer!]
	 	dwErrorControl		[integer!]
	  	lpBinaryPathName 	[string!]
		lpLoadOrderGroup 	[integer!]
		lpdwTagId			[integer!]
		lpDependencies		[integer!]
		lpServiceStartName	[integer!]
		lpPassword			[integer!]
		return:   			[integer!]
	] advapi32.dll "CreateServiceA"
	


	;--------------------------
	;-     DeleteService()
	;--------------------------
	DeleteService: make routine! [
		hService	[integer!]
		return:		[integer!]
	] advapi32.dll "DeleteService"
	


	;--------------------------
	;-     OpenService()
	;--------------------------
	OpenService: make routine! [
		hSCManager 		[integer!]
		lpServiceName 	[string!]
		dwDesiredAccess [integer!]
		return:  		[integer!]
	] advapi32.dll "OpenServiceA"
	


	;--------------------------
	;-     CloseServiceHandle()
	;--------------------------
	CloseServiceHandle: make routine! [
		hSCObject	[integer!]
		return:		[integer!]
	] advapi32.dll "CloseServiceHandle"
	


	;--------------------------
	;-     ControlService()
	;--------------------------
	ControlService: make routine! compose/deep [
		hService	[integer!]
		dwControl	[integer!]
		lpServiceStatus [struct! [(struct-service-status)]]
		return: 	[integer!]
	] advapi32.dll "ControlService"
	


	;--------------------------
	;-     StartService()
	;--------------------------
	StartService: make routine! [
		hService 			[integer!]
		dwNumServiceArgs	[integer!]
		lpServiceArgVectors [integer!]
		return: 			[integer!]
	] advapi32.dll "StartServiceA"
	


	;--------------------------
	;-     QueryServiceStatus()
	;--------------------------
	QueryServiceStatus: make routine! compose/deep [
		hService		[integer!]
		lpServiceStatus [struct! [(struct-service-status)]]
		return: 		[integer!]
	] advapi32.dll "QueryServiceStatus"



	;-----------------------------------------------------------------------------------------------------------
	;
	;- HELPER CLASS
	;
	;-----------------------------------------------------------------------------------------------------------


	;--------------------------
	;-     !SCM [...]
	;
	; service control manager
	;--------------------------
	!SCM: context [
		;--------------------------
		;-         scm-handle:
		;
		; a struct handle to an open scm, or none if it was closed or not opened yet
		;
		; note that all functions will attempt to open the scm if its not set when called.
		;--------------------------
		scm-handle: none
		
		
		;--------------------------
		;-         service-handle:
		;
		;
		;--------------------------
		service-handle: none
		
		
		;--------------------------
		;-         status-handle:
		;
		; a struct handle to the data which is used to query & interact with the SCM.
		;--------------------------
		status-handle: none
		
		
		;--------------------------
		;-         name:
		;
		; the shorthand service name.
		;--------------------------
		name: none
		
		
		;--------------------------
		;-         label:
		;
		; the long version of service name.
		;--------------------------
		label: none
		
		
		;--------------------------
		;-         description:
		;
		; the description which is visible in the SCM gui.
		;--------------------------
		description: none
		
		
		;--------------------------
		;-         win32-error:
		;
		; this will be set whenever an windows error occurs.  it will be cleared
		; when things to as planned.
		;--------------------------
		win32-error: none
		
		
		;--------------------------
		;-         service-path:
		;
		;
		;--------------------------
		service-path: none
		
		
		;--------------------------
		;-         service-args:
		;
		;  these are appended to the command-line 
		;--------------------------
		service-args: none
		
		
		
		
		
		;-----------------------------------------------------------------------------------------------------------
		;
		;-      METHODS
		;
		;-----------------------------------------------------------------------------------------------------------
		
		

		
		;--------------------------
		;-         report-error()
		;--------------------------
		; purpose:  re-implement this to report the error how you need it within your application.
		;
		;           In some functions, we expect specific errors and those will not be reported here.
		;
		;           Only in cases where unexpected errors occur do we call this function.
		;
		; inputs:   
		;
		; returns:  
		;
		; notes:    
		;
		; tests:    
		;--------------------------
		report-error: funcl [
			err [string! object! integer!]
		][
			vin "report-error()"
			
			title: get-application-title
			
			
			v?? err
			
			message: switch type?/word err [
				string! [
					join "ERROR: " err
				]
				
				object! [
					either win32-error? message [
						join "ERROR: " err/msg
					][
						rejoin ["run-time ERROR: " mold/all err ]
					]
				]
				
				integer! [
					vprint "INTEGER ERROR GIVEN"
					get-error-string err
;					out: make-mem-buffer 256
;					FormatMessage ( FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS ) 0  0 out 256 0
;					out
				]
			]
			
			os-alert title message
			vout
			
			message
		]
		

		
		;--------------------------
		;-         open-scm()
		;--------------------------
		; purpose:  
		;
		; inputs:   
		;
		; returns:  error condition.  A !win32-error object when there is an error, or none when successful
		;
		; notes:    
		;
		; tests:    
		;--------------------------
		open-scm: funcl [
			/extern scm-handle
		][
			vin "!SCM/open-scm()"
			rval: err: none ; make these local
			
			;---
			; if we have no handle and we can't open a new one, we return an error.
			unless scm-handle: any [
				scm-handle
				all [
					set [rval err] do-win32 :OpenSCManager [0 0 SC_MANAGER_ALL_ACCESS]
					rval
				]
				(
					v?? rval
					v?? err
					;ask "error ?! ..."
					none
				)
				;]
			][
				;---
				; we got none, get the last windows error.
				either err = ec/ERROR_ACCESS_DENIED [
					report-error "Administrator priviledges required"
				][
					report-error err
				]
			]
			vout
			scm-handle
		]
		
		
		;--------------------------
		;-         close-scm()
		;--------------------------
		; purpose:  close the handle to an opened scm
		;
		; inputs:   
		;
		; returns:  success?
		;
		; notes:    any opened service handles are also closed.
		;
		; tests:    
		;--------------------------
		close-scm: funcl [
		][
			vin "close-scm()"
			
			rval: err: none 
			
			;---	
			; make sure the service-handle this scm manages is also closed.
			close-service
			
			if scm-handle [
				;---
				; try to close 
				set [ rval err ] do-win32 :CloseServiceHandle  [ scm-handle ] 
				unless rval [
					report-error err
				]
			]
			
			; whatever-happens, we forget about the handle
			scm-handle: none
			
			vout
			true? rval
		]
		
		
		
		;--------------------------
		;-         open-Service()
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
		open-Service: funcl [
			/tolerate error-list [integer! block!]
			/quiet
			/extern service-handle
		][
			vin "!SCM/open-Service()"
						
			rval: err: none 
			error-list: compose [(  any [ error-list [] ]  )]
			
			v?? error-list
			v?? name
			
			; returns an error when we try to open the scm or service and it fails.
			if all [
				not service-handle
				open-scm
			][
				; note that service-handle remains none if call failed.
				set [ service-handle err ] do-win32 :OpenService  [ scm-handle name SERVICE_DELETE or SERVICE_ALL_ACCESS]
				if all [
					not quiet
					not service-handle
					not find error-list err
				][
					report-error err
				]
			]
			v?? service-handle
			vout
			; if error is none, we are successful, use service-handle
			service-handle
		]
		
		
		
		;--------------------------
		;-         close-service()
		;--------------------------
		; purpose:  close the handle to an opened service.
		;
		; inputs:   
		;
		; returns:  success in closing the handle
		;
		; notes:    
		;
		; tests:    
		;--------------------------
		close-service: funcl [
			/extern service-handle
		][
			vin "close-service()"
			rval: err: none
			if service-handle [
				;---
				; try to close 
				set [ rval err ] do-win32 :CloseServiceHandle  [ service-handle ]
				unless rval [
					report-error err
				]
			]
			
			; whatever-happens, we forget about the handle
			service-handle: none
			vout
			
			true? rval
		]
		
		

		
		;--------------------------
		;-         launch-service-listener()
		;--------------------------
		; purpose:  given the scm setup being used, it will call the service dll in order
		;           install a Service Control Handler.
		;
		;           the handler will send events to our udp port, installed in the system ports
		;           and the appropriate callback will be executed. 
		;
		; inputs:   
		;
		; returns:  
		;
		; notes:    we must add the input which sets what service name to start listening to.
		;
		; tests:    
		;--------------------------
		launch-service-listener: funcl [
		][
			vin "launch-service-listener()"
			
			either all [
				;---
				; make sure we can open the dll
				open-services-dll
				
				;---
				; make sure the service was installed
				open-service
				close-service
			][
				do make routine! [] service.dll "ServiceLaunch"
			][
				to-error "Unable to launch the service-listener."
			]
			
			vout
		]
		
		
		
		;--------------------------
		;-         handle-service-listener()
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
		handle-service-listener: funcl [
		][
			vin "handle-service-listener()"
			
			vout
		]
		
		
		;--------------------------
		;-         sufficient-credentials?()
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
		sufficient-credentials?: funcl [
		][
			vin "sufficient-credentials?()"
			rval: err: none
			
			set [rval err] do-win32 :OpenSCManager [0 0 SC_MANAGER_ALL_ACCESS]
			v?? rval 
			v?? err
			if rval [
				CloseServiceHandle rval
			]
			
			vout
			not err
		]
		
		
		
		;--------------------------
		;-         running?()
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
		running?: funcl [
		][
			vin "running?()"
			success?: if open-service [
				ss: make struct! SERVICE_STATUS none
				set [rval err] do-win32 :QueryServiceStatus [ service-handle ss ]
				if rval [
					to logic! find SERVICE_ANY_RUNNING ss/dwCurrentState
				]
			]
			vout
			success?
		]
		
		
		
		;--------------------------
		;-         installed?()
		;--------------------------
		; purpose:  
		;
		; inputs:   
		;
		; returns:  
		;
		; notes:    if you do not have the rights to the service, the default report error is opened
		;
		; tests:    
		;--------------------------
		installed?: funcl [
		][
			vin "installed?()"
			
			if is-installed?: any [
				service-handle
				open-service/quiet ; quiet will ignore only "not installed" type errors.
			][
				close-service
				true
			]
			is-installed?: true? is-installed?
			v?? is-installed?
			vout
			is-installed?
		]
		
	
		
		;--------------------------
		;-         install-service()
		;--------------------------
		; purpose:  tell the OS to install the service
		;
		; inputs:   
		;
		; returns:  
		;
		; notes:    if a service already exists with the same name, it is replaced by default.
		;
		; tests:    
		;--------------------------
		install-service: funcl [
			exe-path [file!]   "Filepath to win32 executable, it must exist!"
			exe-args [string!] "Arguments to add to the executable when launching it."
			/ask-if-replace  "Confirm with user if the service already exists on the machine."
		][
			vin "install-service()"
			err: rval: none
			
			;exe-path: to-local-file exe-path
			success?:  false
			
			v?? exe-path
			v?? exe-args
			
			;---
			; remove the service, in order to re-install it.
			if installed? [
				either any [
					not ask-if-replace
					vprobe os-confirm "Service Install"  "The service is already installed, do you want to replace it?"
				][
					remove-service
				][
					return false
				]
			]
			
			cmd: rejoin [ to-local-file exe-path  " " exe-args ]
			
			;---
			; do the installation
			v?? scm-handle
			v?? name
			v?? label
			v?? cmd
			
			set [ service-handle err ] do-win32 :CreateService [
				scm-handle
				name
				label
				SERVICE_ALL_ACCESS
				SERVICE_WIN32_OWN_PROCESS
				SERVICE_AUTO_START
				SERVICE_ERROR_NORMAL
				cmd
				0 0 0 0 0
			]
		
			v?? service-handle
			
			success?: true? service-handle
			
			either service-handle [
				vprint "All went good"
				close-service
			][
				report-error err
			]
			
		
			
			vout
			success?
		]
		
		
		
		set 'install-NT-service has [srv][
			vin "install-NT-service()"
			vout/return
			ERROR_ACCESS_DENIED <> with-SCM [
				unless zero? srv: try* [
					CreateService
						scm
						nt-service-app-name
						"Coginov NLP API Server"
						SERVICE_ALL_ACCESS
						SERVICE_WIN32_OWN_PROCESS
						SERVICE_AUTO_START
						SERVICE_ERROR_NORMAL
						join to-local-file system/options/boot join " -s " cheyenne/sub-args
				][
					try* [CloseServiceHandle srv]
				]
			]
		]
		
		
		
		
		;--------------------------
		;-         remove-service()
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
		remove-service: funcl [
		][
			vin "remove-service()"
			if open-service [
				; make sure the service is stopped
				stop-service
				
				DeleteService service-handle
				close-service
			]
			vout
		]
		
		
		
		;--------------------------
		;-         stop-service()
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
		stop-service: funcl [
		][
			vin "stop-service()"
			ss: make struct! SERVICE_STATUS none
			if open-service [
				set [ rval err ] do-win32 :ControlService [ service-handle SERVICE_CONTROL_STOP ss ]
			]
			vout
		]
		
		
		
		;--------------------------
		;-         start-service()
		;--------------------------
		start-service: funcl [
		][
			vin "start-service()"
			rval: err: none
			
			if open-service [
				set [ rval err ] do-win32 :StartService [ service-handle 0 0 ]
				either rval [
					vprint "service started :-)"
				][
					report-error err
				]
			]
			vout
		]
		
		
		
		
		;--------------------------
		;-         init()
		;--------------------------
		; purpose:  initialize the scm to make sure its ready
		;
		; inputs:   
		;
		; returns:  
		;
		; notes:    we do not attempt to load the dll.  only launching the listener does so.
		;
		; tests:    
		;--------------------------
		init: funcl [
			;/no-dll "We are only managing the service, no need to handle it, thus no need for the service-dll."
		][
			vin "!SCM/init()"
			success?: true? all [
				open-scm
			]
			vout
			success?
		]
		
		
		;--------------------------
		;-         close()
		;--------------------------
		; purpose:  fully close any open handles it still has
		;
		; inputs:   
		;
		; returns:  
		;
		; notes:    
		;
		; tests:    
		;--------------------------
		close: funcl [
		][
			vin "close()"
			close-scm ; automatically closes service.
			vout
		]
		
	]
	
	
	;-----------------------------------------------------------------------------------------------------------
	;
	;- FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;-     open-services-dll()
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
	open-services-dll: funcl [
		/extern service.dll
	][
		vin "win32-services.r/open-services-dll()"
		service.dll: attempt [
			 load/library dll-path
		]
		vprobe type? service.dll
		vout
		service.dll
	]
		
		
	
	;--------------------------
	;-     set-services-dll()
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
	set-services-dll: funcl [
		path [file!]
	][
		vin "set-services-dll()"
		path: clean-path path
		v?? path
		either exists? path [
			dll-path: path
		][
			to-error rejoin ["set-services-dll(): Path doesn't exist: ^/" path ]
		]
		vout
	]
	
		

	;--------------------------
	;-     setup-service()
	;--------------------------
	; purpose:  given a few params, create a new SCM object ready to be used.
	;
	; inputs:   
	;
	; returns:  an initialized SCM object! or none!
	;
	; notes:    errors are not trapped, so you may want to 'ATTEMPT or 'TRY this code.
	;
	; tests:    
	;--------------------------
	setup-service: funcl [
		service-name
		service-label
		service-description
		/exe  s-path
		/args s-args
		/extern service-path service-args
	][
		vin "win32-services.r/setup-service()"
		
		scm: make !scm [
			name: service-name
			label: service-label
			description: service-description
		]
		
		if exe [
			service-path: s-path
		]
		if args [
			service-args: s-args
		]
		
		
		vout
		
		; GC friendly
		first reduce [scm scm: service-name: service-label: service-description: none]
	]
	
	
	
	;-----------------------------------------------------------------------------------------------------------
	;
	;- UN-ADAPTED-CHEYENNE CODE
	;
	;-----------------------------------------------------------------------------------------------------------
	
		;with-SCM: func [body2 [block!] /local scm res][
		;	vin "with-SCM()"
		;	scm: try* [OpenSCManager 0 0 SC_MANAGER_ALL_ACCESS]
		;	if zero? scm [vout return last-error]
		;	res: do bind body2 'scm
		;	try* [CloseServiceHandle scm]
		;	
		;	vout/return	res
		;]
		;
		;with-service: func [body [block!] /quiet /local srv res cmd][
		;	vin "with-service()"
		;	bind body 'srv
		;	vout/return
		;	with-SCM [
		;		cmd: [OpenService scm nt-service-app-name SERVICE_DELETE or SERVICE_ALL_ACCESS]
		;		srv: either quiet [try*/quiet cmd][try* cmd]
		;		unless zero? srv [
		;			res: do body
		;			try* [CloseServiceHandle srv]
		;		]
		;		res
		;	]
		;]
		
	set 'NT-service? does [
		vin "NT-service?()"
		vout/return (
		true = with-service/quiet [
			if zero? srv [
				if ERROR_SERVICE_DOES_NOT_EXIST <> GetLastError [
					log/error ["Opening service failed : " get-error-msg]
				]
			]
			not zero? srv
		])
	]
		
	
	
	set 'launch-service has [file][
		vin "launch-service()"
		file: join cheyenne/data-dir %cogisrvc.dll
		v?? file
		unless exists? file [
			write/binary file read-cache %misc/cogisrvc.dll
		]
		do make routine! [] load/library file "ServiceLaunch"
		vout
	]
	
	
	set 'uninstall-NT-service does [
		vin "uninstall-NT-service()"
		vout/return
		with-service [try* [DeleteService srv]]	
	]
	
	set 'control-service func [/start /stop /local ss][
		vin "control-service()"
		vout/return with-service [
			if start [
				try* [StartService srv 0 0]
			]
			if stop [
				ss: make struct! SERVICE_STATUS none
				try* [ControlService srv SERVICE_CONTROL_STOP ss]
			]
		]
	]
	
	set 'NT-service-running? has [ss][
		vin "NT-service-running?()"
		ss: make struct! SERVICE_STATUS none
		with-service [try* [QueryServiceStatus srv ss]]
		vout/return (
			to logic! find SERVICE_ANY_RUNNING ss/dwCurrentState
		)
	]



]