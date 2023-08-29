#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include "mixmod.inc"

new g_ClientsScore[MAXPLAYERS + 1] =  { 0, ... };
new g_ClientsDeath[MAXPLAYERS + 1] =  { 0, ... };

public OnMapStart(){
	for (new i=0; i<=MaxClients; i++)
	{
		g_ClientsScore[i] = 0;
		g_ClientsDeath[i] = 0;
	}
}

public RoundStartMixmod(const String:CTName[], const String:TTName[], CTScore, TTScore, g_CurrentHalf, g_CurrentRound){
	switch(IsMixmodStarted()){
		case iMixmodStatus_hasMixStarted:{
			
			SetTeamScore(CS_TEAM_CT, CTScore);
			SetTeamScore(CS_TEAM_T, TTScore);	
			
			for (new i=1; i<=MaxClients; i++)
			{
				if(IsClientInGame(i)){
					SetEntProp(i, Prop_Data, "m_iFrags", g_ClientsScore[i]);
					SetEntProp(i, Prop_Data, "m_iDeaths", g_ClientsDeath[i]);
				}	
			}
		}
	}
}

public OnClientDisconnect(client){
	switch(IsMixmodStarted()){
		case iMixmodStatus_hasMixStarted:{
			g_ClientsScore[client] = 0;
			g_ClientsDeath[client] = 0;
		}
	}
}

public RoundEndMixmod(win_team){
	for (new i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i)){
			
			new frag = GetEntProp(i, Prop_Data, "m_iFrags");
			new death = GetEntProp(i, Prop_Data, "m_iDeaths");
			
			g_ClientsScore[i] = frag;
			g_ClientsDeath[i] = death;
			
			//PrintToServer("%N) %i | %i",i, g_ClientsScore[i], g_ClientsDeath[i]);
		}
	}
}