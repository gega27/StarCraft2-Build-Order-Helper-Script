#Region ; **** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_type=a3x
#EndRegion ; **** Directives created by AutoIt3Wrapper_GUI ****

#RequireAdmin

#include-once
#include <Misc.au3>
#include <AutoItConstants.au3>
#include <WindowsConstants.au3>
#include <UDF\TTS.au3>
#include <UDF\SC2_Constants.au3>
#include <UDF\BlockInputEx.au3>
#include <UDF\IsPressed_UDF.au3>

; TO DO: 2) Add probe issue Async function (default Build and Additional/General Build

; TO DO: 1) Get time start picture 0:00, 0:30, 1:00, 1:30, 2:00, 2:30, 3:00 and auto delay script feature
; TO DO: 8) Add auto Select main first nexus base and auto toggle activate bot script on 0:00
; TO DO: 3) Add Auto Screen Pause/Unpause feaure for SC2

; TO DO: 4) Add zealot and stalker auto Issue Feature (General Build)
; TO DO: 5) User KeyBoard Iddle time wait function (anykeypress and capslock explicit pause)
; TO DO: 6) ADD SHIFT + 0  FEATURE TO auto issue General Probe Build
; TO DO: 7) ADD Auto Chrono Boost Feature for Probes
; TO DO: 9) Correct KeySend Delays from 100 ms to 200 ms

Local $hDLLuser32 = DllOpen("user32.dll")

OnAutoItExitRegister("OnAutoItExit")

Local $var_IsSC2Active     		    = False ; Paused in default
Local $var_bReminderPaused 			= False
Local $var_bCtrl10GroupAssigned     = False ; Paused in default
Local $var_bCtrl10GroupSelected     = False ; Paused in default
Local $var_bCtrl9GroupAssigned      = False ; Paused in default
Local $var_bCtrl9GroupSelected      = False ; Paused in default
Local $var_bProbeflow_Paused    	  = True  ; Paused in default
Local $var_i 						  = 0 	  ; internal variable
Local $var_bUserInputBlocked		= False;

Local $var_bBuildActionIsRequired	= False
Local $var_nProbeCounter			= 0
Local $var_nProbesProcessed			= 0

Local $var_nArmyCounter     		= 0
Local $var_nArmyProcessed			= 0

Local $var_nZealotCounter     		= 0
Local $var_nZealotProcessed			= 0

Local $var_nStalkerCounter     		= 0
Local $var_nSentryCounter     		= 0

Local $var_arrayProbes_defaultbuild_MaxI = 24
Local $var_arrayProbes_defaultbuild[$var_arrayProbes_defaultbuild_MaxI+1][3] = _
																			[ [0, 'SpeakText', 'e' ] _
																			, [0, 'Probe', 'e' ] _
																			, [12000, 'Probe', 'e' ] _
																			, [24000, 'ChronoBoost Nexus', 'e' ] _
																			, [30000, 'Probe', 'e' ] _
																			, [36000, 'Probe', 'e' ] _
																			, [49000, 'Probe', 'e' ] _
																			, [61000, 'Probe', 'e' ] _
																			, [73000, 'Probe', 'e' ] _
																			, [85000, 'Probe', 'e' ] _
																			, [97000, 'Probe', 'e' ] _
																			, [109000, 'Probe', 'e' ] _
																			, [121000, 'Probe', 'e' ] _
																			, [133000, 'Probe', 'e' ] _
																			, [145000, 'Probe', 'e' ] _
																			, [157000, 'Probe', 'e' ] _
																			, [169000, 'Probe', 'e' ] _
																			, [181000, 'Probe', 'e' ] _
																			, [193000, 'Probe', 'e' ] _
																			, [205000, 'Probe', 'e' ] _
																			, [217000, 'Probe', 'e' ] _
																			, [229000, 'Probe', 'e' ] _
																			, [241000, 'Probe', 'e' ] _
																			, [253000, 'Probe', 'e' ] _
																			, [265000, 'Probe', 'e' ] ]

Local $var_arrayProbes_Addonbuild_MaxI = 30
Local $var_arrayProbes_Addonbuild[$var_arrayProbes_Addonbuild_MaxI+1][3];
Local $var_NexusCount = 1

Local $var_arrayArmy_defaultbuild_MaxI = 24
Local $var_arrayArmy_defaultbuild[$var_arrayArmy_defaultbuild_MaxI+1][3] = _
																			[ [0, 'SpeakText', 's' ] _
																			, [90000, 'Stalker', 's' ] _
																			, [110000, 'Stalker', 's' ] _
																			, [137000, 'Stalker', 's' ] _
																			, [164000, 'Stalker', 's' ] _
																			, [164000, 'Stalker', 's' ] _
																			, [191000, 'zealot', 'z' ] _
																			, [191000, 'zealot', 'z' ] _
																			, [218000, 'zealot', 'z' ] _
																			, [218000, 'zealot', 'z' ] _
																			, [245000, 'zealot', 'z' ] _
																			, [245000, 'Stalker', 's' ] _
																			, [272000, 'Stalker', 's' ] _
																			, [272000, 'Stalker', 's' ] _
																			, [272000, 'Stalker', 's' ] _
																			, [299000, 'Stalker', 's' ] _
																			, [299000, 'Stalker', 's' ] _
																			, [299000, 'Stalker', 's' ] _
																			, [326000, 'Stalker', 's' ] _
																			, [326000, 'Stalker', 's' ] _
																			, [326000, 'Stalker', 's' ] _
																			, [353000, 'Stalker', 's' ] _
																			, [353000, 'Stalker', 's' ] _
																			, [353000, 'Stalker', 's' ] _
																			, [354000, 'Stalker', 's' ] ]


const $constProbeCounter			= 24
const $constZealotCounter     		= 4
const $constStalkerCounter     		= 8
const $constSentryCounter     		= 2

Local $var_bUserStateSHIFTKey	      = False
Local $var_bUserStateCTRLKey		  = False
Local $var_bUserStateALTKey		  	  = False

Local $var_bIsANYKeyDown			  		= False;
Local $var_nUserKeyNotUsed_SafeTime			= 1.0


Global $Default = _StartTTS()

Global $hTimeGameStart 	= 0
Global $fTimeElapsed	= 0
Global $fTimeElapsedInt	= 0
Global $fTimeGlobalLastProccessedTime	= 0

Global $fTimeTotalTimeScriptWasPaused = 0
Global $fTimeToSleepTime = 0
Global $hDelayPauseTimer = 0

If Not IsObj($Default) Then
    MsgBox(0, 'Error', 'Failed create object')
    Exit
EndIf

Func _Speak2(ByRef $Object, $sText, $bWait=True)
	If Not IsObj($Object) Then
		Return
	EndIf
	_Speak($Object, $sText, $bWait)
	Sleep(200)
EndFunc

$hNotepad_Wnd = WinGetHandle("[REGEXPCLASS:Notepad.*]")

_Speak2($Default, 'Ready', True) ; GegaSC2
Send(":")
_BlockInputEx(1, "{MMOVE}", "", $hNotepad_Wnd, 0)
Send(">")
Sleep(1000)
Send("1")
Sleep(1000)
_Speak2($Default, 'Async', False) ; GegaSC2
Sleep(1000)
Send("2")
Sleep(1000)
Send("3")
_Speak2($Default, 'Sync', False) ; GegaSC2
Sleep(1000)
Send("4")
Sleep(1000)
Send("5")
_Speak2($Default, 'Async', False) ; GegaSC2
Sleep(2000)
Send("6")
Sleep(2000)
Send("7")
_Speak2($Default, 'Done', False) ; GegaSC2
Send("<")
_BlockInputEx(0, "", "", $hNotepad_Wnd, 0)
Sleep(300)
Exit

;SC2_SaveCurSelection()
;_Speak2($Default, 'One, Two, Three', True) ; GegaSC2
;SC2_RestoreCurSelection()

Func SC2_BlockInputEx_Inner($iBlockMode = -1, $sExclude = "", $sInclude = "", $hWindows = "", $iBlockAllInput = 0)
	if $iBlockMode = 1 Then
		_BlockInputEx(1, "{MMOVE}", "", "", 1)
		$var_bUserInputBlocked = True
	Else
		if $var_bUserInputBlocked then
			_BlockInputEx(0)
			$var_bUserInputBlocked = False
		EndIf
	EndIf
EndFunc

Func SC2_SmartBlockInputEx($iBlockMode = -1, $sExclude = "", $sInclude = "", $hWindows = "", $iBlockAllInput = 0)
	if $iBlockMode > 0 Then
		Do
			SC2_WaitForKeyRelease()
			SC2_BlockInputEx_Inner(1, "{MMOVE}") ; SC2_BlockInputEx_Inner($iBlockMode, $sExclude, $sInclude, $hWindows, $iBlockAllInput)
			Sleep(100)
		Until _IsAnyKeyPressed($hDLLuser32) = 0
	Else
		SC2_BlockInputEx_Inner(0)
		Sleep(100)
		; SC2_BlockInputEx_Inner($iBlockMode, $sExclude, $sInclude, $hWindows, $iBlockAllInput)
	EndIf
EndFunc

Func SC2_SaveCurSelection()
; -- wait until key is released: Any.
	SC2_WaitForKeyRelease()
	SC2_DeselectAllGroups()
    ; Disable user input, Except Mouse Move.
;	_Speak2($Default, 'Ready', True) ; GegaSC2
	Send(":")
	_BlockInputEx(1, "{MMOVE}") ; SC2_SmartBlockInputEx(1, '{MMOVE}')
	Send(">")
	_Speak2($Default, "BUG", True)
	_Speak2($Default, "BUG", False)
EndFunc

Func SC2_RestoreCurSelection()
;	_Speak2($Default, "Test Now", True)
	Sleep(2000)
	SC2_DeselectAllGroups()
	Send("<")
    ; Enable user input from the mouse and keyboard.
	_BlockInputEx(0)  ; SC2_SmartBlockInputEx(0) ; 0 = Enable input ; BlockInput($BI_ENABLE)
	; _Speak2($Default, "Unlocked", True)
	; _Speak2($Default, "Done", True)
EndFunc


;~ _Speak2($Default, '5 Seconds', True) ; GegaSC2
;~ 	SC2_SmartBlockInputEx(1, "{MMOVE}")
;~ Sleep(50)
;~ Sleep(5000)
;~ 	SC2_SmartBlockInputEx(0)
;~ Sleep(50)
;~ 	_Speak2($Default, 'Buy', True) ; GegaSC2
;~ Exit

; sc2_GameScript_Toggle()

; HotKeySet("{ESC}", "_SC2_HotKey_ExitScript_Func")
HotKeySet("^o", "_SC2_HotKey_ExitScript_Func") ; was before _SC2_HotKey_Pause_func
HotKeySet("^=", "_SC2_HotKey_GameScript_Toggle")
HotKeySet("^-", "_SC2_HotKey_GameScript_DelayPause")

HotKeySet("^p", "_SC2_HotKey_UnPause_func")
HotKeySet("^0", "_SC2_HotKey_ctrl0_pressed")
HotKeySet("^9", "_SC2_HotKey_ctr9_pressed")
HotKeySet("+0", "_SC2_HotKey_shift10_pressed")

;~ Func _Speak2(ByRef $Object, $sText, $bWait=True)
;~ 	If Not IsObj($Object) Then
;~ 		Return
;~ 	EndIf
;~ 	_Speak($Object, $sText, $bWait)
;~ 	Sleep(200)
;~ EndFunc

Func _SC2_HotKey_UnPause_func()
	HotKeySet("^p")
	SC2_WaitForKeyRelease(2000)
	; Custom action here
	sc2_GameScript_Toggle()
	; Replicate User Key presses -----
    Send("{CTRLDOWN}p{CTRLUP}") ; {CTRLDOWN} {CTRLUP}
	HotKeySet("^p","_SC2_HotKey_UnPause_func")
EndFunc

Func _SC2_HotKey_Pause_func()
	HotKeySet("^o")
	SC2_WaitForKeyRelease(2000)
	; Custom action here
	sc2_GameScript_EnableDisable(False)
	; Replicate User Key presses -----
    Send("{CTRLDOWN}o{CTRLUP}") ; {CTRLDOWN} {CTRLUP}
	HotKeySet("^o","_SC2_HotKey_Pause_func")
EndFunc

Func _SC2_HotKey_ctr9_pressed()
	HotKeySet("^9")
	SC2_WaitForKeyRelease(2000)
	; Custom action here
	$var_bCtrl9GroupAssigned 		= True
	; Replicate User Key presses -----
    Send("{CTRLDOWN}9{CTRLUP}")
	HotKeySet("^9","_SC2_HotKey_ctr9_pressed")
EndFunc

Func _SC2_HotKey_shift10_pressed()
	HotKeySet("+0")
	SC2_WaitForKeyRelease(2000)
	; Custom action here
	 ; $var_bCtrl9GroupAssigned 		= True
	$var_NexusCount = $var_NexusCount + 1
	_Speak2($Default, "Nexus Count is "&$var_NexusCount, False)
	; Replicate User Key presses -----
    Send("{SHIFTDOWN}0{SHIFTUP}")
	HotKeySet("+0","_SC2_HotKey_shift10_pressed")
EndFunc


Func _SC2_HotKey_ctrl0_pressed()
	HotKeySet("^0")
	SC2_WaitForKeyRelease(2000)
	; Custom action here
	$var_bCtrl10GroupAssigned = True
    sc2_GameScript_EnableDisable(True)
	; Replicate User Key presses -----
    Send("{CTRLDOWN}10{CTRLUP}")
	HotKeySet("^0","_SC2_HotKey_ctrl0_pressed")
EndFunc

Func _SC2_HotKey_ExitScript_Func()
	HotKeySet("^o")
	SC2_WaitForKeyRelease(2000)
	; Custom action here
	_Speak2($Default, 'Good Luck', False)
	Sleep(4000)
	Exit(1)
	; Replicate User Key presses -----
    Send("{CTRLDOWN}o{CTRLUP}") ; {CTRLDOWN} {CTRLUP}
	HotKeySet("^o","_SC2_HotKey_ExitScript_Func")
EndFunc

Func _SC2_HotKey_GameScript_Toggle()
	HotKeySet("^=")
	SC2_WaitForKeyRelease()
	; Custom action here
	sc2_GameScript_Toggle()
	; Replicate User Key presses -----
    Send("{CTRLDOWN}={CTRLUP}") ;
	HotKeySet("^=","_SC2_HotKey_GameScript_Toggle")
EndFunc

Func _SC2_HotKey_GameScript_DelayPause()
	HotKeySet("^-")
	SC2_WaitForKeyRelease()
	; Custom action here
	sc2_ScriptDelayBy(10000)
	; Replicate User Key presses -----
    Send("{CTRLDOWN}-{CTRLUP}") ;
	HotKeySet("^-","_SC2_HotKey_GameScript_DelayPause")
EndFunc

Func SC2_isModuleKeyPressed()
	return(_IsPressed("10", $hDLLuser32) Or _IsPressed("11", $hDLLuser32) Or _IsPressed("12", $hDLLuser32) )
EndFunc

Func SC2_isAnyKeyPressed()
	return( _IsAnyKeyPressed($hDLLuser32))
EndFunc

Func SC2_WaitForKeyRelease($lcRemindTime = 3000)
	local $var_icnt = 1
	While _IsAnyKeyPressed($hDLLuser32) = 1
		SC2_BlockInputEx_Inner(0) ; Enable input temporary to for granting access to keyboard for user and wait for key release
		if mod($var_icnt * 100, $lcRemindTime) = 0 Then
			_Speak2($Default, 'Release Keys', False)
		EndIf
        Sleep(100)
		$var_icnt = $var_icnt + 1
	WEnd
EndFunc

Func sc2_ScriptTimeInit()
	$hTimeGameStart = TimerInit()
	$fTimeGlobalLastProccessedTime = 0
	$fTimeElapsed = 0
	$fTimeElapsedInt = 0
	$fTimeTotalTimeScriptWasPaused = 0
	$fTimeToSleepTime = 0
	$var_bReminderPaused = False

	; Build Flow Init
	$var_nProbesProcessed 		= 0
	$var_nProbeCounter 			= 0
	$var_nArmyCounter     		= 0
	$var_nArmyProcessed			= 0
	$var_NexusCount				= 1
EndFunc

Func sc2_ScriptDelayBy($SleepTime = 10000)
	if $SleepTime > 0 Then
		$var_bReminderPaused = True
		if $fTimeToSleepTime <= 0 Then
			$hDelayPauseTimer = TimerInit()
			$fTimeToSleepTime = $SleepTime
		Else
			$fTimeToSleepTime = $fTimeToSleepTime + $SleepTime
		EndIf
		$fTimeTotalTimeScriptWasPaused = $fTimeTotalTimeScriptWasPaused + $SleepTime
		_Speak2($Default, 'Paused for '&($SleepTime/1000)&' Seconds', False)
	Else
		$var_bReminderPaused = False
		; $fTimeToSleepTime = $fTimeToSleepTime
	EndIf
EndFunc

Func sc2_ScriptTimeReset()
	sc2_ScriptTimeInit()
EndFunc

Func sc2_ScriptTimeUpdate()
	$fTimeElapsed = TimerDiff($hTimeGameStart) - $fTimeTotalTimeScriptWasPaused
	$fTimeElapsedInt = int($fTimeElapsed / 1000)
	if TimerDiff($hDelayPauseTimer) >= $fTimeToSleepTime Then
		; Resume From DelayPause
		$fTimeToSleepTime = 0
		$var_bReminderPaused = False
	EndIf
EndFunc

Func sc2_ScriptSaveLastTime()
	if $fTimeElapsed > $fTimeGlobalLastProccessedTime Then
		$fTimeGlobalLastProccessedTime = $fTimeElapsed
	EndIf
EndFunc

Func SC2_DeselectAllGroups()
	$var_bCtrl10GroupSelected = False
	$var_bCtrl9GroupSelected = False
EndFunc

Func SC2_SelectGroup($lcn_groupNum)
	Switch $lcn_groupNum
		Case 9
			if not $var_bCtrl9GroupSelected then
				SC2_DeselectAllGroups()
				Send("9")
				Sleep(200)
				$var_bCtrl9GroupSelected = True
			EndIf
		Case 10
			if not $var_bCtrl10GroupSelected then
				SC2_DeselectAllGroups()
				Send("0")
				Sleep(200)
				$var_bCtrl10GroupSelected = True
			EndIf
		Case Else
			Return
	EndSwitch
EndFunc

Func IsItTimeToTrigger($lcActionTime)
	Return($fTimeGlobalLastProccessedTime <= $lcActionTime and $fTimeElapsed >= $lcActionTime)
EndFunc

Func DoTriggeredAction(ByRef $lcObject, $lcActNum, $lcAtProb, $lcAtRemindTime, $lcAtTime, $lcActText, $lcClockText)
	if IsItTimeToTrigger($lcAtRemindTime)  Then
		; comment this line if you have anbother script for issuing probe
		if not StringInStr($lcActText, "Probe") then
			_Speak2($lcObject, '@'&$lcClockText&', '&$lcActText, False)
		Else
			; _Speak2($lcObject, '@'&$lcClockText&': '&$lcAtProb&' Probes', False)
		EndIf
	EndIf
EndFunc

Func SC2_ReqNewProbe($lcnProbeNum = 0)
	if not $var_bCtrl10GroupAssigned then Return
	_Speak2($Default, $var_arrayProbes_defaultbuild[$lcnProbeNum][1], False)
	SC2_SelectGroup(10)
	for $i = 1 to $var_NexusCount STEP 1
		Send($var_arrayProbes_defaultbuild[$lcnProbeNum][2])
		Sleep(200)
	Next
EndFunc

Func SC2_ReqNewArmy($lcnUnitNum = 0)
	if not $var_bCtrl9GroupAssigned then Return
	_Speak2($Default, $var_arrayArmy_defaultbuild[$lcnUnitNum][1], False)
	SC2_SelectGroup(9)
	Send($var_arrayArmy_defaultbuild[$lcnUnitNum][2])
	Sleep(200)
EndFunc

Func CheckNextBuildActions()
	$var_bBuildActionIsRequired = False

	For $i = $var_nProbeCounter + 1 To $var_arrayProbes_defaultbuild_MaxI Step 1
		IF IsItTimeToTrigger($var_arrayProbes_defaultbuild[$i][0]) Then
			$var_nProbeCounter = $i
			$var_bBuildActionIsRequired = True
		EndIf
		; exit when next action way to far
		if $var_arrayProbes_defaultbuild[$i][0] > $fTimeElapsed Then
			ExitLoop
		EndIf
	Next

	For $i1 = $var_nArmyCounter + 1 To $var_arrayArmy_defaultbuild_MaxI Step 1
		IF IsItTimeToTrigger($var_arrayArmy_defaultbuild[$i1][0]) Then
			$var_nArmyCounter = $i1
			$var_bBuildActionIsRequired = True
		EndIf
		; exit when next action way to far
		if $var_arrayArmy_defaultbuild[$i1][0] > $fTimeElapsed Then
			ExitLoop
		EndIf
	Next
EndFunc

Func ProcessAllQueuedActions()
	if not $var_bBuildActionIsRequired Then Return
	SC2_SaveCurSelection()
	; Process Probes
	while $var_nProbesProcessed < $var_nProbeCounter
		$var_nProbesProcessed = $var_nProbesProcessed + 1
		SC2_ReqNewProbe($var_nProbesProcessed)
	WEnd
	; Process Army
;	while $var_nArmyProcessed < $var_nArmyCounter
;		$var_nArmyProcessed = $var_nArmyProcessed + 1
;		SC2_ReqNewArmy($var_nArmyProcessed)
;	WEnd
	SC2_RestoreCurSelection()
	$var_bBuildActionIsRequired = False
EndFunc

Func SC2_Scenario_ProcessEcoBuild()
	DoTriggeredAction($Default, 1, 12, 0, 2000, 'Probe', '02')
	DoTriggeredAction($Default, 2, 13, 12000, 14000, 'Probe', '14')
	DoTriggeredAction($Default, 3, 14, 15000, 17000, 'Pylon 1', '17')
	DoTriggeredAction($Default, 4, 14, 24000, 26000, 'Probe (Chrono Boost)', '26')
	DoTriggeredAction($Default, 5, 15, 30000, 32000, 'Probe', '32')
	DoTriggeredAction($Default, 6, 15, 34000, 36000, 'Gateway One', '36')
	DoTriggeredAction($Default, 7, 16, 38000, 40000, 'Probe (Chrono Boost)', '40')
	DoTriggeredAction($Default, 8, 17, 43000, 45000, 'Assimilator 1', '45')
	DoTriggeredAction($Default, 9, 17, 51000, 53000, 'Probe', '53')
	DoTriggeredAction($Default, 10, 18, 63000, 65000, 'Probe', '1:05')
	DoTriggeredAction($Default, 11, 19, 75000, 77000, 'Probe', '1:17')
	DoTriggeredAction($Default, 12, 20, 79000, 81000, 'Nexus 2', '1:21')
	DoTriggeredAction($Default, 13, 20, 89000, 91000, 'Cybernetics Core', '1:31')
	DoTriggeredAction($Default, 14, 20, 94000, 96000, 'Probe (Chrono Boost)', '1:36')
	DoTriggeredAction($Default, 15, 20, 96000, 98000, 'Assimilator 2', '1:38')
	DoTriggeredAction($Default, 16, 22, 106000, 108000, 'Probe', '1:48')
	DoTriggeredAction($Default, 17, 22, 107000, 109000, 'Pylon 2', '1:49')
	DoTriggeredAction($Default, 18, 23, 125000, 127000, 'Stalker (Chrono Boost)', '2:07')
	DoTriggeredAction($Default, 19, 23, 126000, 128000, 'Cybernetics Core, Upgrade Warp Gate', '2:08')
	DoTriggeredAction($Default, 20, 26, 135000, 137000, 'Stalker', '2:17')
	DoTriggeredAction($Default, 21, 29, 150000, 152000, 'Robotics Facility', '2:32')
	DoTriggeredAction($Default, 22, 34, 172000, 174000, 'Twilight Council', '2:54')
	DoTriggeredAction($Default, 23, 36, 187000, 189000, 'Observer one', '3:09')
	DoTriggeredAction($Default, 24, 36, 190000, 192000, 'Gateways 2 and 3', '3:12')
	DoTriggeredAction($Default, 25, 39, 208000, 210000, 'Twilight Council, Upgrade Blink', '3:30')
	DoTriggeredAction($Default, 26, 41, 215000, 217000, 'Pylon 3', '3:37')
	DoTriggeredAction($Default, 27, 41, 217000, 219000, 'Observer two', '3:39')
	DoTriggeredAction($Default, 28, 46, 234000, 236000, 'Nexus 3', '3:56')
	DoTriggeredAction($Default, 29, 46, 237000, 239000, 'Pylon 4', '3:59')
	DoTriggeredAction($Default, 30, 46, 243000, 245000, 'Assimilator 3', '4:05')
	DoTriggeredAction($Default, 31, 48, 257000, 259000, 'Observer three', '4:19')
	DoTriggeredAction($Default, 32, 48, 258000, 260000, 'Stalker x3', '4:20')
	DoTriggeredAction($Default, 33, 57, 268000, 270000, 'Pylon 5', '4:30')
	DoTriggeredAction($Default, 34, 59, 278000, 280000, 'Observer 4', '4:40')
	DoTriggeredAction($Default, 35, 59, 283000, 285000, 'Forge, one and two', '4:45')
	DoTriggeredAction($Default, 36, 59, 288000, 290000, 'Sentry, one and two', '4:50')
	DoTriggeredAction($Default, 37, 65, 296000, 298000, 'Forge , Upgrade Ground Weapons', '4:58')
	DoTriggeredAction($Default, 38, 65, 297000, 299000, 'Forge, Upgrade Ground Armor', '4:59')
	DoTriggeredAction($Default, 39, 67, 310000, 312000, 'Observer 5', '5:12')
	DoTriggeredAction($Default, 40, 73, 321000, 323000, 'Gateway 4, 5, and 6', '5:23')
;~ 	DoTriggeredAction($Default, 41, 73, 325000, 327000, 'Sentry', '5:27')
;~ 	DoTriggeredAction($Default, 42, 76, 328000, 330000, 'Gateway 7', '5:30')
;~ 	DoTriggeredAction($Default, 43, 78, 335000, 337000, 'Gateway 8', '5:37')
;~ 	DoTriggeredAction($Default, 44, 79, 340000, 342000, 'Assimilator 4 and 5', '5:42')
;~ 	DoTriggeredAction($Default, 45, 81, 351000, 353000, 'Observer 6', '5:53')
;~ 	DoTriggeredAction($Default, 46, 82, 359000, 361000, 'Twilight Council, Upgrade Charge', '6:01')
;~ 	DoTriggeredAction($Default, 47, 82, 367000, 369000, 'Shield Battery x2', '6:09')
;~ 	DoTriggeredAction($Default, 48, 85, 378000, 380000, 'Immortal', '6:20')
;~ 	DoTriggeredAction($Default, 49, 89, 388000, 390000, 'Stalker x5', '6:30')
;~ 	DoTriggeredAction($Default, 50, 105, 401000, 403000, 'Protoss Ground Weapons Level 2, Protoss Ground Armor Level 2', '6:43')
;~ 	DoTriggeredAction($Default, 51, 105, 405000, 407000, 'Nexus 4', '6:47')
;~ 	DoTriggeredAction($Default, 52, 114, 427000, 429000, 'Warp Prism', '7:09')
;~ 	DoTriggeredAction($Default, 53, 116, 435000, 437000, 'Zealot x5', '7:17')
;~ 	DoTriggeredAction($Default, 54, 126, 446000, 448000, 'Gateway x2', '7:28')
;~ 	DoTriggeredAction($Default, 55, 126, 448000, 450000, 'Zealot x2', '7:30')
;~ 	DoTriggeredAction($Default, 56, 130, 470000, 472000, 'Zealot x3', '7:52')
;~ 	DoTriggeredAction($Default, 57, 130, 475000, 477000, 'Observer', '7:57')
;~ 	DoTriggeredAction($Default, 58, 146, 481000, 483000, 'Templar Archives', '8:03')
;~ 	DoTriggeredAction($Default, 59, 150, 488000, 490000, 'Immortal', '8:10')
;~ 	DoTriggeredAction($Default, 60, 154, 494000, 496000, 'Psionic Storm', '8:16')
;~ 	DoTriggeredAction($Default, 61, 154, 519000, 521000, 'High Templar x4', '8:41')
;~ 	DoTriggeredAction($Default, 62, 154, 524000, 526000, 'Assimilator x2', '8:46')
;~ 	DoTriggeredAction($Default, 63, 168, 532000, 534000, 'Photon Cannon x2', '8:54')
;~ 	DoTriggeredAction($Default, 64, 168, 536000, 538000, 'Shield Battery', '8:58')
;~ 	DoTriggeredAction($Default, 65, 168, 544000, 546000, 'Protoss Shields Level 1', '9:06')
;~ 	DoTriggeredAction($Default, 66, 168, 549000, 551000, 'High Templar x2', '9:11')
;~ 	DoTriggeredAction($Default, 67, 172, 567000, 569000, 'High Templar x2', '9:29')
;~ 	DoTriggeredAction($Default, 68, 178, 591000, 593000, 'Protoss Ground Weapons Level 3', '9:53')
;~ 	DoTriggeredAction($Default, 69, 178, 595000, 597000, 'Archon x2', '9:57')
EndFunc

Func SC2_MainActionTick()
	CheckNextBuildActions()
	SC2_Scenario_ProcessEcoBuild()
	ProcessAllQueuedActions()
EndFunc

Func Main ()
	while 1
		if $var_IsSC2Active Then
			sc2_ScriptTimeUpdate()
			SC2_MainActionTick()
			sc2_ScriptSaveLastTime()
		EndIf
		Sleep(200)
	WEnd
EndFunc

Func sc2_GameScript_Toggle($local_bInvertEnabled = True)
	$var_IsSC2Active = not $var_IsSC2Active and $local_bInvertEnabled
	if $var_IsSC2Active then
		sc2_ScriptTimeReset()
		_Speak2($Default, 'Bot Enabled', False)
	Else
		_Speak2($Default, 'Bot Disabled', False)
	EndIf
EndFunc

Func sc2_GameScript_EnableDisable($local_bEnable)
	if $local_bEnable then
		if not $var_IsSC2Active then
			_Speak2($Default, 'Bot Enabled', False)
			sc2_ScriptTimeReset()
		Else
			_Speak2($Default, 'Bot Restarted', False)
			sc2_ScriptTimeReset()
		EndIf
	Else
		if $var_IsSC2Active then
			_Speak2($Default, 'Bot Disabled', False)
		EndIf
	EndIf
	$var_IsSC2Active = $local_bEnable
EndFunc

Func OnAutoItExit()
	DllClose($hDLLuser32)
	DllClose($hUser32)
	__BlockInputEx_OnAutoItExit()
EndFunc   ;==>OnAutoItExit

Main()

Exit(0)