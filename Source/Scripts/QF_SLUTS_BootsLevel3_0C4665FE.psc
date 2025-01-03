;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 4
Scriptname QF_SLUTS_BootsLevel3_0C4665FE Extends Quest Hidden

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Anette
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Anette Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
SetObjectiveDisplayed(0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
SetObjectiveCompleted(0)
SetObjectiveDisplayed(10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
Actor PlayerRef = Game.GetPlayer()
Actor Anette = Alias_Anette.GetReference() as Actor

Actor[] tmp = new Actor[2]
If(PlayerRef.GetActorBase().GetSex() == 0) ; male
  tmp[0] = Anette
  tmp[1] = PlayerRef
  SlutsAnimation.StartScene(tmp, "femdom")
else
  tmp[0] = PlayerRef
  tmp[1] = Anette
  SlutsAnimation.ManipulateGender(Anette, 0)
  SlutsAnimation.StartSceneByActors(tmp)
  SlutsAnimation.ManipulateGender(Anette, -1)
EndIf

Dia.upgradeGear(1)
CompleteAllObjectives()
CompleteQuest()
Stop()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

SlutsHQDialogue Property Dia  Auto  
