#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include "mixmod.inc"

public OnPluginStart(){
	HookEvent("player_team", event_playerteam)
}
public event_playerteam(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new new_team = GetEventInt(event, "team");
	
	if(new_team != CS_TEAM_SPECTATOR){
		switch(IsMixmodStarted()){
			case iMixmodStatus_isKo3Running:{
				if(GetTeamClientCount(new_team) >= 1)
				{
					CreateTimer(0.1, Mover, client);
					PrintToChat(client, "\x03[Mix] Fuiste movido a spec");
				}
			}
			case iMixmodStatus_hasMixStarted:{
				if(GetTeamClientCount(new_team) >= 5)
				{
					CreateTimer(0.1, Mover, client);
					PrintToChat(client, "\x03[Mix] Fuiste movido a spec");
				}
			}
		}
	}
}

public Action:Mover(Handle:timer, any:client){
	ChangeClientTeam(client, CS_TEAM_SPECTATOR);
	
	return Plugin_Handled
}