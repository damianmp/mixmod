/*
**
*/
#if defined _mixmod_included
 #endinput
#endif
#define _mixmod_included

enum iMixmodStatus
{
	iMixmodStatus_desconocido = 0,
	iMixmodStatus_isKo3Running,
	iMixmodStatus_hasMixStarted
}

forward RoundStartMixmod(const String:CTName[], const String:TTName[], CTScore, TTScore, g_CurrentHalf, g_CurrentRound);

forward RoundEndMixmod(win_team);

native IsMixmodStarted();

public SharedPlugin __pl_mixmod = 
{
	name = "mixmod",
	file = "mixmod.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};