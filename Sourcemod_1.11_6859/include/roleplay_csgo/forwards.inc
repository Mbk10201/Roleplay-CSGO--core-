/**
 * @brief Called when a player dies.
 * 
 * @param attacker        	The attacker.
 * @param victim        	The victim.
 * @param weapon        	The weapon name who used when kill.
 * @param headshot        	True if victim was killed by head.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnClientDeath(int attacker, int victim, const char[] weapon, bool headshot);

/**
 * @brief Called when a weapon fire.
 * 
 * @param client        	The client who fired.
 * @param target        	The target if weapon hited him.
 * @param weapon        	The weapon name who fire.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnClientFire(int client, int target, const char[] weapon);

/**
 * @brief Called when a player spawn.
 * 
 * @param client        	The client who spawn.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnClientSpawn(int client);

/**
 * @brief Called when a player spawn for first time.
 * 
 * @param client        	The client who spawn.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnClientFirstSpawn(int client);

/**
 * @brief Called when a player get hurt.
 * 
 * @param client        	The client who get hurt.
 * @param attacker        	The attacker who infliged.
 * @param damage        	The amount of damage reduced.
 * @param armor        		The amount of armor reduced.
 * @param weapon        	The weapon used for hurt.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnClientHurt(int client, int attacker, int damage, int armor, const char[] weapon);

/**
 * @brief Called when a player text on public chat.
 * 
 * @param client        	The client who text.
 * @param arg        		The text.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnClientSay(int client, const char[] arg);

/**
 * @brief Called when a player text on team chat.
 * 
 * @param client        	The client who text.
 * @param arg        		The text.
 *
 * @return 					Plugin_Handled;
 **/
forward Action RP_OnClientSayTeam(int client, const char[] arg);

/**
 * @brief Call for add hud parameter.
 * 
 * @param text        		The text to display.
 * @param maxlen        	The text lenght.
 * @param disabled        	The text is disabled.
 *
 * @return 					Plugin_Handled;
 **/
forward Action RP_AddTextToHud(char[] text, int maxlen, bool disabled = true);

/**
 * @brief Called when a item is selled.
 * 
 * @param buyer        		The player who bought.
 * @param seller        	The player who sells(Can be a NPC).
 * @param itemID        	The itemID who has been selled.
 * @param price        		The price.
 * @param quantity        	The quantity.
 * @param payCB        		If buyer payd by Card.
 * @param car        		If product is a car.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnSell(int buyer, int seller, int itemID, int price, int quantity, bool payCB);

/**
 * @brief Called when a player use an item
 * 
 * @param client        	The player.
 * @param itemID        	The item used.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnInventoryHandle(int client, int itemID);

/**
 * @brief Called when a player interact (E).
 * 
 * @param client        	The player.
 * @param target        	The target.
 * @param class        		The class of target.
 * @param model        		The model of target.
 * @param name        		The name of target.
 *
 * @return 					Plugin_Continue;
 **/
forward void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name);

/**
 * @brief Called when a player press R (ON_RELOAD).
 * 
 * @param client        	The player.
 *
 * @return 					Plugin_Continue;
 **/
forward void RP_OnClientPress_R(int client);

/**
 * @brief Called when a player press CTRL (ON_DUCK).
 * 
 * @param client        	The player.
 *
 * @return 					Plugin_Continue;
 **/
forward void RP_OnClientPress_CTRL(int client);

/**
 * @brief Called when a player take damages.
 * 
 * @param client        	The victim.
 * @param client        	The attacker.
 * @param client        	The inflictor (entity used to attack with it).
 * @param client        	The amount of damage.
 * @param damagetype        The damagetype (BIT).
 *
 * @return 					Plugin_Continue;
 **/
forward void RP_OnClientTakeDamage(int client, int attacker, int inflictor, float &damage, int damagetype);

/**
 * @brief Called when a player open roleplay Menu (!rp).
 * 
 * @param menu        		The menu handle.
 * @param client        	The client.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnRoleplay(Menu menu, int client);

/**
 * @brief Called when a player press on roleplay menu (!rp).
 * 
 * @param client        	The client.
 * @param info        		The item index pressed.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnRoleplayHandle(int client, const char[] info);

/**
 * @brief Called when a player open settings menu (!rp -> Settings).
 * 
 * @param menu        		The menu handle.
 * @param client        	The client.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnSettings(Menu menu, int client);

/**
 * @brief Called when a player press on settings menu (!rp).
 * 
 * @param client        	The client.
 * @param info        		The item index pressed.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnSettingsHandle(int client, const char[] info);

/**
 * @brief Called when a player get a job.
 * 
 * @param giver        		The boss of the job.
 * @param target        	The client get the job.
 * @param jobname        	The jobname.
 * @param jobname        	The grade name.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnClientGetJob(int giver, int target, const char[] jobname, const char[] gradename);

/**
 * @brief Called each second on a client.
 * 
 * @param client        	The client.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_ClientTimerEverySecond(int client);

/**
 * @brief Called each second on a entity.
 * 
 * @param client        	The entity.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_EntityTimerEverySecond(int entity);

/**
 * @brief Called each second.
 * 
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_TimerEverySecond();

/**
 * @brief Called each 5 seconds.
 * 
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_TimerEvery5Second();

/**
 * @brief Called when a player open build menu (!b).
 * 
 * @param menu        		The menu handle.
 * @param client        	The client.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnClientBuild(Menu menu, int client);

/**
 * @brief Called when a player press on build menu (!b).
 * 
 * @param client        	The client.
 * @param info        		The item index pressed.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnClientBuildHandle(int client, const char[] info);

/**
 * @brief Called when a player open job menu (!rp -> Job).
 * 
 * @param menu        		The menu handle.
 * @param client        	The client.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnClientJob(Menu menu, int client);

/**
 * @brief Called when a player press on job menu (!rp -> Job).
 * 
 * @param client        	The client.
 * @param info        		The item index pressed.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnClientJobHandle(int client, const char[] info);

/**
 * @brief Called when a player walk.
 * 
 * @param client        	The client.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnFootstep(int client);

/**
 * @brief Called when a player get the first spawn messages.
 * 
 * @param client        	The client.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnClientFirstSpawnMessage(int client);

/**
 * @brief Called when a player play's an emote.
 * 
 * @param client        	The client.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnEmote(int client);

/**
 * @brief Called when a player look at an entity.
 * 
 * @param client        	The client.
 * @param client        	The target.
 * @param model        		The target model.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnLookAtTarget(int client, int target, char[] model);

/**
 * @brief Called when a helicopter is created.
 * 
 * @param entity        	The helicopter.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnHelicopterCreate(int entity);

/**
 * @brief Called when a helicopter is fly and doesn't move (IDLE).
 * 
 * @param entity        	The helicopter.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnHelicopterIdle(int entity);

/**
 * @brief Called when a helicopter do a drop.
 * 
 * @param entity        	The helicopter.
 * @param type        		The drop type (see enumeration.inc).
 * @param position        	The position of the drop.
 * @param position        	The angles of the drop.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnHelicopterDrop(int entity, int type, const char[] position, const char[] angles);

/**
 * @brief Called when a helicopter go back to base.
 * 
 * @param entity        	The helicopter.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnHelicopterGoAway(int entity);

/**
 * @brief Called when a helicopter drop the gift for new player.
 * 
 * @param entity        	The helicopter.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnGiftDropped(int entity);

/**
 * @brief Called when a player level up.
 * 
 * @param entity        	The helicopter.
 * @param new_rank        	The new level.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnLevelUp(int client, int new_rank);

/**
 * @brief Called when a player touch a entity.
 * 
 * @param caller        	The player.
 * @param activator        	The entity touched.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnClientStartTouch(int caller, int activator);

/**
 * @brief Called when the server is ont Reboot Status (ChangeMap).
 * 
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnReboot();

/**
 * @brief Called when a player finish his time-jail duration.
 * 
 * @param client        	The player.
 *
 * @return 					Plugin_Handled;
 **/
forward Action RP_OnJailTimeFinish(int client);

/**
 * @brief Called when the server init the database connection
 * 
 * @param client        	The client who text.
 * @param arg        		The text.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnSQLInit(Database db, Transaction transaction);

/**
 * @brief Called when a player open admin menu (!rp -> Administration).
 * 
 * @param menu        		The menu handle.
 * @param client        	The client.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnAdmin(Menu menu, int client);

/**
 * @brief Called when a player select smt on admin menu (!rp -> Administration).
 * 
 * @param client        	The client.
 * @param info        		The item index pressed.
 *
 * @return 					Plugin_Handled;
 **/
forward int RP_OnAdminHandle(int client, const char[] info);

/**
 * @brief Called when a roleplay entity arrives to end life.
 * 
 * @param caller        	The entity.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnEntityEndLife(int entity);

/**
 * @brief Called when a roleplay entity take damage.
 * 
 * @param caller        	The entity.
 * @param old_health        The health before the damage taken.
 * @param damage        	The damage taken.
 *
 * @return 					Plugin_Handled;
 **/
forward void RP_OnEntityReduceHealth(int entity, float old_health, float damage);

forward void RP_OnNPCInteract(int client, int entity, int jobid);

forward void RP_OnRoundStart();

forward void RP_OnStepFinished(int client, TUTORIAL_STEP step);

forward void RP_OnClockChange();

forward void RP_OnNewDay();