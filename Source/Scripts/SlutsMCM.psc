Scriptname SlutsMCM extends SKI_ConfigBase Conditional

; ---------------------------------- Properties
SlutsMain Property main Auto
SlutsData Property data Auto
SlutsMissionHaul Property missionSc Auto
SlutsTats property tatlib auto
SlutsBondage Property bd Auto

; ---------------------------------- Variables
string[] difficulty
; Settings
int Property iHaulType01 = 50 Auto Hidden
{Default Haul, with the buggy cart}
int Property iHaulType02 = 0 Auto Hidden
{Premium Haul, special Delivery to a random NPC}
int[] Property HaulWeights
	{All Haul Types wrapped together in a single array}
	int[] Function Get()
		int[] ret = new int[2]
		ret[0] = iHaulType01
		ret[1] = iHaulType02
		return ret
	EndFunction
EndProperty

int Property iSpontFail = 0 Auto Hidden
{Chance to randomly fail a perfect run}
bool Property bSpontFailRandom = true Auto Hidden
int Property iRehabtRate = 1 Auto Hidden
{Difficulty Scale for Rehab System}

int Property iSSminDebt = 2 Auto Hidden
; Customisation
bool property bUseThermal = false auto Hidden
bool property bThermalColor = true Auto Hidden
bool bPonyAnims = true
;SlaveTats
bool property bUseSlutsLivery = true auto Hidden Conditional
bool property bUseSlutsColors = true auto Hidden Conditional
int property iCustomLiveryColor = 0 auto Hidden
;Debug
bool Property bLargeMsg = false Auto Hidden
bool Property bStruggle = true Auto Hidden
string sTatRemove = "Click"
string sUnponify = "Click"
string sReturnCart = "Click"
string sReinitMod = "Click"
; bool property bSetEssential = false auto Hidden
bool Property bShowDist = false Auto Hidden

; ---------------------------------- Code
bool Property bCooldown = false Auto Hidden Conditional
Function Cooldown()
	bCooldown = true
	Utility.Wait(30)
	bCooldown = false
EndFunction

int Function GetVersion()
	return 1
endFunction

Function Initialize()
	Pages = new string[3]
	Pages[0] = "$SLUTS_Settings"
	Pages[1] = "$SLUTS_Customisation"
	Pages[2] = "$SLUTS_Debug"

	difficulty = new string[4]
	difficulty[0] = "$SLUTS_difficulty0"
	difficulty[1] = "$SLUTS_difficulty1"
	difficulty[2] = "$SLUTS_difficulty2"
	difficulty[3] = "$SLUTS_difficulty3"
endFunction

; ==================================
; 							MENU
; ==================================
Event OnConfigInit()
	Initialize()
endEvent

Event OnPageReset(string Page)
	SetCursorFillMode(TOP_TO_BOTTOM)
	if(Page == "")
		LoadCustomContent("sluts/logo.dds", 186, 33)
		return
	else
		UnloadCustomContent()
	endIf
	If(Page == "$SLUTS_Settings")
		AddHeaderOption("$SLUTS_HaulTypes")
		AddSliderOptionST("defaultHaul", "$SLUTS_HaulCargo", iHaulType01)
		AddSliderOptionST("premiumHaul", "$SLUTS_HaulDelivery", iHaulType02, "{0}", OPTION_FLAG_DISABLED)
		; ============================
		SetCursorPosition(1)
		; ============================
		AddHeaderOption("$SLUTS_Hauls")
		AddSliderOptionST("SpontFail", "$SLUTS_SpontFail", iSpontFail, "{0}%")
		AddToggleOptionST("SpontFailRandom", "$SLUTS_SpontFailRnd", bSpontFailRandom)
		AddEmptyOption()
		AddHeaderOption("$SLUTS_Crime")
		AddMenuOptionST("RehabRate", "$SLUTS_RehabRate", difficulty[iRehabtRate])
		AddEmptyOption()
		AddHeaderOption("$SLUTS_SimpleSlavery")
		AddMenuOptionST("SSdebtScale", "$SLUTS_SSdebtScale", difficulty[iSSminDebt])

	ElseIf(Page == "$SLUTS_Customisation")
		AddHeaderOption("$SLUTS_FillyGear")
		AddToggleOptionST("UseThermal", "$SLUTS_UseThermal", bUseThermal)
		AddToggleOptionST("ThermalColor", "$SLUTS_ThermalColor", bThermalColor, getFlag(bUseThermal))
		AddEmptyOption()
		AddToggleOptionST("PonyAnims", "$SLUTS_PonyAnims", bPonyAnims)
		; ============================
		SetCursorPosition(1)
		; ============================
		AddHeaderOption("$SLUTS_SlaveTats")
		AddToggleOptionST("UseSlutsLivery", "$SLUTS_UseSlutsLivery", bUseSlutsLivery)
		AddToggleOptionST("UseSlutsColors", "$SLUTS_UseSlutsColors", bUseSlutsColors)
		AddColorOptionST("CustomLiveryColor", "$SLUTS_CustomLiveryColor", iCustomLiveryColor)

	ElseIf(Page == "$SLUTS_Debug")
		AddHeaderOption("$SLUTS_Hauls")
		AddToggleOptionST("LargeMsg", "$SLUTS_LargeMsg", bLargeMsg)
		AddToggleOptionST("DDStruggle", "$SLUTS_DDStruggle", bStruggle)
		AddEmptyOption()
		AddHeaderOption("$SLUTS_Debug")
		AddTextOptionST("EmergencyTatRemove", "$SLUTS_EmergencyTatRemove", sTatRemove)
		AddTextOptionST("RemoveDD", "$SLUTS_removeDD", sUnponify)
		AddTextOptionST("ReturnCart", "$SLUTS_ReturnCart", sReturnCart, getFlag(missionSc.GetState() == missionSc.CartDefault && missionSc.GetStage() == 20))
		AddEmptyOption()
		SetCursorPosition(1)
		AddHeaderOption("$SLUTS_HOTKEYS")
		AddTextOptionST("ResetCart", "$SLUTS_ResetCart", "", OPTION_FLAG_DISABLED)
	EndIf
EndEvent

Event OnConfigClose()
	If(sTatRemove == "$SLUTS_Working")
		if(tatlib.scrub(Game.GetPlayer()))
			Debug.notification("Tattoos Scrubbed")
			sTatRemove = "$SLUTS_Click"
		endif
	EndIf
	If(sUnponify == "$SLUTS_Working")
		Debug.Notification("Removing DD Items..")
		sUnponify = "$SLUTS_Click"
		Bd.UndressPony(Game.GetPlayer(), false)
	EndIf
	If(sReturnCart == "$SLUTS_Working")
		missionSc.Tether()
		sReturnCart = "$SLUTS_Click"
	EndIf

EndEvent

; ==================================
; 				States // Settings
; ==================================

;Haul Types
State defaultHaul
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iHaulType01)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	Event OnSliderAcceptST(float value)
		iHaulType01 = value as int
		SetSliderOptionValueST(iHaulType01)
	EndEvent
	Event OnHighlightST()
		SetInfoText("$SLUTS_HaulCargoHighlight")
	EndEvent
EndState

State premiumHaul
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iHaulType02)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	Event OnSliderAcceptST(float value)
		iHaulType02 = value as int
		SetSliderOptionValueST(iHaulType02)
	EndEvent
	Event OnHighlightST()
		SetInfoText("$SLUTS_HaulDeliveryHighlight")
	EndEvent
EndState

State SpontFail
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iSpontFail)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	Event OnSliderAcceptST(float value)
		iSpontFail = value as int
		SetSliderOptionValueST(iSpontFail)
	EndEvent
	Event OnHighlightST()
		SetInfoText("$SLUTS_SpontFailHighlight")
	EndEvent
EndState

state SpontFailRandom
	event onselectst()
		bSpontFailRandom = !bSpontFailRandom
		SetToggleOptionValueST(bSpontFailRandom)
	endevent
	event ondefaultst()
		bSpontFailRandom = true
		SetToggleOptionValueST(bSpontFailRandom)
	endevent
	event onhighlightst()
		SetInfoText("$SLUTS_SpontFailRndHighlight")
	endevent
endstate

State RehabRate
	Event OnMenuOpenST()
		SetMenuDialogStartIndex(iRehabtRate)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(difficulty)
	EndEvent

	Event OnMenuAcceptST(Int aiIndex)
		iRehabtRate = aiIndex
		SetMenuOptionValueST(difficulty[iRehabtRate])
	EndEvent

	Event OnDefaultST()
		iRehabtRate = 1
		SetMenuOptionValueST(difficulty[iRehabtRate])
	EndEvent

	Event OnHighlightST()
		SetInfoText("$SLUTS_RehabRateHighlight")
	EndEvent
EndState

;Simple Slavery
State SSdebtScale
	Event OnMenuOpenST()
		SetMenuDialogStartIndex(iSSminDebt)
		SetMenuDialogDefaultIndex(2)
		SetMenuDialogOptions(difficulty)
	EndEvent

	Event OnMenuAcceptST(Int aiIndex)
		iSSminDebt = aiIndex
		SetMenuOptionValueST(difficulty[iSSminDebt])
	EndEvent

	Event OnDefaultST()
		iSSminDebt = 2
		SetMenuOptionValueST(difficulty[iSSminDebt])
	EndEvent

	Event OnHighlightST()
		SetInfoText("$SLUTS_SSdebtScaleHighlight")
	EndEvent
EndState


; ==================================
; 			States // Customisation
; ==================================

state UseThermal
	event onselectst()
		bUseThermal = !bUseThermal
		SetToggleOptionValueST(bUseThermal)
	endevent
	event ondefaultst()
		bUseThermal = false
		SetToggleOptionValueST(bUseThermal)
	endevent
	event Onhighlightst()
		SetInfoText("$SLUTS_UseThermal_Info")
	endevent
endstate

State ThermalColor
	Event OnSelectST()
		bThermalColor = !bThermalColor
		SetToggleOptionValueST(bThermalColor)
	EndEvent
	Event OnHighlightST()
		SetInfoText("$SLUTS_ThermalFitColor_Info")
	EndEvent
EndState

state PonyAnims
	event onselectst()
		bPonyAnims = !bPonyAnims
		SetToggleOptionValueST(bPonyAnims)
		Bd.setCuffsLeg(bPonyAnims as int)
	endevent
	event ondefaultst()
		bPonyAnims = true
		SetToggleOptionValueST(bPonyAnims)
		Bd.setCuffsLeg(1)
		; Bd.Dev_Inv[5] = form_misc.GetAt(2) As Armor
		; Bd.Dev_Ren[5] = form_misc.GetAt(3) as armor
	endevent
	event OnHighlightST()
		SetInfoText("$SLUTS_PonyAnims_Info")
	endevent
endstate

;SlaveTats
state UseSlutsLivery
	event onselectst()
		bUseSlutsLivery = !bUseSlutsLivery
		SetToggleOptionValueST(bUseSlutsLivery)
	endevent
	event ondefaultst()
		bUseSlutsLivery = true
		SetToggleOptionValueST(bUseSlutsLivery)
	endevent
	event onhighlightst()
		SetInfoText("I$SLUTS_UseSlutsLiveryHighlight")
	endevent
endstate

state UseSlutsColors
	event onselectst()
		bUseSlutsColors = !bUseSlutsColors
		SetToggleOptionValueST(bUseSlutsColors)
	endevent
	event ondefaultst()
		bUseSlutsColors = true
		SetToggleOptionValueST(bUseSlutsColors)
	endevent
	event onhighlightst()
		SetInfoText("$SLUTS_UseSlutsColorsHighlight")
	endevent
endstate

state CustomLiveryColor
	event OnColorOpenST()
		SetColorDialogStartColor(iCustomLiveryColor)
	  SetColorDialogDefaultColor(iCustomLiveryColor)
	endEvent
	event OnColorAcceptST(int color)
		iCustomLiveryColor = color
		SetColorOptionValueST(iCustomLiveryColor)
	endEvent
	event OnDefaultST()
		iCustomLiveryColor = 0x0
		SetColorOptionValueST(iCustomLiveryColor)
	endEvent
	event OnHighlightST()
		SetInfoText("$SLUTS_CustomLiveryColorHighlight")
	endEvent
endState

; ==================================
; 				States // Debug
; ==================================
state LargeMsg
	event onselectst()
		bLargeMsg = !bLargeMsg
		SetToggleOptionValueST(bLargeMsg)
	endevent
	event ondefaultst()
		bLargeMsg = false
		SetToggleOptionValueST(bLargeMsg)
	endevent
endstate

State DDStruggle
	Event OnSelectST()
		bStruggle = !bStruggle
		SetToggleOptionValueST(bStruggle)
	EndEvent
EndState
;Debug
state EmergencyTatRemove
	event onselectst()
		sTatRemove = "$SLUTS_Working"
		SetTextoptionValueST(sTatRemove)
		SetOptionFlagsST(OPTION_FLAG_DISABLED)
		ShowMessage("$SLUTS_EmergencyTatRemoveMsg", false, "$SLUTS_Ok")
	endevent
	event onhighlightst()
		SetInfoText("$SLUTS_EmergencyTatRemoveHighlight")
	endevent
endstate

State RemoveDD
	Event OnSelectST()
		sUnponify = "$SLUTS_Working"
		SetTextoptionValueST(sUnponify)
		SetOptionFlagsST(OPTION_FLAG_DISABLED)
		ShowMessage("$SLUTS_removeDDMsg", false, "$SLUTS_Ok")
		Debug.MessageBox("$SLUTS_removeDD_Msg")
	EndEvent

	Event OnHighlightST()
		SetInfoText("$SLUTS_removeDDHighlight")
	EndEvent
EndState

state ReturnCart
	event onselectst()
		sReturnCart = "$SLUTS_Working"
		SetOptionFlagsST(OPTION_FLAG_DISABLED)
		SetTextoptionValueST(sReturnCart)
		ShowMessage("$SLUTS_ReturnCartMsg", false, "$SLUTS_Ok")
		Debug.MessageBox("$SLUTS_dReturnCart_Msg")
	endevent
	event onhighlightst()
		SetInfoText("$SLUTS_ReturnCartHighlight")
	endevent
endstate

; ---------------------------------- Utility
int Function getFlag(bool option)
	If(option)
		return OPTION_FLAG_NONE
	else
		return OPTION_FLAG_DISABLED
	EndIf
endFunction
