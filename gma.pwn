#include <a_samp>
#include <ZCMD>
#include <a_players>
#include <a_vehicles>
#include <a_mysql>
#include <sscanf>


main()
{
	print("\n----------------------------------");
	print(" Blank Gamemode by your name here");
	print("----------------------------------\n");
}

#if defined MAX_PLAYERS
#undef MAX_PLAYERS
#endif
#define MAX_PLAYERS 550

#define MAX_PLOBBY 4
new Activate[30];
new Popchase[30][MAX_PLOBBY];
new Lobby[30];
new AL[30];
new Adv[144];
new CountLobby[30];
new TimersLobby[30];
new EndLobby[30];
new MySQL: sql;
new Float:LobbyX, Float:LobbyY, Float:LobbyZ;
new Suspect[30];
new PlayerText:LobbyTD[MAX_PLAYERS][8];
new PlayerText:SuspectUI[MAX_PLAYERS][MAX_PLOBBY];
new PlayerText:SusUI[MAX_PLAYERS][MAX_PLOBBY];
new LobbyName[30][MAX_PLOBBY][MAX_PLAYER_NAME];
new ActionLobby[30][MAX_PLOBBY];
new PlayerText:MenuUI[MAX_PLAYERS][2];

enum PI
{
	Lb,
	Money,
	Donate,
	ID,
	Login,
	Admin,
	Skin,
}

new PlayerInfo[MAX_PLAYERS][PI];

public TimerLobby(number)
{
	format(Adv, 144, "До запуска лобби №%i осталось %i секунд.", number, CountLobby[number]);
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(PlayerInfo[i][Lb] == number)
	    SendClientMessage(i, 0xFF000000, Adv);
	}
	CountLobby[number]--;
	if(CountLobby[number] == 0)
	{
		if(Lobby[number] < 2)
		{
		    format(Adv, 144, "В лобби №%i слишком мало людей, лобби отключено!", number);
		    KillTimer(TimersLobby[number]);
		    AL[number] = 1;
		}
		else
		{
		    format(Adv, 144, "Лобби №%i запущено!", number);
			new Alo = 0;
		    new LobbyPlayers[MAX_PLOBBY];
		    KillTimer(TimersLobby[number]);
		    new K;
		    while(K == 0)
		    {
				for(new i = 0; i < MAX_PLOBBY; i++)
				{
				    if(Popchase[number][i] == -1)
					{
					    LobbyPlayers[Alo] = i;
						Alo++;
						continue;
					}
					else if(Popchase[number][i] > -1)
					{
					    Suspect[number] = Popchase[number][i];
					    SendClientMessage(Popchase[number][i], 0xFF000000, "Вы подозреваемый!");
					    break;
					}
				}
				break;
			}
		    new RandomSpawn[4];
			for(new i = 0; i < MAX_PLOBBY; i++)
			{
			    if(Popchase[number][i] == -1) continue;
				mu:
				switch(random(4))
				{
				    case 0:
					{
						if(RandomSpawn[0] == 0)
						{
							RandomSpawn[0] = 1;
							new vehicles;
							vehicles = CreateVehicle(598, 2092.0852,1362.2789,10.8203, 0, 0, 0, 0);
							SetVehicleVirtualWorld(vehicles, number);
							PutPlayerInVehicle(Popchase[number][i], vehicles, 0);
						}
						else
						{
						    goto mu;
						}
					}
				    case 1:
					{
						if(RandomSpawn[1] == 0)
						{
							RandomSpawn[1] = 1;
							new vehicles;
							vehicles = CreateVehicle(598, 2176.9316,1362.7762,10.8203,273.2155, 0, 0, 0, 0);
							SetVehicleVirtualWorld(vehicles, number);
							PutPlayerInVehicle(Popchase[number][i], vehicles, 0);
						}
						else
						{
			   				goto mu;
						}
					}
				    case 2:
					{
					    if(RandomSpawn[2] == 0)
						{
							RandomSpawn[2] = 1;
							new vehicles;
							vehicles = CreateVehicle(598, 2176.6548,1205.9191,10.8203,181.7213, 0, 0, 0, 0);
							SetVehicleVirtualWorld(vehicles, number);
							PutPlayerInVehicle(Popchase[number][i], vehicles, 0);
						}
						else
						{
			   				goto mu;
						}
					}
				    case 3:
					{
    					if(RandomSpawn[3] == 0)
						{
							RandomSpawn[3] = 1;
							new vehicles;
							vehicles = CreateVehicle(598, 2083.3323,1203.6499,10.8203, 0, 0, 0, 0);
							SetVehicleVirtualWorld(vehicles, number);
							PutPlayerInVehicle(Popchase[number][i], vehicles, 0);
						}
						else
						{
			   				goto mu;
						}
					}
				}
			}
			for(new i; i < MAX_PLOBBY; i++)
			{
			    ActionLobby[number][i] = Popchase[number][i];
			}
			for(new i; i < MAX_PLOBBY; i++) // для всего лобби действие
			{
				if(Popchase[number][i] == -1) continue;
				if(Popchase[number][i] == Suspect[number])
				{
					new Name[MAX_PLAYER_NAME];
					Name = GPN(Popchase[number][i]);
					new PrintName[40];
					format(PrintName, MAX_PLAYER_NAME+6, "~n~%s(%i)~n~~n~", Name, Popchase[number][i]);
					
					MenuUI[Popchase[number][i]][0] = CreatePlayerTextDraw(Popchase[number][i], 90, 210, PrintName);
					PlayerTextDrawUseBox(Popchase[number][i], MenuUI[Popchase[number][i]][0], 1);
					PlayerTextDrawBoxColor(Popchase[number][i], MenuUI[Popchase[number][i]][0], 0xc00022ff);
					PlayerTextDrawTextSize(Popchase[number][i], MenuUI[Popchase[number][i]][0], 100, 150);
					PlayerTextDrawFont(Popchase[number][i], MenuUI[Popchase[number][i]][0], 2);
					PlayerTextDrawLetterSize(Popchase[number][i], MenuUI[Popchase[number][i]][0], 0.2, 0.8);
					PlayerTextDrawSetShadow(Popchase[number][i], MenuUI[Popchase[number][i]][0], 0);
					PlayerTextDrawAlignment(Popchase[number][i], MenuUI[Popchase[number][i]][0], 2);
					PlayerTextDrawShow(Popchase[number][i], MenuUI[Popchase[number][i]][0]);
					
					new TextTD[240];
					format(TextTD, 240, "~n~~n~Time remaining: 601~n~~n~~n~Cops remaining: %i~n~~n~~n~Vehicle hp: 1000~n~~n~", Lobby[number] - 1);
					MenuUI[Popchase[number][i]][1] = CreatePlayerTextDraw(Popchase[number][i], 90, 234, TextTD);
					PlayerTextDrawUseBox(Popchase[number][i], MenuUI[Popchase[number][i]][1], 1);
					PlayerTextDrawBoxColor(Popchase[number][i], MenuUI[Popchase[number][i]][1], 0x000000ff);
					PlayerTextDrawTextSize(Popchase[number][i], MenuUI[Popchase[number][i]][1], 100, 150);
					PlayerTextDrawFont(Popchase[number][i], MenuUI[Popchase[number][i]][1], 2);
					PlayerTextDrawLetterSize(Popchase[number][i], MenuUI[Popchase[number][i]][1], 0.2, 0.8);
					PlayerTextDrawSetShadow(Popchase[number][i], MenuUI[Popchase[number][i]][1], 0);
					PlayerTextDrawAlignment(Popchase[number][i], MenuUI[Popchase[number][i]][1], 2);
					PlayerTextDrawShow(Popchase[number][i], MenuUI[Popchase[number][i]][1]);
					continue;
				} 
				for(new i1; i1 < MAX_PLOBBY; i1++) // отрисовываем кол-во игроков
				{
					if(Popchase[number][i1] == -1) continue;
					if(Popchase[number][i1] == Suspect[number]) continue;
					new Name[MAX_PLAYER_NAME];
					Name = GPN(Popchase[number][i1]);
					new Text[60];
					strcat(Text, Name);
					new Texts[60];
					format(Texts, 60,"%s", Text);
					
		            SuspectUI[Popchase[number][i]][i1] = CreatePlayerTextDraw(Popchase[number][i], 460, 240 + 12 * i1, Texts);
					PlayerTextDrawUseBox(Popchase[number][i], SuspectUI[Popchase[number][i]][i1], 1);
					PlayerTextDrawBoxColor(Popchase[number][i], SuspectUI[Popchase[number][i]][i1], 0x000000FF);
					PlayerTextDrawTextSize(Popchase[number][i], SuspectUI[Popchase[number][i]][i1], 595, 20);
					PlayerTextDrawFont(Popchase[number][i], SuspectUI[Popchase[number][i]][i1], 2);
					PlayerTextDrawLetterSize(Popchase[number][i], SuspectUI[Popchase[number][i]][i1], 0.2, 0.8);
					PlayerTextDrawSetShadow(Popchase[number][i], SuspectUI[Popchase[number][i]][i1], 0);
					PlayerTextDrawShow(Popchase[number][i], SuspectUI[Popchase[number][i]][i1]);
					
					SusUI[Popchase[number][i]][i1] = CreatePlayerTextDraw(Popchase[number][i], 590, 240 + 12 * i1, "Blizko");
					PlayerTextDrawUseBox(Popchase[number][i], SusUI[Popchase[number][i]][i1], 1);
					PlayerTextDrawBoxColor(Popchase[number][i], SusUI[Popchase[number][i]][i1], 0x000000FF);
					PlayerTextDrawTextSize(Popchase[number][i], SusUI[Popchase[number][i]][i1], 640, 20);
					PlayerTextDrawFont(Popchase[number][i], SusUI[Popchase[number][i]][i1], 2);
					PlayerTextDrawLetterSize(Popchase[number][i], SusUI[Popchase[number][i]][i1], 0.2, 0.8);
					PlayerTextDrawSetShadow(Popchase[number][i], SusUI[Popchase[number][i]][i1], 0);
					PlayerTextDrawShow(Popchase[number][i], SusUI[Popchase[number][i]][i1]);
				}
				new Name[MAX_PLAYER_NAME];
				Name = GPN(Popchase[number][i]);
				new PrintName[40];
				
				format(PrintName, MAX_PLAYER_NAME+6, "~n~%s(%i)~n~~n~", Name, Popchase[number][i]);
				MenuUI[Popchase[number][i]][0] = CreatePlayerTextDraw(Popchase[number][i], 90, 210, PrintName);
				PlayerTextDrawUseBox(Popchase[number][i], MenuUI[Popchase[number][i]][0], 1);
				PlayerTextDrawBoxColor(Popchase[number][i], MenuUI[Popchase[number][i]][0], 0x0044bbB0);
				PlayerTextDrawTextSize(Popchase[number][i], MenuUI[Popchase[number][i]][0], 80, 150);
				PlayerTextDrawFont(Popchase[number][i], MenuUI[Popchase[number][i]][0], 2);
				PlayerTextDrawLetterSize(Popchase[number][i], MenuUI[Popchase[number][i]][0], 0.2, 0.8);
				PlayerTextDrawSetShadow(Popchase[number][i], MenuUI[Popchase[number][i]][0], 0);
				PlayerTextDrawAlignment(Popchase[number][i], MenuUI[Popchase[number][i]][0], 2);
				PlayerTextDrawShow(Popchase[number][i], MenuUI[Popchase[number][i]][0]);
				
				Name = GPN(Suspect[number]);
				new TextTD[250];
				format(TextTD, 250, "~n~~n~Time remaining: 601~n~~n~~n~Suspect: %s ~n~~n~~n~Minimap: Ne vidno~n~~n~", Name);
				MenuUI[Popchase[number][i]][1] = CreatePlayerTextDraw(Popchase[number][i], 90, 234, "~n~~n~Time remaining: 601~n~~n~~n~Suspect: ~n~~n~~n~Minimap:~n~~n~");
				PlayerTextDrawUseBox(Popchase[number][i], MenuUI[Popchase[number][i]][1], 1);
				PlayerTextDrawBoxColor(Popchase[number][i], MenuUI[Popchase[number][i]][1], 0x000000ff);
				PlayerTextDrawTextSize(Popchase[number][i], MenuUI[Popchase[number][i]][1], 80, 150);
				PlayerTextDrawFont(Popchase[number][i], MenuUI[Popchase[number][i]][1], 2);
				PlayerTextDrawLetterSize(Popchase[number][i], MenuUI[Popchase[number][i]][1], 0.2, 0.8);
				PlayerTextDrawSetShadow(Popchase[number][i], MenuUI[Popchase[number][i]][1], 0);
				PlayerTextDrawAlignment(Popchase[number][i], MenuUI[Popchase[number][i]][1], 2);
				PlayerTextDrawShow(Popchase[number][i], MenuUI[Popchase[number][i]][1]);
			}
		    AL[number] = 2;
		    CountLobby[number] = 601;
			EndLobby[number] = SetTimerEx("EndTimer", 1000, true, "i", number);
	    }
	    SendClientMessageToAll(0xFF000000, Adv);
	}
	return 1;
}

stock GPN(playerid)
{
	new Name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, Name, MAX_PLAYER_NAME);
	return Name;
}

public EndTimer(number)
{
	if(CountLobby[number] > 0)
	{
		CountLobby[number]--;
		for(new i; i < MAX_PLOBBY; i++)
		{
		    if(Popchase[number][i] == -1) continue;
			if(Popchase[number][i] == Suspect[number])
			{
			    new Float:VehicleHP, VehID;
				VehID = GetPlayerVehicleID(i);
			    GetVehicleHealth(VehID, VehicleHP);
			    format(Adv, 400, "~n~~n~Time remaining: %i sec~n~~n~~n~Cops remaining: %i~n~~n~~n~Vehicle hp: %.0f~n~~n~", CountLobby[number], Lobby[number] - 1, VehicleHP);
				PlayerTextDrawSetString(Popchase[number][i], MenuUI[Popchase[number][i]][1], Adv);
			}
			else
			{
				new Name[MAX_PLAYER_NAME];
				Name = GPN(Suspect[number]);
				format(Adv, 400, "~n~~n~Time remaining: %i sec~n~~n~~n~Suspect: %s~n~~n~~n~Minimap: Ne vidno~n~~n~", CountLobby[number], Name);
				PlayerTextDrawSetString(Popchase[number][i], MenuUI[Popchase[number][i]][1], Adv);
			}
		}
		SendClientMessageToAll(0xFF000000, Adv);
 	}
 	else
	{
	    format(Adv, 144, "Лобби %i закрывается", number);
		SendClientMessageToAll(0xFF000000, Adv);
		Suspect[number] = -1;
		for(new i = 0; i < MAX_PLOBBY; i++)
		{
			if(Popchase[number][i] == -1) { continue; }
			else
			{
				PlayerInfo[Popchase[number][i]][Lb] = -1;
				SendClientMessage(Popchase[number][i], 0xFF000000, "Вы покинули лобби");
		    	Popchase[number][i] = -1;
		    }
		}
		KillTimer(EndLobby[number]);
		AL[number] = 0;
 		Lobby[number] = 0;
	}
	return 1;
}

public OnGameModeInit()
{
	for(new i = 0; i < 30; i++)
	{
	    for(new ik; ik < MAX_PLOBBY; ik++)
	    {
	        Popchase[i][ik] = -1;
	    }
	}
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    PlayerInfo[i][Lb] = -1;
	}
	for(new i = 0; i < 30; i++)
	{
	    Suspect[i] = -1;
	}
	LobbyX = 1958.3783;
	LobbyY = 1343.1572;
	LobbyZ = 15.3746;
	sql = mysql_connect("db2.myarena.ru", "anayks_anayks", "RicardoMilos", "anayks_Akakiy");
	SetGameModeText("Copchase Beta Test");
	EnableStuntBonusForAll(false);
	DisableInteriorEnterExits();
	return 1;
}

public OnGameModeExit()
{
	mysql_close(sql);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
    if(PlayerInfo[playerid][Lb] == -1) return 1;
	if(Suspect[PlayerInfo[playerid][Lb]] == playerid)
	{
	    new string[250];
		new Float:VehHP;
		GetVehicleHealth(vehicleid, VehHP);
	    format(string, sizeof(string), "~n~~n~Time remaining: %i sec~n~~n~~n~Cops remaining: %i~n~~n~~n~Vehicle hp: %.0f~n~~n~", CountLobby[PlayerInfo[playerid][Lb]], Lobby[PlayerInfo[playerid][Lb]], VehHP);
		PlayerTextDrawSetString(playerid, MenuUI[playerid][1], string);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
    PlayerInfo[playerid][Lb] = -1;
	new Name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, Name, sizeof(Name));
	new query[256];
	format(query, 256, "SELECT COUNT(*) FROM `Accounts` WHERE `Name` = '%s'", Name);
	mysql_query(sql, query);
	new row;
	cache_get_value_index_int(0, 0, row);
	if(row == 0)
	{
	    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_INPUT, "Регистрация", "Добро пожаловать на Copchase Server\nЧтобы начать игру, Вам необходимо зарегистрироваться\n\nВведите пароль для Вашего аккаунта\nОн будет использоваться при каждом входе на сервер.\n\n\t-Пароль чувствителен к регистру\n\t-Можно использовать только кириллицу, латиницу и цифры.", "Далее", "Отмена");
	}
	else
	{
		ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Авторизация", "Добро пожаловать на Copchase Server\nВаш аккаунт зарегистрирован.\nЧтобы начать игру, Вам нужно ввести пароль,\nКоторый Вы указали при регистрации.", "Далее", "Отмена");
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(PlayerInfo[playerid][Lb] > -1)
	{
		Lobby[PlayerInfo[playerid][Lb]]--;
		for(new i = 0; i < MAX_PLOBBY; i++)
		{
			if(Popchase[PlayerInfo[playerid][Lb]][i] != playerid) continue;
			else
			{
   				Popchase[PlayerInfo[playerid][Lb]][i] = -1;
			    break;
			}
		}
		PlayerInfo[playerid][Lb] = -1;
	}
	PlayerInfo[playerid][Login] 	= 0;
	PlayerInfo[playerid][Donate] 	= 0;
	PlayerInfo[playerid][Money] 	= 0;
	PlayerInfo[playerid][Admin] 	= 0;
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(PlayerInfo[playerid][Login] == 0)
	{
	    Kick(playerid);
	}
	return 1;
}


public OnPlayerDeath(playerid, killerid, reason)
{
	if(PlayerInfo[playerid][Lb] > -1)
	{
	    new LB = PlayerInfo[playerid][Lb];
	    // Если умер саспект блять

	    if(Suspect[LB] == playerid)
	    {
			for(new i; i < MAX_PLOBBY; i++)
			{
			    if(Popchase[LB][i] == -1) continue;
				PlayerTextDrawHide(Popchase[LB][i], MenuUI[Popchase[LB][i]][0]);
				PlayerTextDrawHide(Popchase[LB][i], MenuUI[Popchase[LB][i]][1]);
				if(Popchase[LB][i] == Suspect[LB]) continue;
				for(new k; k < MAX_PLOBBY; k++)
				{
				    if(Popchase[LB][k] == Popchase[LB][i]) continue;
				    if(Popchase[LB][k] == -1) continue;
					PlayerTextDrawHide(Popchase[LB][i], SusUI[Popchase[LB][i]][k]);
					PlayerTextDrawHide(Popchase[LB][i], SuspectUI[Popchase[LB][i]][k]);
					new Text[250];
					new Name[MAX_PLAYER_NAME];
					GetPlayerName(playerid, Name, MAX_PLAYER_NAME);
					format(Text, 250, "Строка худа с %s очищена", Name);
					SendClientMessage(Popchase[LB][i], 0xFF000000, Text);
				}
				Lobby[Popchase[LB][i]]--;
				Popchase[LB][i] = -1;
				SendClientMessage(Popchase[LB][i], 0xFF000000, "Вы вышли из лобби, поскольку преследуемый погиб");
				TogglePlayerSpectating(Popchase[LB][i], 1);
				OpenTD(Popchase[LB][i]);
				TogglePlayerSpectating(playerid, 1);
			}
			KillTimer(EndLobby[LB]);
			Lobby[LB]--;
			OpenTD(playerid);
			Popchase[LB][playerid] = -1;
			TogglePlayerSpectating(playerid, 1);
	    }
		// если умер нихуя не саспект
		else
		{
		    Lobby[LB]--;
		    Popchase[LB][playerid] = -1;
   			HideHUD(playerid);
			TogglePlayerSpectating(playerid, 1);
			OpenTD(Popchase[LB][playerid]);
		}
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 0:
	    {
	        if(response)
			{
			    if(!strlen(inputtext) || strlen(inputtext) < 6 || strlen(inputtext) > 20)
			    {
       				ShowPlayerDialog(playerid, 0, DIALOG_STYLE_INPUT, "Регистрация", "Произошла ошибка регистрации. \nВ пароле должно быть более 6 и менее 20 символов.\nПожалуйста, повторите попытку", "Продолжить", "");
			    }
				else
				{
					for(new i; i<strlen(inputtext); i++)
					{
						switch(inputtext[i])
						{
						    case 'A'..'Z': continue;
						    case 'a'..'z': continue;
						    case '0'..'9': continue;
						    case '_': continue;
						    default:
						    {
						    	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_INPUT, "Регистрация", "Произошла ошибка регистрации.\nВы ввели запрещенные символы.\nПожалуйста, повторите попытку", "Продолжить", "");
								return 1;
						    }
						}
					}
					new Name[MAX_PLAYER_NAME];
					GetPlayerName(playerid, Name, MAX_PLAYER_NAME);
					new query[256];
					format(query, 256, "SELECT COUNT(*) from `Accounts`");
					mysql_query(sql, query);
					new rows;
					cache_get_value_index_int(0, 0, rows);
					format(query, 256, "INSERT INTO `Accounts` (`ID`, `Name`, `Password`, `Admin`, `Money`, `Donate`, `Online`) VALUES ('%i', '%s', '%s', '0', '0', '0', '1')", rows, Name, inputtext);
					mysql_query(sql, query);
					PlayerInfo[playerid][Login] = 1;
					new RandomSkin = 1 + random(310);
					SetPlayerSkin(playerid, RandomSkin);
					SetSpawnInfo(playerid, 0, RandomSkin, LobbyX, LobbyY, LobbyZ, 0, 0, 0, 0, 0, 0, 0);
					OpenTD(playerid);
					TogglePlayerSpectating(playerid, 1);
				}
			}
			else
			{
			    Kick(playerid);
			}
	    }
	    case 1:
		{
		    if(response)
		    {
	 			if(!strlen(inputtext) || strlen(inputtext) < 6 || strlen(inputtext) > 20)
			    {
       				ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Авторизация", "Произошла ошибка. \nПожалуйста, повторите попытку.", "Продолжить", "");
			    }
			    else
				{
					for(new i; i<strlen(inputtext); i++)
					{
						switch(inputtext[i])
						{
						    case 'A'..'Z': continue;
						    case 'a'..'z': continue;
						    case '0'..'9': continue;
						    case '_': continue;
						    default:
						    {
						    	ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Авторизация", "Вы ввели запрещённые символы\nПожалуйста, повторите попытку.", "Продолжить", "");
								return 1;
						    }
						}
					}
					new Name[MAX_PLAYER_NAME];
					GetPlayerName(playerid, Name, MAX_PLAYER_NAME);
					new query[256];
					format(query, 256, "SELECT * from `Accounts` where `Name` = '%s'", Name);
					mysql_query(sql, query);
					new password[24];
					cache_get_value_name(0, "Password", password);
					if(strcmp(password, inputtext, false) != 0)
					{
						ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Авторизация", "Пароль введен неверно\nПожауйста, повторите попытку.", "Продолжить", "");
					}
					else
					{
					    LoadAccount(playerid);
						PlayerInfo[playerid][Login] = 1;
						new RandomSkin = 1 + random(310);
						SetPlayerSkin(playerid, RandomSkin);
						OpenTD(playerid);
						TogglePlayerSpectating(playerid, 1);
					}
				}
		    }
		}
	}
	return 1;
}

forward LoadAccount(playerid);
public LoadAccount(playerid)
{
	cache_get_value_name_int(0, "ID", PlayerInfo[playerid][ID]);
	cache_get_value_name_int(0, "Money", PlayerInfo[playerid][Money]);
	cache_get_value_name_int(0, "Admin", PlayerInfo[playerid][Admin]);
	cache_get_value_name_int(0, "Donate", PlayerInfo[playerid][Donate]);
	return 1;
}

forward OpenTD(playerid);
public OpenTD(playerid)
{
	LobbyTD[playerid][0] = CreatePlayerTextDraw(playerid, 0, 380, "~n~~n~");
	PlayerTextDrawUseBox(playerid, LobbyTD[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, LobbyTD[playerid][0], 0x22222299);
	PlayerTextDrawTextSize(playerid, LobbyTD[playerid][0], 640, 140);
	PlayerTextDrawFont(playerid, LobbyTD[playerid][0], 2);
 	PlayerTextDrawLetterSize(playerid, LobbyTD[playerid][0], 0.5, 2);
	PlayerTextDrawSetShadow(playerid, LobbyTD[playerid][0], 0);
	PlayerTextDrawShow(playerid, LobbyTD[playerid][0]);
	LobbyTD[playerid][1] = CreatePlayerTextDraw(playerid, 350, 390, "Customize");
	LobbyTD[playerid][2] = CreatePlayerTextDraw(playerid, 480, 390, "Shop");
	LobbyTD[playerid][3] = CreatePlayerTextDraw(playerid, 550, 390, "Stats");
	LobbyTD[playerid][4] = CreatePlayerTextDraw(playerid, 120, 370, "~n~Play~n~~n~");
	PlayerTextDrawUseBox(playerid, LobbyTD[playerid][4], 1);
	PlayerTextDrawFont(playerid, LobbyTD[playerid][4], 2);
	PlayerTextDrawBoxColor(playerid, LobbyTD[playerid][4], 0x00AA33FF);
	PlayerTextDrawTextSize(playerid, LobbyTD[playerid][4], 160, 140);
	PlayerTextDrawLetterSize(playerid, LobbyTD[playerid][4], 0.5, 2);
	PlayerTextDrawSetShadow(playerid, LobbyTD[playerid][4], 0);
	PlayerTextDrawAlignment(playerid, LobbyTD[playerid][4], 2);
	PlayerTextDrawShow(playerid, LobbyTD[playerid][4]);
	for(new i = 1; i < 5; i++)
	{
	    PlayerTextDrawSetSelectable(playerid, LobbyTD[playerid][i], 1);
	    PlayerTextDrawFont(playerid, LobbyTD[playerid][i], 2);
	    PlayerTextDrawLetterSize(playerid, LobbyTD[playerid][i], 0.5, 2);
	    PlayerTextDrawSetShadow(playerid, LobbyTD[playerid][i], 0);
        PlayerTextDrawShow(playerid, LobbyTD[playerid][i]);
	}
	SelectTextDraw(playerid, 0xFFFFFFFF);
	return 1;
}

forward CloseTD(playerid);
public CloseTD(playerid)
{
	for(new i; i < 5; i++)
	{
		PlayerTextDrawDestroy(playerid, LobbyTD[playerid][i]);
	}
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}


public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == LobbyTD[playerid][4])
	{
        for(new i; i < 30; i++)
		{
			if(AL[i] == 2) { continue; }
			else if(AL[i] == 1 || AL[i] == 0) {
		    new a = 0;
		    if(Lobby[i] == 0)
			{
				LobbyName[i][playerid] = GPN(playerid);
    			format(Adv, 144, "Вы заняли слот первый в лобби %i. ожидайте начала игры. ", i);
			    SendClientMessage(playerid, 0xFF000000, Adv);
				AL[i] = 1;
			    Lobby[i]++;
				Popchase[i][0] = playerid;
				PlayerInfo[playerid][Lb] = i;
				SetPlayerVirtualWorld(playerid, i);
				break;
			}
			else if(Lobby[i] == MAX_PLOBBY)
			{
			    continue;
			}
			else if(Lobby[i] > 0)
			{
				for(new ik = 0; ik < MAX_PLOBBY; ik++)
				{
				    if(Popchase[i][ik] > -1)
					{
				 		continue;
				 	}
					else if(Popchase[i][ik] == -1)
					{
						LobbyName[i][playerid] = GPN(playerid);
					    format(Adv, 144, "Вы заняли слот %i в лобби %i. ожидайте начала игры.", ik, i);
					    SendClientMessage(playerid, 0xFF000000, Adv);
						Popchase[i][ik] = playerid;
						PlayerInfo[playerid][Lb] = i;
						Lobby[i]++;
						CountLobby[i] = 15;
						SetPlayerVirtualWorld(playerid, i);
						if(Activate[i] == 0)
						{
							if(Lobby[i] > 2)
							{
							    Activate[i] = 1;
							    TimersLobby[i] = SetTimerEx("TimerLobby", 1000, true, "i", i);
							}
						}
						break;
					}
				}
				a = 1;
				if(a == 1) break;
			}
			if(i == 29) { SendClientMessage(playerid, 0x33DD4400, "Все лобби заняты, ожидайте."); return 1; }
			}
		}
  		new RandomSkin = 1 + random(310);
    	SetPlayerSkin(playerid, RandomSkin);
		SetSpawnInfo(playerid, 0, RandomSkin, LobbyX, LobbyY, LobbyZ, 269.1425, 0, 0, 0, 0, 0, 0);
		CancelSelectTextDraw(playerid);
		CloseTD(playerid);
		SendClientMessage(playerid, 0xFF000000, "Подбор игроков");
		TogglePlayerSpectating(playerid, 0);
	}
	return 1;
}

CMD:lba(playerid)
{
	new LobbyInfo[2000];
	new str[100];
	for(new i = 0; i < 30; i++)
	{
	    if(Lobby[i] == 0 && AL[i] == 0)
		{
		    format(str, 100, "%i\t\tлобби свободно\t\t\t%i/%i\n", i, Lobby[i], MAX_PLOBBY);
			strcat(LobbyInfo, str);
	    }
   		else if(Lobby[i] == MAX_PLOBBY && AL[i] == 1)
		{
			format(str, 100, "%i\t\tлобби заполнено\t\t\t%i/%i\n", i, Lobby[i], MAX_PLOBBY);
			strcat(LobbyInfo, str);
		}
		else if(Lobby[i] > 0 && AL[i] == 1)
		{
		    format(str, 100, "%i\t\tлобби заполняется\t\t\t%i/%i\n", i, Lobby[i], MAX_PLOBBY);
			strcat(LobbyInfo, str);
		}
		else if(Lobby[i] > 0 && AL[i] == 2)
		{
		    format(str, 100, "%i\t\tлобби в стадии игры\t\t\t%i/%i\n", i, Lobby[i], MAX_PLOBBY);
			strcat(LobbyInfo, str);
		}
		else if(Lobby[i] == MAX_PLOBBY && AL[i] == 2)
		{
		    format(str, 100, "%i\t\tлобби заполнено и в стадии игры\t\t\t%i/%i\n", i, Lobby[i], MAX_PLOBBY);
			strcat(LobbyInfo, str);
		}
		else
		{
		    format(str, 100, "%i\t\t лобби забагалось.\t\t\t%i/%i\n", i, Lobby[i], MAX_PLOBBY);
			strcat(LobbyInfo, str);
		}
	}
	ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, "Отладка лобби", LobbyInfo, "Продолжить", "");
	return 1;
}

CMD:account(playerid)
{
	new AccInfo[2000];
	new AccText[100];
	if(PlayerInfo[playerid][Lb] < 0)
	{
	    format(AccText, 100, "Вы не находитесь в лобби\n", PlayerInfo[playerid][Lb]);
	}
	else
	{
		format(AccText, 100, "Вы в №%i лобби\n", PlayerInfo[playerid][Lb]);
	}
	strcat(AccInfo, AccText);
	format(AccText, 100, "Ваш уровень админки:\t\t%i\n", PlayerInfo[playerid][Admin]);
	strcat(AccInfo, AccText);
	format(AccText, 100, "Номер вашего аккаунта:\t\t%i\n", PlayerInfo[playerid][ID]);
	strcat(AccInfo, AccText);
	format(AccText, 100, "У вас на счету:\t\t\t\t%i CC", PlayerInfo[playerid][Donate]);
	strcat(AccInfo, AccText);
	ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, "Информация об аккаунте", AccInfo, "Принять", "");
	return 1;
}

CMD:veh(playerid, params[])
{
	if(PlayerInfo[playerid][Admin] == 0)
	{
		SendClientMessage(playerid, 0xFF000000, "Ошибка: эта команда вам недоступна.");
	}
	else
	{
		new Float:x, Float:y, Float:z, veh;
		GetPlayerPos(playerid, x, y, z);
		if(sscanf(params, "d", veh)) return SendClientMessage(playerid, 0xFF000000, "Ошибка: введите корректный id транспорта");
		CreateVehicle(veh, x, y, z, 0, 0, 0, 0);
	}
	return 1;
}

CMD:lobby(playerid, params[])
{
	new lid;
	if(sscanf(params,"d", lid))
	return SendClientMessage(playerid, 0xFF000000, "Ошибка: введите корректный id лобби");
	new LobbyInfo[1000];
	new keks[100];
	for(new i; i < MAX_PLOBBY; i++)
	{
	    format(keks, 100, "%i слот занят игроком %i\n", i, Popchase[lid][i]);
		strcat(LobbyInfo, keks);
	}
	format(keks, 100, "\nВсего игроков в лобби: %i", Lobby[lid]);
	strcat(LobbyInfo, keks);
	format(keks, 100, "\nПодозреваемый: %i", Suspect[lid]);
	strcat(LobbyInfo, keks);
	new DialogLobbyName[55];
	format(DialogLobbyName, 55, "Информация о №%i лобби.", lid);
	ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, DialogLobbyName, LobbyInfo, "Ок", "");
	return 1;
}

CMD:check(playerid)
{
	new string[1000];
	new a;
	for(new i; i < MAX_PLOBBY; i++)
	{
	    if(Popchase[PlayerInfo[playerid][Lb]][i] == playerid) {a = playerid; break;}
	}
	format(string, 1000, "%i\t\t\t - виртуальный мир;\n%i\t\t\t - номер лобби;\n%i\n\n\n - слот в лобби", GetPlayerVirtualWorld(playerid), PlayerInfo[playerid][Lb], a);
	ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, "Проверка", string, "Ок", "Отмена");
	return 1;
}

CMD:kill(playerid)
{
	SetPlayerHealth(playerid, 0);
	return 1;
}

stock HideHUD(playerid)
{
    new LB = PlayerInfo[playerid][Lb];
	PlayerTextDrawHide(playerid, MenuUI[playerid][0]);
	PlayerTextDrawHide(playerid, MenuUI[playerid][1]);
	for(new k; k < MAX_PLOBBY; k++)
	{
		if(Popchase[LB][k] == Suspect[LB]) continue;
		if(Popchase[LB][k] == -1) continue;
		PlayerTextDrawHide(playerid, SusUI[playerid][k]);
		PlayerTextDrawHide(playerid, SuspectUI[playerid][k]);
	}
	return 1;
}
