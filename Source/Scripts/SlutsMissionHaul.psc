Scriptname SlutsMissionHaul extends Quest Conditional
{Main Script for Hauling Quests}

SlutsMain Property Main Auto
SlutsMCM Property MCM Auto
SlutsData Property data Auto
SlutsBondage Property Bd Auto
SexLabFramework Property SL Auto
SlutsEscrow Property Escrow Auto

Actor Property PlayerRef Auto
SlutsMissionHaulPlayer Property PlayerAlias Auto

ReferenceAlias Property DispatcherREF Auto
ReferenceAlias property RecipientREF Auto
ReferenceAlias Property TargetREF Auto
ReferenceAlias Property Manifest Auto
ReferenceAlias Property ScenePlayer Auto ; Where the Player stands in Intro
ReferenceAlias Property SceneSpell Auto ; From where the Carter casts his Spell
ReferenceAlias Property SceneRecipient Auto ; Where the Recipient Waits
ReferenceAlias Property SceneHumilChest Auto ; Recipient Escrow Position

LocationAlias Property RecipientLOC Auto
LocationAlias Property RecipientLOCHold Auto

Keyword Property RootLink Auto ; Driver to Rootnt
Keyword Property EscrowLink Auto ; Root to Escrow
Keyword Property PlayerWaitLoc Auto ; Root to Player Marker
Keyword Property KartSpawnLoc Auto ; Root to Kart Marker
Keyword Property SpellCastLoc Auto ; Root to Spellcast Marker
Keyword Property CarriageDriver Auto ; Root to Driver Wait Marker
; ===
ReferenceAlias Property PackageREF Auto ; Prem Delivery Package
ReferenceAlias Property KartREF Auto ; Used for Dialogue Conditions
Activator Property Kart_Form Auto ; Carts Base Object

GlobalVariable Property MissionType Auto  ; Currently active Mission Type
GlobalVariable Property Payment Auto  ; Base Pay of the current Haul
MiscObject Property FillyCoin Auto
MiscObject Property Gold001 Auto
Message Property DetachKartSureMsg Auto
Message Property ScenePilferageMsg Auto
Message Property PackageDestroyedMsg Auto
Keyword Property ActorTypeNPC Auto

Activator Property SummonFX Auto
Race Property DefaultRace Auto

Quest Property DeliverySelectorQst Auto ; Pick a random NPC from the current Hold
Scene Property moveChestScene Auto ; Post Humiliation reward

Faction Property SlutsCrime Auto ; Sluts Crime Faction
Faction Property DriverFaction Auto ; All Drivers
Faction Property DirtyFaction Auto ; For Dirt Tats
Faction Property PlayerFollowerFaction Auto
Faction Property BanditFaction Auto
Faction property ForswornFaction Auto
Faction[] Property FriendFactions Auto

; Worldspaces
Worldspace Property Tamriel Auto
Worldspace Property Solstheim Auto
ObjectReference Property windhelmPort Auto
ObjectReference Property ravenRockPort Auto
; Holds
Location Property EastmarchHoldLocation auto
Location Property HaafingarHoldLocation auto
Location Property ReachHoldLocation auto
Location Property RiftHoldLocation auto
Location Property WhiterunHoldLocation auto
Location Property FalkreathHoldLocation auto
Location Property PaleHoldLocation auto
Location Property HjaalmarchHoldLocation auto
Location Property WinterholdHoldLocation auto

ImageSpaceModifier Property FadeToBlackImod Auto
ImageSpaceModifier Property FadeToBlackBackImod Auto
ImageSpaceModifier Property FadeToBlackHoldImod Auto

Faction YK_Ignored

; ---------------------------------- Variables
String Property CartDefault = "CartHaul" AutoReadOnly Hidden
String PRoperty Delivery = "SpecialDelivery" AutoReadOnly Hidden

float Property SkyrimDiameter = 311231.0 AutoReadOnly Hidden  ; Distance between 2 Drivers frutherst away from each other

; Keybinds
int ActivateKey

; Series Info
int Property Streak Auto Hidden Conditional ; Num Hauls the Player did this series
float PerfectStreak
float TotalPay

; Haul Info
float Property GoodsTotal = 1500.0 AutoReadOnly Hidden ; Amount of Goods total
float Property KartHealth = 100.0 AutoReadOnly Hidden ; Amount of Damage the can Kart beyond GoodsTotal
float Property Pilferage = 0.0 Auto Hidden Conditional ; Lost goods

int Property MissionComplete Auto Hidden Conditional  ; To keep track of mission progress for multi objective missions

int Property PremiumDeliveryDelay Auto Hidden Conditional ; 0 Early | 1 On Time | 2 Too Late
int Property PremiumPackageStatus Auto Hidden Conditional ; 0 NoDmg | 1 Light Dmg | 2 Heavy Dmg | 3 Destroyed
int Property PackageStatusLightDmg = 300 AutoReadOnly Hidden ; Pilferage at which Package is considered damaged
int Property PackageStatusHeavyDmg = 900 AutoReadOnly Hidden

; Humiliation System
bool Property HumiliatedOnce = false Auto Hidden Conditional  ; Set after 1st Humiliation. Dialogue flag
bool Property Humiliated = false Auto Hidden Conditional
int Property HumilPick = 0 Auto Hidden Conditional
; 0 - Nothing, free to go
; 1 - DD Boots
; 2 - BURN ALL HOBBLEDRESSES
; 3 - Piercings
; 4 - Give up part of your payment
; 5 - Unused
; 6 - Unused
; 7 - Unused
; 8 - Fallback - Sell yourself to the Driver

; Tether System
bool Property bIsThethered Auto Hidden Conditional
SlutsKart Property Kart Auto Hidden

int Property Response_Flawless = 0 AutoReadOnly Hidden      ; 0 Pilferage + No Debt
int Property Response_Deduction = 1 AutoReadOnly Hidden     ; X Pilferage + No Debt
int Property Response_Endebted = 2 AutoReadOnly Hidden      ; No Pay + Init Debt
int Property Response_ReduceDebt1 = 3 AutoReadOnly Hidden   ; 0 Pilferage + Debt
int Property Response_ReduceDebt2 = 4 AutoReadOnly Hidden   ; X Pilferage + Debt
int Property Response_DebtStacking = 5 AutoReadOnly Hidden  ; No Pay + Stacking Debt
int Property Response_DebtDone = 6 AutoReadOnly Hidden      ; Debt fully payed off
int Property EvalResponse Auto Hidden Conditional

; misc
bool forced

; ======================================================
; =============================== NEW HAUL
; ======================================================
;/ A new Haul always starts with this Quest. This Quest is active from beginning of a Haul to end and store the Objectives as well as generic Dialogue
/;
Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akDispatcher, ObjectReference akRecipient, int aiCustomLoc, int aiForced)
  Debug.Trace("[SLUTS] Started new Haul")
  Escrow.lockEscrow()
  SetMissionState()
  forced = aiForced
  If (!SetLinks(akDispatcher, akRecipient))
    Stop()
    return
  ElseIf(!RecipientLocHOLD.GetLocation())
    RecipientLOCHold.ForceLocationTo(GetHold(RecipientLOC))
  EndIf

  float p = 1 - (aiCustomLoc * 0.15) ; 15% Payment Deduction for Custom Loc Hauls
  Payment.SetValue(GetBasePay(akDispatcher, akRecipient, p))
  UpdateCurrentInstanceGlobal(Payment)
  Debug.Trace("[SLUTS] Payment = " + Payment.GetValueInt())

  ActivateKey = Input.GetMappedKey("Activate")
  RegisterEvents()
  HumilPick = Utility.RandomInt(0, 8)
  TotalPay = 0.0

  Debug.Trace("[SLUTS] Haul Preparations done, SetStage 5")
  SetStage(5)
EndEvent

bool Function SetLinks(ObjectReference akDispatcher, ObjectReference akRecipient)
  ObjectReference root0 = StorageUtil.GetFormValue(akDispatcher, "SLUTS_ROOT") as ObjectReference
  ObjectReference root1 = StorageUtil.GetFormValue(akRecipient, "SLUTS_ROOT") as ObjectReference
  If(!root0 || !root1)
    Debug.TraceStack("[SLUTS] Missing Root | " + root0 + " | " + root1, 2)
    Debug.MessageBox("Unable to create Haul. Root Object is missing.")
    return false
  EndIf
  ScenePlayer.ForceRefTo(root0.GetLinkedRef(PlayerWaitLoc))
  SceneSpell.ForceRefTo(root0.GetLinkedRef(SpellCastLoc))
  SceneRecipient.ForceRefTo(root1.GetLinkedRef(CarriageDriver))
  SceneHumilChest.ForceRefTo(root1.GetLinkedRef(EscrowLink))
  return true
EndFunction

Function SetMissionState(int missionID = -1)
  String[] missions = new String[2]
  missions[0] = CartDefault
  missions[1] = Delivery
  If (missionID < 0)
    missionID = SlutsData.Distribute(MCM.HaulWeights) - 1
  EndIf
  If(missions[missionID] != GetState())
    GoToState(missions[missionID])
    MissionType.SetValueInt(missionID)
  EndIf
EndFunction

Function RegisterEvents()
  RegisterForKey(ActivateKey)
  RegisterForModEvent("HookAnimationStart", "OnAnimStart")
	RegisterForModEvent("HookAnimationEnd", "OnAnimEnd")
endFunction

Function Blackout()
  FadeToBlackImod.Apply()
  Utility.Wait(2)
  FadeToBlackImod.PopTo(FadeToBlackHoldImod)
EndFunction

Function StripPlayer()
  int intmax = 2147483647
  Keyword SLSLicense = Keyword.GetKeyword("_SLS_LicenceDocument")
  Form[] items = PlayerRef.GetContainerForms()
  int i = 0
  While(i < items.Length)
    Keyword[] kw = items[i].GetKeywords()
    If (!kw.Length || kw.Find(bd.SlutsRestraints) == -1 && kw.Find(SLSLicense) == -1)
      PlayerRef.RemoveItem(items[i], intmax, true, Escrow)
    EndIf
    i += 1
  EndWhile
EndFunction

Function SetupHaul()
  DispatcherREF.GetReference().MoveTo(SceneSpell.GetReference())
  PlayerRef.MoveTo(ScenePlayer.GetReference())
  PlayerRef.PlaceAtMe(SummonFX)
  StripPlayer()
  SetupHaulImpl()
  Pilferage = 0.0

  If(Game.GetModByName("YameteKudasai.esp") != 255)
    YK_Ignored = Game.GetFormFromFile(0x9F9D1E, "YameteKudasai.esp") as Faction
    PlayerRef.AddToFaction(YK_Ignored)
  EndIf
EndFunction
Function SetupHaulImpl()
  Debug.TraceStack("[SLUTS] Function call outside a valid State = " + GetState(), 2)
EndFunction

State CartHaul
  Function SetupHaulImpl()
    Debug.Trace("[SLUTS] Setting up Cart Haul")
    TargetREF.ForceRefTo(RecipientREF.GetReference())
    If(!Kart)
      Kart = SlutsMain.GetLink(DispatcherREF.GetReference(), KartSpawnLoc).PlaceAtMe(Kart_Form) as SlutsKart
      KartRef.ForceRefTo(Kart)
      Kart.SetUp()
      Utility.Wait(0.5)
    Else ; Chain Haul, make sure the Kart can actually be moved
      Kart.SetMotionType(Kart.Motion_Dynamic)
      If(Kart.GetDistance(PlayerRef) > 750)
        bIsThethered = false
      EndIf
    EndIf
    Tether()
    Bd.DressUpPony(PlayerRef)
    PlayerAlias.GoToState(CartDefault)
  EndFunction
  
  Event OnEndState()
    If(Kart)
      Untether()
      KartRef.Clear()
      Kart.Disable()
      Kart.Delete()
      Kart.ShutDown()
      Kart = none
    EndIf
  EndEvent
EndState

State SpecialDelivery
  Function SetupHaulImpl()
    Debug.Trace("[SLUTS] Setting up Special Delivery")
    If(Main.myDrivers.Find(RecipientREF.GetActorReference()) == 9)
      RecipientREF.ForceRefTo(Main.myDrivers[4])
    EndIf
    If(!DeliverySelectorQst.Start())
      Debug.Trace("[SLUTS] Failed to find Target. Fallback to " + CartDefault)
      SetMissionState(0)
      return
    EndIf
    ReferenceAlias target = DeliverySelectorQst.GetAliasById(3) as ReferenceAlias
    ObjectReference tref = target.GetReference()
    Debug.Trace("[SLUTS] Found Target for Package Delivery = " + tref)
    TargetREF.ForceRefTo(tref)
    RecipientLOC.ForceLocationTo(tref.GetCurrentLocation())
    PlayerAlias.GoToState(Delivery)
    DeliverySelectorQst.Stop()
    ; TODO: Look for artist for some kinda bag equipping
    Bd.DressUpPony(PlayerRef, false)
    PlayerRef.AddItem(PackageREF.GetReference())
    ; Total Dur from Riften to Solitude = ~30min -> ~10k Distance every Minute
    PremiumDeliveryDelay = 0
    float d = DispatcherREF.GetReference().GetDistance(RecipientREF.GetReference())
    int segments = Math.Ceiling(d / 10000)
    RegisterForUpdate(segments * 40)
  EndFunction

  Event OnUpdate()
    PremiumDeliveryDelay += 1
  EndEvent

  Event OnEndState()
    PlayerAlias.GoToState("")
    ; TODO: Once bag implemented, remove it here again
  EndEvent
EndState

Function TakePackage()
  PlayerRef.RemoveItem(PackageREF.GetReference())
  If(PremiumDeliveryDelay > 1)
    Pilferage += (GoodsTotal / 5) * (PremiumDeliveryDelay - 1)
  ElseIf(PremiumPackageStatus == 0)
    Pilferage = 0.0
  EndIf
  DoPayment()
EndFunction

Function CheckPackageStatus()
  If(Pilferage < PackageStatusLightDmg)
    PremiumPackageStatus = 0 ; No Damage
  ElseIf(Pilferage < PackageStatusHeavyDmg)
    PremiumPackageStatus = 1 ; Light Damage
  ElseIf(Pilferage < GoodsTotal)
    PremiumPackageStatus = 2 ; Heavy Damage
  Else
    PremiumPackageStatus = 3 ; Destroyed
    If(PlayerRef.GetItemCount(PackageREF.GetReference()) > 0)
      PackageDestroyedMsg.Show()
      PlayerRef.RemoveItem(PackageREF.GetReference(), 1, true)
    EndIf
  EndIf
EndFunction

; ======================================================
; =============================== EVALUATION
; ======================================================

float overtimepay ; Accumulated payments over a series of perfect hauls 
int Property qstage Auto Hidden

Function HandleStage()
  If(MissionComplete < 1)
    return
  EndIf
  MissionComplete = 0 - MissionType.GetValueInt()
  int stage = 21 + MissionType.GetValueInt()
  If(stage != qstage)
    SetObjectiveDisplayed(qstage, false, true)
  EndIf
  qstage = stage
  If(IsObjectiveCompleted(qstage))
    SetObjectiveCompleted(qstage, false)
  EndIf
  SetObjectiveDisplayed(qstage, true, true)
EndFunction

Function Fail()
  MissionComplete = 1
  pilferage = GoodsTotal + KartHealth
  DoPayment()
EndFunction

Function CreateChainMission(bool abForced, int aiMissionID = -1)
  Actor recip = RecipientREF.GetReference() as Actor
  Actor next = Main.GetDestination(recip, DispatcherREF.GetActorReference())
  Debug.Trace("[SLUTS] Attempting Chain Mission with new Dispatcher = " + recip + " | Recipient = " + next)
  If (!SetLinks(recip, next))
    Quit()
    return
  EndIf
  forced = abForced
  DispatcherREF.ForceRefTo(recip)
  RecipientREF.ForceRefTo(next)
  RecipientLOC.ForceLocationTo(Main.myDestLocs[Main.myDrivers.Find(next)])
  RecipientLOCHold.ForceLocationTo(GetHold(RecipientLOC))
  SetMissionState(aiMissionID)
  SetupHaulImpl()
  Payment.SetValue(GetBasePay(recip, next, 1.0))
  UpdateCurrentInstanceGlobal(Payment)
  Debug.Trace("[SLUTS] ChainMission; Payment = " + Payment.GetValueInt())
  Pilferage = 0.0
  ; ChainScene.ForceStart()
  Manifest.GetReference().Activate(PlayerRef)
  Utility.Wait(0.1)
  FadeToBlackHoldImod.PopTo(FadeToBlackBackImod)
  Game.SetPlayerAIDriven(false) ; Unsure why this is needed, zz
  SetStage(20)
EndFunction

; Assume there to be a Blackout right here
Function Quit()
  data.SeriesCompleted()
  PlayerRef.RemoveItem(Manifest.GetReference(), abSilent = true)
  ; Clear State & get Player out of gear
  PlayerRef.PlaceAtMe(SummonFX)
  GoToState("")
  Bd.UndressPony(PlayerRef, false)
  Game.EnableFastTravel()
  FadeToBlackHoldImod.PopTo(FadeToBlackBackImod)
  ; Enable post haul Dialogue & place Escrow
  If (overtimepay > 0)
    int coins = Math.Floor(overtimepay * GetOvertimeBonus())
    Escrow.AddItem(FillyCoin, coins)
  EndIf
  ObjectReference spawn
  If (data.licenseEscrowPort > 0)
    spawn = SlutsMain.GetLink(RecipientREF.GetReference(), EscrowLink)
    data.licenseEscrowPort -= 1
  Else
    spawn = SlutsMain.GetLink(DispatcherREF.GetReference(), EscrowLink)
  EndIf
  Escrow.MoveTo(spawn)
  Escrow.Lock(false)

  If(YK_Ignored)
    PlayerRef.RemoveFromFaction(YK_Ignored)
  EndIf
EndFunction


; ======================================================
; =============================== PAYMENT
; ======================================================

float Function GetBasePay(ObjectReference akDisp, ObjectReference akRecip, float mult = 1.0)
  Worldspace ref2Space = akRecip.GetWorldSpace()
  float distance
  int base = 0
  If(akDisp.GetWorldSpace() == ref2Space)
    distance = akDisp.GetDistance(akRecip)
  Else ; Not same Worldspace, give a 40k Basepay and check Distance from a Port
    If(ref2Space == Tamriel)
      distance = windhelmPort.GetDistance(akRecip)
    ElseIf(ref2Space == Solstheim)
      distance = ravenRockPort.GetDistance(akRecip)
    Else ; If in a modded Worldspace dont bother about calculus, just return some random number
      return Utility.RandomInt(27500, 45000)
    EndIf
  EndIf
  ; Explanation: https://www.loverslab.com/topic/146751-sluts-resume/page/14/#comment-3357294
  ; V3: Hardcoding M = 2 | Division 10 -> 25
  float ret = (Math.pow(Math.sqrt((0.5 * distance) / SkyrimDiameter), -1.0) * distance) / 25
  return ret * mult
EndFunction

float Function GetOvertimeBonus()
  If(SlutsCrime.GetCrimeGold() > 0 || PerfectStreak == 0)
    return 0
  else
    ; Explanation: https://www.loverslab.com/topic/146751-sluts-resume/page/15/#comment-3360719
    ; V3: Hardcoding M = 1
    float ret
    If(PerfectStreak < 15)
      ret = Math.pow(1.4, (0.3 * PerfectStreak)) - 1
    else
      ret = 5 ; MCM.fOvertimeGrowth * 5
    EndIf
    ; notify("Having agreed to " + streakPerfect + " hauls in a row your overtime bonus is now " + bonusPerCent + "%")
    Debug.Trace("Overtime Bonus: " + (ret * 100) + "%")
    return ret
  EndIf
EndFunction

Function DoPayment()
  Streak += 1
  data.RunCompleted(Pilferage == 0)
  ; Finalize Payment, payout to Escrow Chest, get response type
  int crime = SlutsCrime.GetCrimeGold()
  int pay = Payment.GetValueInt()
  If(Pilferage == 0)
    overtimepay += pay
    PerfectStreak += 1
    If(crime == 0)
      EvalResponse = Response_Flawless
    ElseIf(crime <= pay)
      EvalResponse = Response_DebtDone
    Else
      EvalResponse = Response_ReduceDebt1
    EndIf
  Else
    float mult = (Pilferage / GoodsTotal) * 5
    pay -= Math.Floor(mult * pay)
    overtimepay = 0
    PerfectStreak = 0
    If (crime == 0)
      If (mult < 1)
        EvalResponse = Response_Deduction
      Else
        EvalResponse = Response_Endebted
      EndIf
    Else
      If(crime <= pay)
        EvalResponse = Response_DebtDone
      ElseIf(mult < 1)
        EvalResponse = Response_ReduceDebt2
      Else
        EvalResponse = Response_DebtStacking
      EndIf
    EndIf
  EndIf
  Debug.Trace("[SLUTS] Eval Response = " + EvalResponse)
  If(pay > 0) ; Made profit
    If(crime > pay)
      SlutsCrime.ModCrimeGold(-pay)
      pay = 0
    ElseIf(crime > 0)
      SlutsCrime.SetCrimeGold(0)
      pay -= crime
    EndIf
    Escrow.AddItem(FillyCoin, pay, true)
  ElseIf(pay < 0) ; Made losses
    SlutsCrime.ModCrimeGold(-pay)
  EndIf
  Debug.Trace("[SLUTS] Post Eval => Payment = " + pay + " | Debt = " + SlutsCrime.GetCrimeGold() + " | Overtime Bonus = " + overtimepay)
  TotalPay += pay
  ; Payment = {} | Debt = {} | Overtime Bonus = {}
EndFunction

; ======================================================
; =============================== HAUL START0
; ======================================================
Function TransferManifest()
  ObjectReference Paper = Manifest.GetReference()
  DispatcherRef.GetReference().RemoveItem(Paper, 1, true, PlayerRef)
EndFunction

Function ShowManifest()
  Manifest.GetReference().Activate(PlayerRef)
  Bd.EquipIdx(Bd.gagIDX)
endFunction

; ======================================================
; =============================== PAYMENT
; ======================================================

Function spontaneousFailure()
  if (pilferage == 0 && Utility.RandomInt(1,100) <= mcm.iSpontFail)
  	if mcm.bSpontFailRandom
  		;Deliberately set the chance above the 120 maximum. Overwise max would only have a 1 in 120 chance of happening.
  		pilferage = (Utility.RandomInt(825,2400))
  		if pilferage > 1800
  			pilferage = 1800
  		endif
  	else
  		pilferage = 1800
  	endif
    string X = ""
    if pilferage < 1500
  		X = "some of your cargo appears to be missing"
  	elseif pilferage < 1800
  		X = "much of your cargo is missing"
  	else
  		X = "your cargo is completely gone"
  	endif
  	Debug.Messagebox("In a moment of absent mindedness you glance behind you, only to notice to your horror that " + X + "! You have no idea what happened and can only shudder in a cold sweat knowing you will still have to answer for it...")
  endif
EndFunction


; ======================================================
; =============================== KEYCODES
; ======================================================
Event OnKeyDown(int KeyCode)
  If(Utility.IsInMenuMode())
		return
  EndIf
  bool Ctrl = Input.IsKeyPressed(29) || Input.IsKeyPressed(157)
  If(!Ctrl || !Kart || PlayerRef.IsInInterior())
    return
  EndIf
  Debug.Trace("[SLUTS] Key Down")
  If(KeyCode == ActivateKey)
    If(!bIsThethered)
      Tether()
      Bd.RemoveIdx(Bd.yokeIDX, true)
      Bd.EquipIdx(Bd.yokeIDX, true)
    Else
      If(DetachKartSureMsg.Show() == 0)
        Unhitch()
      EndIf
    EndIf
  EndIf
EndEvent

; ======================================================
; =============================== TETHER
; ======================================================

Function Tether()
  If(!Kart || bIsThethered)
    return
  EndIf
  bIsThethered = true
  Debug.Trace("[SLUTS] Attempting to tether..")

  If(Kart.GetDistance(PlayerRef) > 500)
    Kart.SetMotionType(Kart.Motion_Keyframed)
    Game.DisablePlayerControls()
    Debug.SetGodMode(true)  ; To avoid the cart physics killing the player
    ObjectReference tmp = PlayerRef.PlaceAtMe(FillyCoin, aiCount = 1, abInitiallyDisabled = true)
    tmp.MoveTo(PlayerRef, -258.0 * Math.Sin(PlayerRef.GetAngleZ()), -258.0 * Math.Cos(PlayerRef.GetAngleZ()))
    Utility.Wait(0.3)
    Kart.MoveTo(tmp)
    Utility.Wait(0.2)
    Kart.SetMotionType(Kart.Motion_Dynamic)
    Debug.SetGodMode(false)
    Game.EnablePlayerControls()
  EndIf

  Race r = PlayerRef.GetRace()
  PlayerRef.SetRace(DefaultRace)
  PlayerRef.SetRace(r)
  Utility.Wait(0.25)
  Kart.TetherToHorse(PlayerRef)
  Game.EnableFastTravel(false)
EndFunction

Function OnLoadTether()
  RegisterEvents()
  If(!bIsThethered || !Kart || PlayerRef.IsInInterior())
    return
  EndIf
  ; Tether will always come loose when reloading
  bIsThethered = false
  Tether()
EndFunction

Function Untether()
  If(!bIsThethered)
    return
  ElseIf(Kart.Is3DLoaded())
    Kart.Disable()
    Utility.Wait(0.1)
    Kart.Enable()
  EndIf
  Debug.Trace("[SLUTS] Untethered Kart")
  bIsThethered = false
  Game.EnableFastTravel(true)
endFunction

Function Unhitch()
  If(!bIsThethered)
    return
  EndIf
  Debug.Notification("Attempting to untether..")
  If(MCM.bStruggle)
    Bd.Lib0.abq.StruggleScene(PlayerRef)
  EndIf
  Untether()
endFunction

; ======================================================
; =============================== SEXLAB
; ======================================================

Event OnAnimStart(int tid, bool HasPlayer)
  If(!HasPlayer || GetStage() != 20 || GetState() != CartDefault)
    return
  EndIf
  Untether()
EndEvent

Event OnAnimEnd(int tid, bool HasPlayer)
  sslThreadController Thread = SL.GetController(tid)
  If(Thread.GetHooks().Find("SLUTS_Humil") > -1)
    Debug.Trace("[SLUTS] Humiliation Scene End")
    Utility.Wait(0.2)
    moveChestScene.Start()
    return
  ElseIf(!MCM.bCargoAssault || !Thread.IsVictim(PlayerRef) || GetStage() != 20)
    Debug.Trace("[SLUTS] Scene End Pilferage is disabled or Player is not Victim")
    return
  EndIf
  Debug.Trace("[SLUTS] Piferage at Scene End | Pre = " + Pilferage)
  int type = 0
  int i = 0
  While(i < Thread.Positions.Length)
    Actor p = Thread.Positions[i]
    If(p.IsPlayerTeammate() || p.IsInFaction(DriverFaction))
      return
    ElseIf(p.IsInFaction(BanditFaction) || p.IsInFaction(ForswornFaction))
      type = 1
    ElseIf(p.GetActorValue("Morality") < 2)
      type = 2 + p.GetActorValue("Morality") as int
    EndIf
    i += 1
  EndWhile
  If(type == 1 || type > 2 && Utility.RandomInt(0, 99) < 40 * (1 + Math.pow(type, -1)))
    float robbed = Utility.RandomFloat(5 + Thread.Positions.length, 15 + Thread.Positions.length)
    Pilferage += GoodsTotal * (robbed / 100)
    If(Pilferage > GoodsTotal * 1.1)
      Pilferage = GoodsTotal * 1.1
    EndIf
    ScenePilferageMsg.Show(Pilferage, GoodsTotal)
  EndIf
  Debug.Trace("[SLUTS] Piferage at Scene End | Post = " + Pilferage)
endEvent

; ======================================================
; =============================== HUMILIATION
; ======================================================

; HumilPick = 4
Function debitRate()
  float dR = Utility.RandomFloat(0.05, 0.35)
  int debit = Math.Floor(TotalPay * dR)
  Escrow.RemoveItem(FillyCoin, debit)
  data.notify(Math.Floor(dR * 100) + "% has been debited from your last payout")
EndFunction

function fondle(Message msg=none, float increment=5.0)
; 	if msg == none
; 		msg = msg_stroke_flank
; 	endif
; 	msg.show()
; 	int eid = ModEvent.Create("slaUpdateExposure")
; 	ModEvent.PushForm(eid, PlayerREf)
; 	ModEvent.PushFloat(eid, increment)
; 	ModEvent.Send(eid)
endfunction

Function HumilChest()
  HumiliatedOnce = true
  Escrow.MoveTo(SceneHumilChest.GetReference())
endFunction

; ======================================================
; =============================== UTILITY
; ======================================================
; Function Dirtify()
;   If(!MCM.bUseDirt)
;     return
;   EndIf
;   int L = PapyrusUtil.ClampInt(PlayerRef.GetFactionRank(DirtyFaction) + 1, 1, 10)
; 	;slavetats.simple_add_tattoo(pc, "Dirty S.L.U.T.S.", "Dirty Head " + level, last = false, silent = true )
; 	;slavetats.simple_add_tattoo(pc, "Dirty S.L.U.T.S.", "Dirt " + level, last = true, silent = true )
; 	PlayerRef.SetFactionRank(DirtyFaction, L)
; 	mcm.TatLib.set_dirty_level(PlayerRef, L)
; endfunction

Function Befriend()
  int i = 0
  While(i < FriendFactions.length)
    PlayerRef.AddToFaction(FriendFactions[i])
    i += 1
  EndWhile
EndFunction

Function Unfriend()
  int i = 0
  While(i < FriendFactions.length)
    PlayerRef.RemoveFromFaction(FriendFactions[i])
    i += 1
  EndWhile
EndFunction

Location Function GetHold(LocationAlias myDest)
  Location myLoc = myDest.GetLocation()
  If(!myLoc)
    Debug.Trace("[SLUTS] DefaultHaul: Null Location passed, abandon \"GetHold\"")
    return none
  EndIf
  Debug.Trace("[SLUTS] DefaultHaul: Getting Hold for: " + myLoc.GetName())
  If(EastmarchHoldLocation.IsChild(myLoc))
    Debug.Trace("[SLUTS] Hold identified: Windhelm")
    return EastmarchHoldLocation
  ElseIf(HaafingarHoldLocation.IsChild(myLoc))
		Debug.Trace("[SLUTS] Hold identified: Solitude")
		return HaafingarHoldLocation
  ElseIf(ReachHoldLocation.IsChild(myLoc))
		Debug.Trace("[SLUTS] Hold identified: Markarth")
		return ReachHoldLocation
  ElseIf(RiftHoldLocation.IsChild(myLoc))
		Debug.Trace("[SLUTS] Hold identified: Riften")
		return RiftHoldLocation
  ElseIf(WhiterunHoldLocation.IsChild(myLoc))
		Debug.Trace("[SLUTS] Hold identified: Whiterun")
		return WhiterunHoldLocation
  ElseIf(FalkreathHoldLocation.IsChild(myLoc))
		Debug.Trace("[SLUTS] Hold identified: Falkreath")
		return FalkreathHoldLocation
  ElseIf(PaleHoldLocation.IsChild(myLoc))
		Debug.Trace("[SLUTS] Hold identified: Dawnstar")
		return PaleHoldLocation
  ElseIf(HjaalmarchHoldLocation.IsChild(myLoc))
		Debug.Trace("[SLUTS] Hold identified: Morthal")
		return HjaalmarchHoldLocation
  ElseIf(WinterholdHoldLocation.IsChild(myLoc))
		Debug.Trace("[SLUTS] Hold identified: Winterhold")
		return WinterholdHoldLocation
  endIf
	return none
endfunction

