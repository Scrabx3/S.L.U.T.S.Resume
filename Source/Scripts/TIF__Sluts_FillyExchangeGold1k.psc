;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname TIF__Sluts_FillyExchangeGold1k Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
Actor PlayerRef = Game.GetPlayer()

PlayerRef.AddItem(Gold001, 1000)
PlayerRef.RemoveItem(FillyCoins, 100000, true)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

MiscObject Property Gold001  Auto  

MiscObject Property FillyCoins  Auto  
