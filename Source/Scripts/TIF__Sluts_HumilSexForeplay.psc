;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname TIF__Sluts_HumilSexForeplay Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
SlutsMissionHaul q = getowningquest() as SlutsMissionHaul 

q.humilsex = true
q.sl.QuickStart(q.playerref, akSpeaker, AnimationTags = "Foreplay")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
