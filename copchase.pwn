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
#define MAX_PLAYERS 320
#define MAX_PLOBBY 4

new MySQL:sql;

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

enum LI
{
	Suspect,
	Players,
	Activate,
	Timer,
}

new PlayerInfo[MAX_PLAYERS][PI];
new LobbyInfo[30][LI];
new LobbyName[30][MAX_PLOBBY][MAX_PLAYER_NAME];
new LobbyID[30][MAX_PLOBBY];
new Priority;
new PlayerText:MenuTD[MAX_PLAYERS][5];
new PlayerText:PoliceUI[MAX_PLAYERS][9];
new PlayerText:RangeUI[MAX_PLAYERS][9];

public OnGameModeInit()
{
	sql = mysql_connect("db2.myarena.ru", "anayks_anayks", "RicardoMilos", "anayks_Akakiy");
	SetGameModeText("Copchase Beta Test");
	EnableStuntBonusForAll(false);
	DisableInteriorEnterExits();
	Priority = 0;
	for(new k; k < 30; k++)
	{
		LobbyInfo[k][Suspect] = -1;
		LobbyInfo[k][Timer] = -1;
		for(new i; i < MAX_PLOBBY; i++)
		{
			LobbyID[k][i] = -1;
		}
	}
	for(new i; i < MAX_PLAYERS; i++)
	{
		PlayerInfo[i][Lb] = -1;
		PlayerInfo[i][Money] = -1;
		PlayerInfo[i][Donate] = -1;
		PlayerInfo[i][ID] = -1;
		PlayerInfo[i][Login] = -1;
		PlayerInfo[i][Skin] = -1;
		PlayerInfo[i][Admin] = -1;
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
	    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_INPUT, "Регистрация", "Регистрация же", "Далее", "Отмена");
	}
	else
	{
		ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Авторизация", "Добро пожаловать на Copchase Server\nВаш аккаунт зарегистрирован.\nЧтобы начать игру, Вам нужно ввести пароль,\nКоторый Вы указали при регистрации.", "Далее", "Отмена");
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	PlayerInfo[playerid][Skin] 		= -1;
	PlayerInfo[playerid][ID]		= -1;
	PlayerInfo[playerid][Login] 	= -1;
	PlayerInfo[playerid][Donate] 	= -1;
	PlayerInfo[playerid][Money] 	= -1;
	PlayerInfo[playerid][Admin] 	= -1;
	PlayerInfo[playerid][Login] 	= -1;
	DestroyMenuTD(playerid);
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
					SetSpawnInfo(playerid, 0,0,0,0,0,0,0,0, 0,0,0,0);
					//Если человек зарегистрировался
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
					else // Человек авторизовался
					{
						SelectTextDraw(playerid, 0xffffffff);
					    LoadAccount(playerid);
					    PlayerInfo[playerid][Login] = 1;
					    SetSpawnInfo(playerid, 0,0,0,0,0,0,0,0, 0,0,0,0);
					    SetPlayerCameraPos(playerid, 1627.4650, -1045.1171, 24.8984);
					    SpawnPlayer(playerid);
					    SetPlayerPos(playerid, 1633.7219, -1045.2396, 23.8984);
					    SetPlayerFacingAngle(playerid, 92.0000);
					    SetPlayerCameraLookAt(playerid, 1637.7219,-1045.2396,23.8984);
					  	SetPlayerVirtualWorld(playerid, 1001);
					  	TogglePlayerControllable(playerid, 0);
					  	new veh;
					  	veh = CreateVehicle(400, 1640.4,-1045.2396,23.8984, 0.0000, 0, 0, 0);
					  	SetVehicleVirtualWorld(veh, 1001);
					  	CreateMenuTD(playerid);
					  	ShowMenuTD(playerid);
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

stock CreateMenuTD(playerid)
{
	MenuTD[playerid][0] = CreatePlayerTextDraw(playerid, 320, 360, "~n~~n~~n~");
	PlayerTextDrawTextSize(playerid, MenuTD[playerid][0], 0, 640);
	PlayerTextDrawUseBox(playerid, MenuTD[playerid][0], 1);
	PlayerTextDrawAlignment(playerid, MenuTD[playerid][0], 2);
	PlayerTextDrawBoxColor(playerid, MenuTD[playerid][0], 0x888888ee);

	MenuTD[playerid][1] = CreatePlayerTextDraw(playerid, 100, 350, "~n~PLAY~n~~n~");
	PlayerTextDrawSetShadow(playerid, MenuTD[playerid][1], 0);
	PlayerTextDrawFont(playerid, MenuTD[playerid][1], 2);
	PlayerTextDrawAlignment(playerid, MenuTD[playerid][1], 2);
	PlayerTextDrawLetterSize(playerid, MenuTD[playerid][1], 0.4, 1.8);
	PlayerTextDrawUseBox(playerid, MenuTD[playerid][1], 1);
	PlayerTextDrawTextSize(playerid, MenuTD[playerid][1], 60, 130);
	PlayerTextDrawBoxColor(playerid, MenuTD[playerid][1], 0x003399ff);
	PlayerTextDrawSetSelectable(playerid, MenuTD[playerid][1], 1);

	MenuTD[playerid][2] = CreatePlayerTextDraw(playerid, 350, 365, "CUSTOMIZE");
	PlayerTextDrawLetterSize(playerid, MenuTD[playerid][2], 0.4, 1.8);
	PlayerTextDrawSetShadow(playerid, MenuTD[playerid][2], 0);
	PlayerTextDrawFont(playerid, MenuTD[playerid][2], 2);
	PlayerTextDrawSetSelectable(playerid, MenuTD[playerid][2], 1);

	MenuTD[playerid][3] = CreatePlayerTextDraw(playerid, 470, 365, "SHOP");
	PlayerTextDrawLetterSize(playerid, MenuTD[playerid][3], 0.4, 1.8);
	PlayerTextDrawSetShadow(playerid, MenuTD[playerid][3], 0);
	PlayerTextDrawFont(playerid, MenuTD[playerid][3], 2);
	PlayerTextDrawSetSelectable(playerid, MenuTD[playerid][3], 1);

	MenuTD[playerid][4] = CreatePlayerTextDraw(playerid, 545, 365, "STATS");
	PlayerTextDrawLetterSize(playerid, MenuTD[playerid][4], 0.4, 1.8);
	PlayerTextDrawSetShadow(playerid, MenuTD[playerid][4], 0);
	PlayerTextDrawFont(playerid, MenuTD[playerid][4], 2);
	PlayerTextDrawSetSelectable(playerid, MenuTD[playerid][4], 1);
}

stock ShowMenuTD(playerid)
{
	for(new i; i < 5; i++)
	{
		PlayerTextDrawShow(playerid, MenuTD[playerid][i]);
	}
}

stock HideMenuTD(playerid)
{
	for(new i; i < 5; i++)
	{
		PlayerTextDrawHide(playerid, MenuTD[playerid][i]);
	}
}

stock DestroyMenuTD(playerid)
{
	for(new i; i < 5; i++)
	{
		PlayerTextDrawDestroy(playerid, MenuTD[playerid][i]);
	}
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


public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
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
		new Float:x, Float:y, Float:z, veh, idv;
		GetPlayerPos(playerid, x, y, z);
		if(sscanf(params, "d", veh)) return SendClientMessage(playerid, 0xFF000000, "Ошибка: введите корректный id транспорта");
		idv = CreateVehicle(veh, x, y, z, 0, 0, 0, 0);
		SetVehicleVirtualWorld(idv, 1001);
	}
	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == MenuTD[playerid][1])
	{
		if(Priority > -1) 
		{
			HideMenuTD(playerid);
			TogglePlayerControllable(playerid, 1);
			SetPlayerVirtualWorld(playerid, Priority);
			if(LobbyInfo[Priority][Activate] == 0) // если лобби не создано
			{
				LobbyInfo[Priority][Activate] = 1;
				GiveSlot(playerid, Priority);
				CreatePoliceUI(playerid);
				ShowPoliceUI(playerid);
				SendClientMessage(playerid, 0xFF000000, "Вы попали в пустое лобби. Ожидайте игроков");
				SetCameraBehindPlayer(playerid);
				SetPlayerVirtualWorld(playerid, Priority);
			}
			else if(LobbyInfo[Priority][Activate] == 1 || LobbyInfo[Priority][Activate] == 2) // Если лобби создано и в процессе поиска
			{
				if(LobbyInfo[Priority][Players] < 3) // Если игроков меньше 3
				{
					GiveSlot(playerid, Priority);
					if(LobbyInfo[Priority][Players] == 3) // Если игрок подключился третьим
					{
						LobbyInfo[Priority][Timer] = 10; // Задаем 10 секунд до подключения к лобби
						LobbyInfo[Priority][Activate] = 2; // Состояние лобби: запущен таймер
					}
				}
				else
				{
					if(LobbyInfo[Priority][Players] + 1 == MAX_PLOBBY) //Если игрок занимает последний слот
					{
						GiveSlot(playerid, Priority);
						new check = 0;
						while(Priority < 30)
						{
							Priority++;
							if(Priority == 30) 
							{
								if(check < 2) // Если цикл ещё не прошел круг
								{
									check++;
									Priority = 0;
								}
								else // Если крууг пройден и ни 1 лобби не найден
								{
									Priority = -1;
									break;
								}
							}
							if(LobbyInfo[Priority][Players] == MAX_PLOBBY || LobbyInfo[Priority][Activate] > 2) // Если лобби заполнено или игра уже начата, ищем следующее
							{
								continue;
							}
							else if(LobbyInfo[Priority][Players] < MAX_PLOBBY && LobbyInfo[Priority][Activate] < 3) // Если лобби не заполнено и игра ещё не начата, то
							{
								break;
							}
						}
					}
				}
				CreatePoliceUI(playerid);
				ShowPoliceUI(playerid);
			}
		}
		else 
		{
			SendClientMessage(playerid, 0xFF000000, "Все лобби заняты, повторите попытку позднее.");
		}
	}
	return 1;
}

stock GPN(playerid)
{
	new Name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, Name, MAX_PLAYER_NAME);
	return Name;
}

stock GiveSlot(playerid, lobby)
{
	PlayerInfo[playerid][Lb] = lobby;
	for(new i; i < MAX_PLOBBY; i++)
	{
		if(LobbyID[lobby][i] == -1)
		{
			LobbyID[lobby][i] 		= playerid;
			LobbyName[lobby][i] 	= GPN(playerid);
			break;
		}
	}
	LobbyInfo[Priority][Players]++;
}

stock CreatePoliceUI(playerid)
{
	new i = 0;
	new LB = PlayerInfo[playerid][Lb];
	for(new k; k < MAX_PLOBBY; k++)
	{
		if(LobbyID[LB][k] == playerid) continue;
		if(LobbyID[LB][k] == -1) continue;
		if(isnull(LobbyName[LB][k])) continue;
		if(LobbyID[LB][k] == LobbyInfo[LB][Suspect]) continue;
		PoliceUI[playerid][i] = CreatePlayerTextDraw(playerid, 470, 230 + 15 * i, "VyacheslavIvankovmas");
		PlayerTextDrawSetShadow(playerid, PoliceUI[playerid][i], 0);
		PlayerTextDrawLetterSize(playerid, PoliceUI[playerid][i], 0.2, 0.8);
		PlayerTextDrawUseBox(playerid, PoliceUI[playerid][i], 1);
		PlayerTextDrawTextSize(playerid, PoliceUI[playerid][i], 599, 40);
		PlayerTextDrawBoxColor(playerid, PoliceUI[playerid][i], 0x000000FF);
		PlayerTextDrawFont(playerid, PoliceUI[playerid][i], 2);
		PlayerTextDrawShow(playerid, PoliceUI[playerid][i]);

		RangeUI[playerid][i] = CreatePlayerTextDraw(playerid, 600, 230 + 15 * i, "blizko");
		PlayerTextDrawSetShadow(playerid, RangeUI[playerid][i], 0);
		PlayerTextDrawLetterSize(playerid, RangeUI[playerid][i], 0.2, 0.8);
		PlayerTextDrawUseBox(playerid, RangeUI[playerid][i], 1);
		PlayerTextDrawTextSize(playerid, RangeUI[playerid][i], 640, 40);
		PlayerTextDrawBoxColor(playerid, RangeUI[playerid][i], 0x000000FF);
		PlayerTextDrawFont(playerid, RangeUI[playerid][i], 2);


		i++;
	}
}

stock ShowPoliceUI(playerid)
{
	new i = 0;
	new LB = PlayerInfo[playerid][Lb];
	for(new k; k < MAX_PLOBBY; k++)
	{
		if(LobbyID[LB][k] == playerid) continue;
		if(LobbyID[LB][k] == -1) continue;
		if(isnull(LobbyName[LB][k])) continue;
		if(LobbyID[LB][k] == LobbyInfo[LB][Suspect]) continue;
		PlayerTextDrawShow(playerid, PoliceUI[playerid][i]);
		PlayerTextDrawShow(playerid, RangeUI[playerid][i]);
		i++;
	}

}