#include <sourcemod>
#include <cstrike>
#include "mixmod.inc"

/*public OnPluginStart(){
	HookEvent("round_start", Event_RoundStart);
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	char CTName[255];
	char TTName[255];
	GetNombres(CTName, sizeof(CTName), TTName, sizeof(TTName));
	
	PrintToServer("CTName: %s | TTName: %s", CTName, TTName);
	
	SetConVarString(FindConVar("sm_mixmod_custom_name_ct"), CTName);
	SetConVarString(FindConVar("sm_mixmod_custom_name_t"), TTName);
}*/

public RoundStartMixmod(const String:CTName[], const String:TTName[], CTScore, TTScore, g_CurrentHalf, g_CurrentRound){
	//PrintToServer("CTName: %s | TTName: %s | CTScore: %i | TTScore: %i | g_CurrentHalf: %i", CTName, TTName, CTScore, TTScore, g_CurrentHalf);
	
	new String:aux[255];
	
	switch(IsMixmodStarted()){
		case iMixmodStatus_isKo3Running:{
			Format(aux, sizeof(aux), "Ronda Cuchi! [ %s vs %s ]", CTName, TTName);
			SetConVarString(FindConVar("hostname"), aux);
		}
		case iMixmodStatus_hasMixStarted:{
			Format(aux, sizeof(aux), "Ronda %i Parte %i [ %s(%i) vs %s(%i) ]", g_CurrentRound, g_CurrentHalf, CTName, CTScore ,TTName, TTScore);	
			SetConVarString(FindConVar("hostname"), aux);
		}
	}
}

public RoundEndMixmod(win_team){
	//PrintToServer("\t\t WIN: %i", win_team);
}

void GetNombres(char[] NCT, int iNCT , char[] NTT, int iNTT){
	
	int team = 0;
	bool ctok = false;
	bool ttok = false;
	
	for (int i = 1; i < MaxClients; i++){
		if(IsClientConnected(i)){
			team = GetClientTeam(i);
			if(team >= CS_TEAM_T){
				if(team == CS_TEAM_T && !ttok){
					GetClientName(i, NTT, iNTT);
					
					Format(NTT, iNTT, "%s (T)", NTT);
					
					ttok = true;
				}
				else if(team == CS_TEAM_CT && !ctok){
					GetClientName(i, NCT, iNCT);
					
					Format(NCT, iNCT, "%s (CT)", NCT);
					
					ctok = true;
				}
			}
			if(ctok && ttok){
				break;
			}
		}
	}
}